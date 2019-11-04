-module(preliminary_check_tests).
-author("Yuce Tekol").
-include_lib("eunit/include/eunit.hrl").


all_test_() ->
    {foreach,
     fun start/0,
     fun stop/1,
     [fun valid_token/1,
      fun variable_length_in_possible_token/1]}.


start() ->
    ok.


stop(_) ->
    ok.


valid_token(_) ->
    [?_assert(pot:valid_token(<<"123456">>)),
     ?_assertNot(pot:valid_token(<<"abcdef">>)),
     ?_assertNot(pot:valid_token(<<"12345678">>))].


variable_length_in_possible_token(_) ->
    [?_assertNot(pot:valid_token(<<"1234567">>)),
     ?_assert(pot:valid_token(<<"1234567">>, [{token_length, 7}]))].
