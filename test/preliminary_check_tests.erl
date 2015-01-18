-module(preliminary_check_tests).
-author("Yuce Tekol").
-include_lib("eunit/include/eunit.hrl").


valid_token_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun valid_token/1}.


variable_length_in_possible_token_test_() ->
    {setup, fun start/0,
            fun stop/1,
            fun variable_length_in_possible_token/1}.


start() ->
    ok.


stop(_) ->
    ok.


valid_token(_) ->
    [?_assertEqual(pot:valid_token(<<"123456">>), true),
     ?_assertEqual(pot:valid_token(<<"abcdef">>), false),
     ?_assertEqual(pot:valid_token(<<"12345678">>), false)].


variable_length_in_possible_token(_) ->
    [?_assertEqual(pot:valid_token(<<"1234567">>), false),
     ?_assertEqual(pot:valid_token(<<"1234567">>, [{token_length, 7}]), true)].
