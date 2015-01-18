-module(totp_validity_tests).
-author("Yuce Tekol").
-include_lib("eunit/include/eunit.hrl").


validating_totp_for_same_secret_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun validating_totp_for_same_secret/1}.


validating_invalid_totp_for_same_secret_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun validating_invalid_totp_for_same_secret/1}.


validating_correct_hotp_as_totp_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun validating_correct_hotp_as_totp/1}.


start() ->
    ok.


stop(_) ->
    ok.


validating_totp_for_same_secret(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    [?_assertEqual(pot:valid_totp(pot:totp(Secret), Secret), true)].


validating_invalid_totp_for_same_secret(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    [?_assertEqual(pot:valid_totp(<<"123456">>, Secret), false)].


validating_correct_hotp_as_totp(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    [?_assertEqual(pot:valid_totp(pot:hotp(Secret, 1), Secret), false)].
