-module(rfc4226_hotp_tests).
-author("Sebastien Merle").
-include_lib("eunit/include/eunit.hrl").


rfc4226_hotp_vectors_test_() ->
    Secret = pot_base32:encode(rfc4226_secret()),
    [{integer_to_list(Counter),
      ?_assertEqual(Expected, pot:hotp(Secret, Counter))}
     || {Counter, Expected} <- rfc4226_vectors()].


% RFC4226 - Appendix D - HOTP Algorithm: Test Values
% https://www.rfc-editor.org/rfc/rfc4226.html#page-32


rfc4226_secret() ->
    <<16#31, 16#32, 16#33, 16#34, 16#35,
      16#36, 16#37, 16#38, 16#39, 16#30,
      16#31, 16#32, 16#33, 16#34, 16#35,
      16#36, 16#37, 16#38, 16#39, 16#30>>.


rfc4226_vectors() ->
    [{0, <<"755224">>},
     {1, <<"287082">>},
     {2, <<"359152">>},
     {3, <<"969429">>},
     {4, <<"338314">>},
     {5, <<"254676">>},
     {6, <<"287922">>},
     {7, <<"162583">>},
     {8, <<"399871">>},
     {9, <<"520489">>}].
