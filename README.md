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

- **2017/08/03**
  - Added options to support Android devices (Thanks to Pedro Vieira)
- **2016/07/30**
  - Released version 0.9.5 with bug fixes (Thanks to Peter McLain)
- **2015/01/20**
  - Embedded base32_erlang library
- **2015/01/18**
  - Initial version


## Usage (Erlang)

We recommend using [rebar3](https://github.com/erlang/rebar3) for managing dependencies and building the library. POT is available on hex.pm, so you can just include the following in your `rebar.config`:

```
{deps, [pot]}.
```

POT works with binary tokens and secrets.

### Create a time based token

```erlang
Secret = <<"MFRGGZDFMZTWQ2LK">>,
Token = pot:totp(Secret),
% Do something with the token
```

### Create an HMAC based token

```erlang
Secret = <<"MFRGGZDFMZTWQ2LK">>,
CurrentTrial = 3,
Token = pot:hotp(Secret, CurrentTrial),
% Do something with the token
```

### Check some time based token

```erlang
Secret = <<"MFRGGZDFMZTWQ2LK">>,
Token = <<"123456">>,
IsValid = pot:valid_totp(Token, Secret),
% Do something
```

### Check some HMAC based token

```erlang
Secret = <<"MFRGGZDFMZTWQ2LK">>,
Token = <<"123456">>,
LastUsed = 5,  % last successful trial
IsValid = pot:valid_hotp(Token, Secret, [{last, LastUsed}]),
% Do something
```

## Usage (Elixir)

Include POT in your `mix.exs` as a dependency:

```elixir
defp deps do
    [{:pot, "~>0.9.6"}]
end
```

### Create a time based token

```elixir
secret = "MFRGGZDFMZTWQ2LK"
token = :pot.totp(secret)
# Do something with the token
```

### Create an HMAC based token

```elixir
secret = "MFRGGZDFMZTWQ2LK"
current_trial = 3
token = :pot.hotp(secret, current_trial)
# Do something with the token
```

### Check some time based token

```elixir
secret = "MFRGGZDFMZTWQ2LK"
token = "123456"
is_valid = :pot.valid_totp(token, secret)
# Do something
```

### Check some HMAC based token

```elixir
secret = "MFRGGZDFMZTWQ2LK"
token = "123456"
last_used = 5  # last successful trial
is_valid = :pot.valid_hotp(token, secret, [{:last, last_used}])
# Do something
```

## Credits

- Yuce Tekol
- Tomasz Jaskowski: [OneTimePass](https://github.com/tadeck/onetimepass) Python library
- Andrew Tunnell-Jones: [base32_erlang](https://github.com/aetrion/base32_erlang) library


## License

Copyright (c) 2014-2017 Yüce Tekol

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
