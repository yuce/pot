-module(totp_generation_tests).
-author("Yuce Tekol").
-include_lib("eunit/include/eunit.hrl").


generating_current_totp_and_validating_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun generating_current_totp_and_validating/1}.


start() ->
    ok.


stop(_) ->
    ok.


generating_current_totp_and_validating(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    IntervalsNo = trunc(time_now() / 30),
    Hotp = pot:hotp(Secret, IntervalsNo),
    Totp = pot:totp(Secret),
    [?_assertEqual(Hotp, Totp)].


time_now() ->
    {MegaSecs, Secs, _} = os:timestamp(),
    MegaSecs * 1000000 + Secs.
