-module(rfc6238_totp_tests).
-author("Sebastien Merle").
-include_lib("eunit/include/eunit.hrl").


rfc6238_totp_vectors_test_() ->
    [{test_name(Algorithm, UnixSeconds),
      ?_assertEqual(Expected, pot:totp(secret(Algorithm), opts(Algorithm, UnixSeconds)))}
     || {UnixSeconds, Algorithm, Expected} <- rfc6238_vectors()].


opts(Algorithm, UnixSeconds) ->
    [{digest_method, Algorithm},
     {token_length, 8},
     {timestamp, timestamp(UnixSeconds)}].


timestamp(UnixSeconds) ->
    {UnixSeconds div 1000000, UnixSeconds rem 1000000, 0}.


test_name(Algorithm, UnixSeconds) ->
    atom_to_list(Algorithm) ++ " at " ++ integer_to_list(UnixSeconds).


secret(sha) ->
    pot_base32:encode(seed(sha));
secret(sha256) ->
    pot_base32:encode(seed(sha256));
secret(sha512) ->
    pot_base32:encode(seed(sha512)).


% RFC6238 - Appendix B - Test Vectors
% https://www.rfc-editor.org/rfc/rfc6238.html#appendix-B


seed(sha) ->
    <<"12345678901234567890">>;
seed(sha256) ->
    <<"12345678901234567890123456789012">>;
seed(sha512) ->
    <<"1234567890123456789012345678901234567890123456789012345678901234">>.


rfc6238_vectors() ->
    [{59, sha, <<"94287082">>},
     {59, sha256, <<"46119246">>},
     {59, sha512, <<"90693936">>},
     {1111111109, sha, <<"07081804">>},
     {1111111109, sha256, <<"68084774">>},
     {1111111109, sha512, <<"25091201">>},
     {1111111111, sha, <<"14050471">>},
     {1111111111, sha256, <<"67062674">>},
     {1111111111, sha512, <<"99943326">>},
     {1234567890, sha, <<"89005924">>},
     {1234567890, sha256, <<"91819424">>},
     {1234567890, sha512, <<"93441116">>},
     {2000000000, sha, <<"69279037">>},
     {2000000000, sha256, <<"90698825">>},
     {2000000000, sha512, <<"38618901">>},
     {20000000000, sha, <<"65353130">>},
     {20000000000, sha256, <<"77737706">>},
     {20000000000, sha512, <<"47863826">>}].
