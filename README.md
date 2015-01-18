# POT

## Introduction

POT is an Erlang library for generating one time passwords. It supports both HMAC-based one time passwords (HOTP) and time based ones (TOTP). The generated passwords are compatible with [Google Authenticator](http://en.wikipedia.org/wiki/Google_Authenticator).

POT is an almost direct translation of the Python [OneTimePass](https://github.com/tadeck/onetimepass) library.

POT should work with any recent version of [Erlang/OTP](http://www.erlang.org/) but only tested with version 17.

In order to learn more about one time password generation, see the following Wikipedia articles:

- [Google Authenticator](http://en.wikipedia.org/wiki/Google_Authenticator)
- [HMAC-based One-time Password Algorithm](http://en.wikipedia.org/wiki/HMAC-based_One-time_Password_Algorithm)
- [Time-based One-time Password Algorithm](http://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm)

### TODO

- Usage samples for other Erlang VM based languages such as Elixir and LFE.

## Install

POT uses [rebar v2](https://github.com/rebar/rebar) for managing dependencies and building the library. Only dependency is Erlang [base32](https://github.com/aetrion/base32_erlang) library which is automatically fetched with rebar.

Fetch dependencies and compile the library once it is cloned:

    $ ./rebar get-deps compile
    
Run tests with:

    $ ./rebar skip_deps=true eunit
    
A `Makefile` is included which you can use to `make` and `make test`.

## Usage

Include POT in your `rebar config`:

    {deps, [
        {pot, ".*",
            {git, "https://github.com/yuce/pot.git", "master"}}]}.

POT works with binary tokens and secrets.

### Create a time base token

    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    Token = pot:totp(Secret),
    % Do something with the token
    
### Create an HMAC based token

    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    CurrentTrial = 3,
    Token = pot:hotp(Secret, CurrentTrial),
    % Do something with the token

### Check some time based token

    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    Token = <<"123456">>,
    IsValid = pot:valid_totp(Secret, Token),
    % Do something
    
### Check some HMAC based token
    
    Secret = <<"MFRGGZDFMZTWQ2LK">>,
    Token = <<"123456">>,
    LastUsed = 5,  % last successful trial
    IsValid = pot:valid_hotp(Secret, Token, [{last, LastUsed]),
    % Do something
