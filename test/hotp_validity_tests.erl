-module(hotp_validity_tests).
-author("Yuce Tekol").

-include_lib("eunit/include/eunit.hrl").


checking_hotp_validity_without_range_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun checking_hotp_validity_without_range/1}.


validating_correct_hotp_after_exhaustion_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun validating_correct_hotp_after_exhaustion/1}.


validating_correct_totp_as_hotp_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun validating_correct_totp_as_hotp/1}.


retrieving_proper_interval_from_validator_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun retrieving_proper_interval_from_validator/1}.


hotp_for_range_preceding_match_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun hotp_for_range_preceding_match/1}.


start() ->
    ok.


stop(_) ->
    ok.


checking_hotp_validity_without_range(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    [?_assertEqual(pot:valid_hotp(pot:hotp(Secret, 123), Secret), true)].


validating_correct_hotp_after_exhaustion(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
     [?_assertEqual(pot:valid_hotp(
            pot:hotp(Secret, 123), Secret, [{last, 123}]), false)].


validating_correct_totp_as_hotp(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    [?_assertEqual(pot:valid_hotp(pot:totp(Secret), Secret), false)].


retrieving_proper_interval_from_validator(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    Totp = <<"713385">>,
    Result = pot:valid_hotp(Totp, Secret, [{last, 1}, {trials, 5}]),
    [?_assertEqual(Result, true),
     ?_assertEqual(pot:hotp(Secret, 4), Totp)].


hotp_for_range_preceding_match(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    [?_assertEqual(pot:valid_hotp(<<"713385">>, Secret, [{last, 1}, {trials, 2}]), false)].
