-module(hotp_generation_tests).
-author("Yuce Tekol").
-include_lib("eunit/include/eunit.hrl").


all_test_() ->
    {foreach,
     fun start/0,
     fun stop/1,
     [fun hotp_generation_from_secret/1,
      fun hotp_generation_for_different_intervals/1,
      fun hotp_generation_with_padding/1,
      fun hotp_generation_with_multiple_padding/1,
      fun hotp_generation_unsigned_interval/1]}.


start() ->
    #{secret1 => <<"MFRGGZDFMZTWQ2LK">>,
      secret2 => <<"RWLMFU237M4RJIFA">>}.


stop(_) ->
    ok.


hotp_generation_from_secret(#{secret1 := Secret}) ->
    [?_assertEqual(pot:hotp(Secret, 1), <<"765705">>)].


hotp_generation_for_different_intervals(#{secret1 := Secret}) ->
    [?_assertEqual(pot:hotp(Secret, 0), <<"462371">>),
     ?_assertEqual(pot:hotp(Secret, 1), <<"765705">>),
     ?_assertEqual(pot:hotp(Secret, 2), <<"816065">>)].


hotp_generation_with_padding(#{secret1 := Secret}) ->
   [?_assertEqual(pot:hotp(Secret, 19), <<"088239">>)].


hotp_generation_with_multiple_padding(#{secret2 := Secret}) ->
   [?_assertEqual(pot:hotp(Secret, 48930987), <<"000371">>)].


hotp_generation_unsigned_interval(#{secret1 := Secret}) ->
    [{"negative intervals are equivalent to 64-bit unsigned representations (2^64 - 1)",
      ?_assertEqual(pot:hotp(Secret,  18446744073709551615),
                    pot:hotp(Secret, -1))},
     {"negative intervals are equivalent to 64-bit unsigned representations (2^63 - 1)",
      ?_assertEqual(pot:hotp(Secret,  9223372036854775808),
                    pot:hotp(Secret, -9223372036854775808))},
     {"large intervals are equivalent to 64-bit truncated representations (2^64 + 1)",
      ?_assertEqual(pot:hotp(Secret, 18446744073709551617),
                    pot:hotp(Secret, 1))}].
