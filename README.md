# POT

## Introduction

POT is an Erlang library for generating one time passwords. It supports both HMAC-based one time passwords (HOTP) and time based ones (TOTP). The generated passwords are compatible with [Google Authenticator](http://en.wikipedia.org/wiki/Google_Authenticator).

POT is an almost direct translation of the Python [OneTimePass](https://github.com/tadeck/onetimepass) library.

POT should work with any recent version of [Erlang/OTP](http://www.erlang.org/), [Elixir](http://elixir-lang.org/) and other Erlang VM based languages.

In order to learn more about one time password generation, see the following Wikipedia articles:

- [Google Authenticator](http://en.wikipedia.org/wiki/Google_Authenticator)
- [HMAC-based One-time Password Algorithm](http://en.wikipedia.org/wiki/HMAC-based_One-time_Password_Algorithm)
- [Time-based One-time Password Algorithm](http://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm)

### TODO

- Documentation.

## News

- **2015/01/20**
  - Embedded base32_erlang library  
- **2015/01/18**
  - Initial version


## Usage (Erlang)

POT uses [rebar v2](https://github.com/rebar/rebar) for managing dependencies and building the library.

Include POT in your `rebar.config`:

    {deps, [
        {pot, ".*", {git, "https://github.com/yuce/pot.git", "master"}}]}.

POT works with binary tokens and secrets.

### Create a time based token

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
    IsValid = pot:valid_hotp(Secret, Token, [{last, LastUsed}]),
    % Do something

## Usage (Elixir)

Include POT in your `mix.exs` as a dependency:

    defp deps do
      [{:pot, git: "https://github.com/yuce/pot.git"}]
    end

### Create a time based token

    secret = "MFRGGZDFMZTWQ2LK"
    token = :pot.totp(secret)
    # Do something with the token

### Create an HMAC based token

    secret = "MFRGGZDFMZTWQ2LK"
    current_trial = 3
    token = :pot.hotp(secret, current_trial)
    # Do something with the token

### Check some time based token

    secret = "MFRGGZDFMZTWQ2LK"
    token = "123456"
    is_valid = :pot.valid_totp(secret, token)
    # Do something

### Check some HMAC based token

    secret = "MFRGGZDFMZTWQ2LK"
    token = "123456"
    last_used = 5  # last successful trial
    is_valid = :pot.valid_hotp(secret, token, [{:last, last_used}])
    # Do something

## Credits

- Yuce Tekol
- Tomasz Jaskowski: [OneTimePass](https://github.com/tadeck/onetimepass) Python library
- Andrew Tunnell-Jones: [base32_erlang](https://github.com/aetrion/base32_erlang) library
