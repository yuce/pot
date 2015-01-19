%% Copyright (c) 2014 Yüce Tekol
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

-export([valid_token/1, valid_token/2]).
-export([hotp/2, hotp/3]).
-export([totp/1, totp/2]).
-export([valid_hotp/2, valid_hotp/3]).
-export([valid_totp/2, valid_totp/3]).


-type token() :: binary().
-type secret() :: binary().
-type proplistitem() :: {atom(), term()}.
-type proplist() :: [proplistitem()] | [].


-spec valid_token(token()) -> boolean().
valid_token(Token) ->
    valid_token(Token, []).


-spec valid_token(token(), proplist()) -> boolean().
valid_token(Token, Opts) when is_binary(Token) ->
    Length = proplists:get_value(token_length, Opts, 6),
    case byte_size(Token) == Length of
        true ->
            lists:all(fun(X) -> X >= $0 andalso X =< $9 end, binary_to_list(Token));
        false ->
            false end.


-spec hotp(secret(), pos_integer()) -> token().
hotp(Secret, IntervalsNo) ->
    hotp(Secret, IntervalsNo, []).


-spec hotp(secret(), pos_integer(), proplist()) -> token().
hotp(Secret, IntervalsNo, Opts) ->
    DigestMethod = proplists:get_value(digest_method, Opts, sha),
    TokenLength = proplists:get_value(token_length, Opts, 6),
    IsLower = {lower, proplists:get_bool(casefold, Opts)},
    Key = base32:decode(Secret, [{lower, IsLower}]),
    Msg = <<IntervalsNo:8/big-unsigned-integer-unit:8>>,
    Digest = crypto:hmac(DigestMethod, Key, Msg),
    <<_:19/binary, Ob:8>> = Digest,
    O = Ob band 15,
    <<TokenBase0:4/integer-unit:8>> = binary:part(Digest, O, 4),
    TokenBase = TokenBase0 band 16#7fffffff,
    Token0 = TokenBase rem trunc(math:pow(10, TokenLength)),
    Token1 = integer_to_binary(Token0),
    <<0:(TokenLength - byte_size(Token1))/integer-unit:8, Token1/binary>>.


-spec totp(secret()) -> token().
totp(Secret) ->
    totp(Secret, []).


-spec totp(secret(), proplist()) -> token().
totp(Secret, Opts) ->
    IntervalLength = proplists:get_value(interval_length, Opts, 30),
    {MegaSecs, Secs, _} = os:timestamp(),
    IntervalsNo = trunc((MegaSecs * 1000000 + Secs) / IntervalLength),
    hotp(Secret, IntervalsNo, Opts).


-spec valid_hotp(token(), secret()) -> boolean().
valid_hotp(Token, Secret) ->
    valid_hotp(Token, Secret, []).


-spec valid_hotp(token(), secret(), proplist()) -> boolean().
valid_hotp(Token, Secret, Opts) ->
    Last = proplists:get_value(last, Opts, 1),
    Trials = proplists:get_value(trials, Opts, 1000),
    TokenLength = proplists:get_value(token_length, Opts, 6),
    case valid_token(Token, [{token_length, TokenLength}]) of
        true ->
            check_candidate(Token, Secret, Last + 1, Last + Trials, Opts);
        _ ->
            false end.


-spec valid_totp(token(), secret()) -> boolean().
valid_totp(Token, Secret) ->
    valid_totp(Token, Secret, []).


-spec valid_totp(token(), secret(), proplist()) -> boolean().
valid_totp(Token, Secret, Opts) ->
    case valid_token(Token, Opts) of
        true ->
            case totp(Secret, Opts) of
                Token ->
                    true;
                _ ->
                    false end;
        _ ->
            false end.


check_candidate(Token, Secret, Current, Last, Opts) when Current =< Last ->
    case Current of
        Last ->
            false;
        _ ->
            Candidate = hotp(Secret, Current, Opts),
            case Candidate of
                Token ->
                    Current;
                _ ->
                    check_candidate(Token, Secret, Current + 1, Last, Opts) end end.

