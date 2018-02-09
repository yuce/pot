-module(totp_generation_tests).
-author("Yuce Tekol").
-include_lib("eunit/include/eunit.hrl").


generating_current_totp_and_validating_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun generating_current_totp_and_validating/1}.

generating_totp_for_given_timestamp_and_compare_test_() ->
    {setup, fun start/0,
        fun stop/1,
        fun generating_totp_for_given_timestamp_and_compare/1}.

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

generating_totp_for_given_timestamp_and_compare(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    Totp = pot:totp(Secret, [{timestamp, {1518, 179058, 919315}}]),
    [?_assertEqual(Totp, <<"151469">>)].

time_now() ->
    {MegaSecs, Secs, _} = os:timestamp(),
    MegaSecs * 1000000 + Secs.
