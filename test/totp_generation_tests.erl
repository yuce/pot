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

generating_totp_for_given_unix_time_and_compare_test_() ->
    {setup, fun start/0,
        fun stop/1,
        fun generating_totp_for_given_unix_time_and_compare/1}.

generating_post_2038_totp_for_given_unix_time_test_() ->
    {setup, fun start/0,
        fun stop/1,
        fun generating_post_2038_totp_for_given_unix_time/1}.

start() ->
    ok.


stop(_) ->
    ok.


generating_current_totp_and_validating(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    IntervalOpts = [{timestamp, os:timestamp()}],
    IntervalsNo = pot:time_interval(IntervalOpts),
    Hotp = pot:hotp(Secret, IntervalsNo),
    Totp = pot:totp(Secret, IntervalOpts),
    [?_assertEqual(Hotp, Totp)].

generating_totp_for_given_timestamp_and_compare(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    Totp = pot:totp(Secret, [{timestamp, {1518, 179058, 919315}}]),
    [?_assertEqual(Totp, <<"151469">>)].

generating_totp_for_given_unix_time_and_compare(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    UnixTime = 1518179058,
    Totp = pot:totp(Secret, [{unix_time, UnixTime}]),
    [?_assertEqual(Totp, <<"151469">>)].

generating_post_2038_totp_for_given_unix_time(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    UnixTime = 20000000000,
    Totp = pot:totp(Secret, [{unix_time, UnixTime}]),
    Hotp = pot:hotp(Secret, UnixTime div 30),
    [?_assertEqual(Hotp, Totp)].
