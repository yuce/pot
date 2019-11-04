%% Copyright (c) 2014-2017 Yüce Tekol
%
%% Permission is hereby granted, free of charge, to any person obtaining a copy of this software
%% and associated documentation files (the "Software"), to deal in the Software without
%% restriction, including without limitation the rights to use, copy, modify, merge, publish,
%% distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
%% Software is furnished to do so, subject to the following conditions:
%
%% The above copyright notice and this permission notice shall be included in all copies or
%% substantial portions of the Software.
%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
%% BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
%% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

-module(pot).

% API
-export([hotp/2, hotp/3]).
-export([totp/1, totp/2]).

-export([valid_token/1, valid_token/2]).
-export([valid_hotp/2, valid_hotp/3]).
-export([valid_totp/2, valid_totp/3]).

% Internal API
-export([time_interval/1]).

% Types
-export_type([token/0, secret/0, interval/0]).

-export_type([valid_token_options/0,
              hotp_options/0,
              totp_options/0,
              valid_hotp_options/0,
              valid_totp_options/0,
              time_interval_options/0]).

%%==============================================================================
%% Types
%%==============================================================================

-type interval() :: integer().
-type secret() :: binary().
-type token() :: binary().

-type token_option() :: {token_length, pos_integer()}.

-type time_interval_option() :: {addwindow, integer()} |
                                {interval_length, pos_integer()} |
                                {timestamp, erlang:timestamp()}.

-type hotp_option() :: token_option() |
                       {digest_method, atom()}.

-type totp_option() :: hotp_option() | time_interval_option().

-type valid_hotp_option() :: hotp_option() |
                             {last, interval()} |
                             {trials, pos_integer()}.

-type valid_totp_option() :: totp_option() |
                             {window, non_neg_integer()}.

-type hotp_options() :: [hotp_option()].
-type totp_options() :: [totp_option()].

-type valid_token_options() :: [token_option()].
-type valid_hotp_options() :: [valid_hotp_option()].
-type valid_totp_options() :: [valid_totp_option()].

-type time_interval_options() :: [time_interval_option()].

%%==============================================================================
%% Token generation
%%==============================================================================

-spec hotp(secret(), interval()) -> token().
hotp(Secret, IntervalsNo) ->
    hotp(Secret, IntervalsNo, []).

-spec hotp(secret(), interval(), hotp_options()) -> token().
hotp(Secret, IntervalsNo, Opts) ->
    DigestMethod = proplists:get_value(digest_method, Opts, sha),
    TokenLength = proplists:get_value(token_length, Opts, 6),
    Key = pot_base32:decode(Secret),
    Msg = <<IntervalsNo:8/big-unsigned-integer-unit:8>>,
    Digest = crypto:hmac(DigestMethod, Key, Msg),
    <<_:19/binary, Ob:8>> = Digest,
    O = Ob band 15,
    <<TokenBase0:4/integer-unit:8>> = binary:part(Digest, O, 4),
    TokenBase = TokenBase0 band 16#7fffffff,
    Token0 = TokenBase rem trunc(math:pow(10, TokenLength)),
    Token1 = integer_to_binary(Token0),
    prepend_zeros(Token1, TokenLength - byte_size(Token1)).

-spec totp(secret()) -> token().
totp(Secret) ->
    totp(Secret, []).

-spec totp(secret(), totp_options()) -> token().
totp(Secret, Opts) ->
    IntervalsNo = time_interval(Opts),
    hotp(Secret, IntervalsNo, Opts).

%%==============================================================================
%% Token validation
%%==============================================================================

-spec valid_token(token()) -> boolean().
valid_token(Token) ->
    valid_token(Token, []).

-spec valid_token(token(), valid_token_options()) -> boolean().
valid_token(Token, Opts) when is_binary(Token) ->
    Length = proplists:get_value(token_length, Opts, 6),
    case byte_size(Token) == Length of
        true ->
            lists:all(fun(X) -> X >= $0 andalso X =< $9 end, binary_to_list(Token));
        false ->
            false
    end.

-spec valid_hotp(token(), secret()) -> boolean().
valid_hotp(Token, Secret) ->
    valid_hotp(Token, Secret, []).

-spec valid_hotp(token(), secret(), valid_hotp_options()) -> boolean().
valid_hotp(Token, Secret, Opts) ->
    Last = proplists:get_value(last, Opts, 1),
    Trials = proplists:get_value(trials, Opts, 1000),
    TokenLength = proplists:get_value(token_length, Opts, 6),
    case valid_token(Token, [{token_length, TokenLength}]) of
        true ->
            case check_candidate(Token, Secret, Last + 1, Last + Trials, Opts) of
                false ->
                    false;
                _ ->
                    true
            end;
        _ ->
            false
    end.

-spec valid_totp(token(), secret()) -> boolean().
valid_totp(Token, Secret) ->
    valid_totp(Token, Secret, []).

-spec valid_totp(token(), secret(), valid_totp_options()) -> boolean().
valid_totp(Token, Secret, Opts) ->
    case valid_token(Token, Opts) of
        true ->
            IntervalsNo = time_interval(Opts),
            case totp(Secret, Opts) of
                Token ->
                    true;
                _ ->
                    Window = proplists:get_value(window, Opts, 0),
                    case check_candidate(Token, Secret, IntervalsNo - Window, IntervalsNo + Window, Opts) of
                        false ->
                            false;
                        _ ->
                            true
                    end
            end;
        _ ->
            false
    end.

%%==============================================================================
%% Internal functions
%%==============================================================================

-spec time_interval(time_interval_options()) -> interval().
time_interval(Opts) ->
  IntervalLength = proplists:get_value(interval_length, Opts, 30),
  AddSeconds = proplists:get_value(addwindow, Opts, 0) * proplists:get_value(interval_length, Opts, 30),
  {MegaSecs, Secs, _} = proplists:get_value(timestamp, Opts, os:timestamp()),
  trunc((MegaSecs * 1000000 + (Secs + AddSeconds)) / IntervalLength).

-spec check_candidate(token(), secret(), interval(), interval(), hotp_options()) ->
    interval() | false.
check_candidate(Token, Secret, Current, Last, Opts) when Current =< Last ->
    case hotp(Secret, Current, Opts) of
        Token ->
            Current;
        _ ->
            check_candidate(Token, Secret, Current + 1, Last, Opts)
    end;
check_candidate(_Token, _Secret, _Current, _Last, _Opts) ->
    false.

-spec prepend_zeros(token(), non_neg_integer()) -> token().
prepend_zeros(Token, N) ->
    Padding = << <<48:8>> || _ <- lists:seq(1, N) >>,
    <<Padding/binary, Token/binary>>.
