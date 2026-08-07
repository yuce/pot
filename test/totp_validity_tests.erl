-module(totp_validity_tests).
-author("Yuce Tekol").
-include_lib("eunit/include/eunit.hrl").


totp_validity_test_() ->
    {foreach,
     fun start/0,
     fun stop/1,
     [fun validating_totp_for_same_secret/1,
      fun validating_invalid_totp_for_same_secret/1,
      fun validating_invalid_token_hotp/1,
      fun validating_correct_hotp_as_totp/1,
      fun validating_past_future_totp_too_small_window/1,
      fun validating_past_future_totp_with_window/1,
      fun retrieving_proper_interval_from_validator/1,
      fun retrieving_window_matched_interval_from_validator/1]}.


start() ->
    _Secret = <<"MFRGGZDFMZTWQ2LK">>.


stop(_) ->
    ok.


validating_totp_for_same_secret(Secret) ->
    [?_assert(pot:valid_totp(pot:totp(Secret), Secret))].


validating_invalid_totp_for_same_secret(Secret) ->
    [?_assertNot(pot:valid_totp(<<"123456">>, Secret))].


validating_invalid_token_hotp(Secret) ->
     [?_assertNot(pot:valid_totp(<<"abcdef">>, Secret))].


validating_correct_hotp_as_totp(Secret) ->
    [?_assertNot(pot:valid_totp(pot:hotp(Secret, 1), Secret))].


validating_past_future_totp_too_small_window(Secret) ->
    IntervalOpts = [{timestamp, os:timestamp()}],
    N = 5,
    [?_assertNot(pot:valid_totp(pot:totp(Secret, [{addwindow, AW} | IntervalOpts]),
                                Secret,
                                [{window, W} | IntervalOpts]))
     || W <- lists:seq(0, N), AW <- lists:seq(-N, N), W < abs(AW)].


validating_past_future_totp_with_window(Secret) ->
    IntervalOpts = [{timestamp, os:timestamp()}],
    N = 5,
    [?_assert(pot:valid_totp(pot:totp(Secret, [{addwindow, AW} | IntervalOpts]),
                             Secret,
                             [{window, W} | IntervalOpts]))
     || W <- lists:seq(0, N), AW <- lists:seq(-N, N), W >= abs(AW)].


retrieving_proper_interval_from_validator(Secret) ->
    Timestamp = {1518, 179058, 919315},
    Interval = pot:time_interval([{timestamp, Timestamp}]),
    Totp = pot:totp(Secret, [{timestamp, Timestamp}]),
    [?_assert(pot:valid_totp(Totp, Secret, [{timestamp, Timestamp}])),
     ?_assert(pot:valid_totp(Totp, Secret, [{timestamp, Timestamp},
                                            {return_interval, false}])),
     ?_assertEqual({true, Interval},
                   pot:valid_totp(Totp, Secret, [{timestamp, Timestamp},
                                                 {return_interval, true}]))].


retrieving_window_matched_interval_from_validator(Secret) ->
    Timestamp = {1518, 179058, 919315},
    Interval = pot:time_interval([{timestamp, Timestamp}]),
    Totp = pot:totp(Secret, [{timestamp, Timestamp}, {addwindow, -1}]),
    [?_assertEqual({true, Interval - 1},
                   pot:valid_totp(Totp, Secret, [{timestamp, Timestamp},
                                                 {window, 1},
                                                 {return_interval, true}]))].
