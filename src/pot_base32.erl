%% -------------------------------------------------------------------
%%
%% Copyright (c) 2012 Andrew Tunnell-Jones. All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------
-module(pot_base32).
-export([encode/1, encode/2, decode/1, decode/2]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

encode(Bin) when is_binary(Bin) -> encode(Bin, []);
encode(List) when is_list(List) -> encode(list_to_binary(List), []).

encode(Bin, Opts) when is_binary(Bin) andalso is_list(Opts) ->
    Hex = proplists:get_bool(hex, Opts),
    Lower = proplists:get_bool(lower, Opts),
    Fun = case Hex of
	      true -> fun(I) -> hex_enc(Lower, I) end;
	      false -> fun(I) -> std_enc(Lower,  I) end
	  end,
    {Encoded0, Rest} = encode_body(Fun, Bin),
    {Encoded1, PadBy} = encode_rest(Fun, Rest),
    Padding = case proplists:get_bool(nopad, Opts) of
		  true -> <<>>;
		  false -> list_to_binary(lists:duplicate(PadBy, $=))
	      end,
    <<Encoded0/binary, Encoded1/binary, Padding/binary>>;
encode(List, Opts) when is_list(List) andalso is_list(Opts) ->
    encode(list_to_binary(List), Opts).

encode_body(Fun, Bin) ->
    Offset = 5 * (byte_size(Bin) div 5),
    <<Body:Offset/binary, Rest/binary>> = Bin,
    {<< <<(Fun(I))>> || <<I:5>> <= Body>>, Rest}.

encode_rest(Fun, Bin) ->
    Whole = bit_size(Bin) div 5,
    Offset = 5 * Whole,
    <<Body:Offset/bits, Rest/bits>> = Bin,
    Body0 = << <<(Fun(I))>> || <<I:5>> <= Body>>,
    {Body1, Pad} = case Rest of
		       <<I:3>> -> {<<(Fun(I bsl 2))>>, 6};
		       <<I:1>> -> {<<(Fun(I bsl 4))>>, 4};
		       <<I:4>> -> {<<(Fun(I bsl 1))>>, 3};
		       <<I:2>> -> {<<(Fun(I bsl 3))>>, 1};
		       <<>> -> {<<>>, 0}
		   end,
    {<<Body0/binary, Body1/binary>>, Pad}.

std_enc(_, I) when is_integer(I) andalso I >= 26 andalso I =< 31 -> I + 24;
std_enc(Lower, I) when is_integer(I) andalso I >= 0 andalso I =< 25 ->
    case Lower of
	true -> I + $a;
	false -> I + $A
    end.

hex_enc(_, I) when is_integer(I) andalso I >= 0 andalso I =< 9 -> I + 48;
hex_enc(Lower, I) when is_integer(I) andalso I >= 10 andalso I =< 31 ->
    case Lower of
	true -> I + 87;
	false -> I + 55
    end.

decode(Bin) when is_binary(Bin) -> decode(Bin, []);
decode(List) when is_list(List) -> decode(list_to_binary(List), []).

decode(Bin, Opts) when is_binary(Bin) andalso is_list(Opts) ->
    Fun = case proplists:get_bool(hex, Opts) of
	      true -> fun hex_dec/1;
	      false -> fun std_dec/1
	  end,
    decode(Fun, Bin, <<>>);
decode(List, Opts) when is_list(List) andalso is_list(Opts) ->
    decode(list_to_binary(List), Opts).

decode(Fun, <<A, B, "======">>, Bits) ->
    decode_final(Fun, [A, B], Bits, 2);
decode(Fun, <<A, B, C, D, "====">>, Bits) ->
    decode_final(Fun, [A, B, C, D], Bits, 4);
decode(Fun, <<A, B, C, D, E, "===">>, Bits) ->
    decode_final(Fun, [A, B, C, D, E], Bits, 1);
decode(Fun, <<A, B, C, D, E, F, G, "=">>, Bits) ->
    decode_final(Fun, [A, B, C, D, E, F, G], Bits, 3);
decode(_Fun, <<"=", _Rest/binary>>, _Bits) ->
    error(badarg);
decode(Fun, <<X, Rest/binary>>, Bits) ->
    decode(Fun, Rest, <<Bits/bits, (Fun(X)):5>>);
decode(_Fun, <<>>, Bits) ->
    trim_padding(Bits, bit_size(Bits) rem 8).

decode_final(Fun, [X | Rest], Bits, UnusedBits) ->
    decode_final(Fun, Rest, <<Bits/bits, (Fun(X)):5>>, UnusedBits);
decode_final(_Fun, [], Bits, UnusedBits) ->
    trim_padding(Bits, UnusedBits).

trim_padding(Bits, 0) -> Bits;
trim_padding(Bits, UnusedBits) when UnusedBits >= 1, UnusedBits =< 4 ->
    BitSize = bit_size(Bits) - UnusedBits,
    <<Decoded:BitSize/bits, Unused:UnusedBits>> = Bits,
    case Unused of
        0 -> Decoded;
        _ -> error(badarg)
    end;
trim_padding(_Bits, _UnusedBits) ->
    error(badarg).

std_dec(I) when I >= $2 andalso I =< $7 -> I - 24;
std_dec(I) when I >= $a andalso I =< $z -> I - $a;
std_dec(I) when I >= $A andalso I =< $Z -> I - $A;
std_dec(_I) -> error(badarg).

hex_dec(I) when I >= $0 andalso I =< $9 -> I - 48;
hex_dec(I) when I >= $a andalso I =< $v -> I - 87;
hex_dec(I) when I >= $A andalso I =< $V -> I - 55;
hex_dec(_I) -> error(badarg).

-ifdef(TEST).

std_cases() ->
    [{<<"">>, <<"">>},
     {<<"f">>, <<"MY======">>},
     {<<"fo">>, <<"MZXQ====">>},
     {<<"foo">>, <<"MZXW6===">>},
     {<<"foob">>, <<"MZXW6YQ=">>},
     {<<"fooba">>, <<"MZXW6YTB">>},
     {<<"foobar">>, <<"MZXW6YTBOI======">>}].

lower_cases(Cases) ->
    [{I, << <<(string:to_lower(C))>> || <<C>> <= O >>} || {I, O} <- Cases ].

nopad_cases(Cases) ->
    [{I, << <<C>> || <<C>> <= O, C =/= $= >>} || {I, O} <- Cases].

stringinput_cases(Cases) -> [{binary_to_list(I), O} || {I, O} <- Cases].

stringoutput_cases(Cases) -> [{I, binary_to_list(O)} || {I, O} <- Cases].

std_encode_test_() ->
    [ ?_assertEqual(Out, encode(In)) || {In, Out} <- std_cases() ].

std_decode_test_() ->
    [ ?_assertEqual(Out, decode(In)) || {Out, In} <- std_cases() ].

std_encode_lower_test_() ->
    [ ?_assertEqual(Out, encode(In, [lower])) ||
	{In, Out} <- lower_cases(std_cases()) ].

std_decode_lower_test_() ->
    [ ?_assertEqual(Out, decode(In)) || {Out, In} <- lower_cases(std_cases()) ].

std_encode_nopad_test_() ->
    [ ?_assertEqual(Out, encode(In, [nopad]))
      || {In, Out} <- nopad_cases(std_cases()) ].

std_decode_nopad_test_() ->
    [ ?_assertEqual(Out, decode(In))
      || {Out, In} <- nopad_cases(std_cases()) ].

std_decode_nopad_byte_aligned_test_() ->
    [ ?_assertEqual(8 * byte_size(Out), bit_size(decode(In)))
      || {Out, In} <- nopad_cases(std_cases()) ].

std_encode_lower_nopad_test_() ->
    [ ?_assertEqual(Out, encode(In, [lower,nopad]))
      || {In, Out} <- nopad_cases(lower_cases(std_cases())) ].

std_decode_malformed_padding_test_() ->
    [ ?_assertError(badarg, decode(<<"M=">>)),
      ?_assertError(badarg, decode(<<"MY=">>)),
      ?_assertError(badarg, decode(<<"MY=====">>)),
      ?_assertError(badarg, decode(<<"M=Y=====">>)) ].

std_decode_non_zero_unused_bits_test_() ->
    [ ?_assertError(badarg, decode(<<"MZ======">>)),
      ?_assertError(badarg, decode(<<"MZXZ====">>)),
      ?_assertError(badarg, decode(<<"MZXW7===">>)),
      ?_assertError(badarg, decode(<<"MZXW6YZ=">>)) ].

std_decode_invalid_alphabet_test_() ->
    [ ?_assertError(badarg, decode(<<"M0======">>)),
      ?_assertError(badarg, decode(<<"M1======">>)),
      ?_assertError(badarg, decode(<<"M8======">>)),
      ?_assertError(badarg, decode(<<"M+======">>)) ].

std_encode_string_test_() ->
    [ ?_assertEqual(Out, encode(In))
      || {In, Out} <- stringinput_cases(std_cases()) ].

std_decode_string_test_() ->
    [ ?_assertEqual(Out, decode(In))
      || {Out, In} <- stringoutput_cases(std_cases()) ].

hex_cases() ->
    [{<<>>, <<>>},
     {<<"f">>, <<"CO======">>},
     {<<"fo">>, <<"CPNG====">>},
     {<<"foo">>, <<"CPNMU===">>},
     {<<"foob">>, <<"CPNMUOG=">>},
     {<<"fooba">>, <<"CPNMUOJ1">>},
     {<<"foobar">>, <<"CPNMUOJ1E8======">>}].

hex_encode_test_() ->
    [ ?_assertEqual(Out, encode(In, [hex])) || {In, Out} <- hex_cases() ].

hex_decode_test_() ->
    [ ?_assertEqual(Out, decode(In, [hex])) || {Out, In} <- hex_cases() ].

hex_encode_lower_test_() ->
    [ ?_assertEqual(Out, encode(In, [hex,lower]))
      || {In, Out} <- lower_cases(hex_cases()) ].

hex_decode_lower_test_() ->
    [ ?_assertEqual(Out, decode(In, [hex]))
      || {Out, In} <- lower_cases(hex_cases()) ].

hex_encode_nopad_test_() ->
    [ ?_assertEqual(Out, encode(In, [hex,nopad]))
      || {In, Out} <- nopad_cases(hex_cases()) ].

hex_decode_nopad_test_() ->
    [ ?_assertEqual(Out, decode(In, [hex]))
      || {Out, In} <- nopad_cases(hex_cases()) ].

hex_decode_nopad_byte_aligned_test_() ->
    [ ?_assertEqual(8 * byte_size(Out), bit_size(decode(In, [hex])))
      || {Out, In} <- nopad_cases(hex_cases()) ].

hex_encode_lower_nopad_test_() ->
    [ ?_assertEqual(Out, encode(In, [hex,lower,nopad]))
      || {In, Out} <- nopad_cases(lower_cases(hex_cases())) ].

hex_decode_malformed_padding_test_() ->
    [ ?_assertError(badarg, decode(<<"C=">>, [hex])),
      ?_assertError(badarg, decode(<<"CO=">>, [hex])),
      ?_assertError(badarg, decode(<<"CO=====">>, [hex])),
      ?_assertError(badarg, decode(<<"C=O=====">>, [hex])) ].

hex_decode_non_zero_unused_bits_test_() ->
    [ ?_assertError(badarg, decode(<<"CP======">>, [hex])),
      ?_assertError(badarg, decode(<<"CPNH====">>, [hex])),
      ?_assertError(badarg, decode(<<"CPNMV===">>, [hex])),
      ?_assertError(badarg, decode(<<"CPNMUOH=">>, [hex])) ].

hex_decode_invalid_alphabet_test_() ->
    [ ?_assertError(badarg, decode(<<"CW======">>, [hex])),
      ?_assertError(badarg, decode(<<"CX======">>, [hex])),
      ?_assertError(badarg, decode(<<"CY======">>, [hex])),
      ?_assertError(badarg, decode(<<"CZ======">>, [hex])) ].

hex_encode_string_test_() ->
    [ ?_assertEqual(Out, encode(In, [hex]))
      || {In, Out} <- stringinput_cases(hex_cases()) ].

hex_decode_string_test_() ->
    [ ?_assertEqual(Out, decode(In, [hex]))
      || {Out, In} <- stringoutput_cases(hex_cases()) ].

-endif.
