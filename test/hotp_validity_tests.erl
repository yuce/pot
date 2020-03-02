-module(hotp_validity_tests).
-author("Yuce Tekol").

-include_lib("eunit/include/eunit.hrl").


checking_hotp_validity_without_range_test_() ->
    {foreach,
     fun start/0,
     fun stop/1,
     [fun checking_hotp_validity_without_range/1,
      fun checking_hotp_validity_without_range_return_interval/1,
      fun checking_hotp_validity_max_default_range/1,
      fun checking_hotp_validity_past_max_default_range/1,
      fun validating_invalid_token_hotp/1,
      fun validating_correct_hotp_after_exhaustion/1,
      fun validating_correct_totp_as_hotp/1,
      fun retrieving_proper_interval_from_validator/1,
      fun hotp_for_range_exact_match/1,
      fun hotp_for_range_preceding_match/1]}.


start() ->
    _Secret = <<"MFRGGZDFMZTWQ2LK">>.


stop(_) ->
    ok.


checking_hotp_validity_without_range(Secret) ->
    [?_assert(pot:valid_hotp(pot:hotp(Secret, 123), Secret))].


checking_hotp_validity_without_range_return_interval(Secret) ->
    [?_assertEqual({true, 123},
                   pot:valid_hotp(pot:hotp(Secret, 123), Secret, [return_interval]))].


checking_hotp_validity_max_default_range(Secret) ->
    [{"hotp at the max # of trials (1000) past the start (1) is valid",
      ?_assert(pot:valid_hotp(pot:hotp(Secret, 1001), Secret))}].


checking_hotp_validity_past_max_default_range(Secret) ->
    [{"hotp beyond the max # of trials (1000) past the start (1) is invalid",
      ?_assertNot(pot:valid_hotp(pot:hotp(Secret, 1002), Secret))}].


validating_invalid_token_hotp(Secret) ->
     [?_assertNot(pot:valid_hotp(<<"abcdef">>, Secret))].


validating_correct_hotp_after_exhaustion(Secret) ->
     [?_assertNot(pot:valid_hotp(pot:hotp(Secret, 123), Secret, [{last, 123}]))].


validating_correct_totp_as_hotp(Secret) ->
    [?_assertNot(pot:valid_hotp(pot:totp(Secret), Secret))].


retrieving_proper_interval_from_validator(Secret) ->
    Hotp = <<"713385">>,
    [?_assert(pot:valid_hotp(Hotp, Secret, [{last, 1}, {trials, 5}])),
     ?_assert(pot:valid_hotp(Hotp, Secret, [{last, 1}, {trials, 5},
                                            {return_interval, false}])),
     ?_assertEqual({true, 4},
                   pot:valid_hotp(Hotp, Secret, [{last, 1}, {trials, 5},
                                                 {return_interval, true}])),
     ?_assertEqual(pot:hotp(Secret, 4), Hotp)].


hotp_for_range_exact_match(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    Hotp = <<"816065">>,
    [?_assert(pot:valid_hotp(Hotp, Secret, [{last, 1}, {trials, 1}])),
     ?_assert(pot:valid_hotp(Hotp, Secret, [{last, 1}, {trials, 1},
                                            {return_interval, false}])),
     ?_assertEqual({true, 2},
                   pot:valid_hotp(Hotp, Secret, [{last, 1}, {trials, 1},
                                                 {return_interval, true}])),
     ?_assertEqual(pot:hotp(Secret, 2), Hotp)].


hotp_for_range_preceding_match(_) ->
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    Hotp = <<"713385">>,
    [?_assertNot(pot:valid_hotp(Hotp, Secret, [{last, 1}, {trials, 2}])),
     ?_assertNot(pot:valid_hotp(Hotp, Secret, [{last, 1}, {trials, 2},
                                               {return_interval, true}])),
     ?_assertEqual(pot:hotp(Secret, 4), Hotp)].
