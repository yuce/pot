-module(hotp_generation_tests).
-author("Yuce Tekol").
-include_lib("eunit/include/eunit.hrl").


hotp_generation_from_secret_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun hotp_generation_from_secret/1}.


hotp_generation_for_different_intervals_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun hotp_generation_for_different_intervals/1}.


start() ->
    ok.


stop(_) ->
    ok.


hotp_generation_from_secret(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    [?_assertEqual(pot:hotp(Secret, 1), <<"765705">>)].


hotp_generation_for_different_intervals(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    [?_assertEqual(pot:hotp(Secret, 1), <<"765705">>),
     ?_assertEqual(pot:hotp(Secret, 2), <<"816065">>)].
