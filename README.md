[![coveralls.io](https://api.travis-ci.org/yuce/pot.svg?branch=master)](https://travis-ci.org/yuce/pot)
[![coveralls.io](https://coveralls.io/repos/github/yuce/pot/badge.svg?branch=master)](https://coveralls.io/github/yuce/pot)
[![hex.pm](http://img.shields.io/hexpm/v/pot.svg?style=flat)](https://hex.pm/packages/pot)


# POT

- [Introduction](#introduction)
- [Version History](#version-history)
- [Usage](#usage)
- [Function Reference](#function-ref)
- [Examples (Erlang)](#examples-erlang)
- [Examples (Elixir)](#examples-elixir)
- [Credits](#credits)
- [Licence](#license)

## Introduction

POT is an Erlang library for generating one time passwords. It supports both HMAC-based one time passwords (HOTP) and time based ones (TOTP). The generated passwords are based on [RFC 4226][rfc4226] and [RFC 6238][rfc6238], compatible with [Google Authenticator][google_auth_wiki].

POT is an almost direct translation of the Python [OneTimePass][onetimepass] library.

POT should work with any recent version of [Erlang/OTP][erlang], [Elixir][elixir], and other Erlang VM based languages.

In order to learn more about one time password generation, see the following Wikipedia articles:

- [Google Authenticator][google_auth_wiki]
- [HMAC-based One-time Password Algorithm][hotp_wiki] ([RFC 4226][rfc4226])
- [Time-based One-time Password Algorithm][totp_wiki] ([RFC 6238][rfc6238])

## Version History

### 2020-03-08

- Released version 0.11.0 with the following changes:

    * [Improved types, README documentation](https://github.com/yuce/pot/commit/fa4d4314465f7cb7d32526c4c495fcf4f7b0eaf5) (Thanks to Nicholas Lundgaard)
    * [Add return_interval option to valid_hotp](https://github.com/yuce/pot/commit/62b8289afe9bc807dd055cec13a810594dc91e8a) (Thanks to Nicholas Lundgaard)

### 2019-10-16

- Released version 0.10.2 with the following change:

    * [Fix valid_totp to support upper bound on check_candidate](https://github.com/yuce/pot/pull/20) (Thanks to Nicholas Lundgaard)

### 2019-08-03

- Released version 0.10.1 with the following change:

    * [Added pot prefix to base32 module avoid name collision](https://github.com/yuce/pot/pull/16) (Thanks to Girish Ramnani). This is a breaking change, `base32` module was renamed to `pot_base32`.

### 2019-07-09

- Released version 0.9.8 with the following bug fix:

    * [Return boolean on pot:valid_hotp/2 and pot:valid_hotp/3](https://github.com/yuce/pot/pull/15) (Thanks to Zbigniew Pekala)

### 2018-02-12

  - `pot:totp/2` supports setting the timestamp (Thanks to Julius Beckmann)

### 2017-08-04

  - Added options to support Android devices (Thanks to Pedro Vieira)

### 2016-07-30

  - Released version 0.9.5 with bug fixes (Thanks to Peter McLain)

### 2015-01-20

  - Embedded base32_erlang library

### 2015-01-18

  - Initial version
  
## Usage

See the sections below on using `pot` in your Erlang and Elixir project.

### Erlang

We recommend using [rebar3][rebar3] for managing dependencies and building the library. POT is available on hex.pm, so you can just include the following in your `rebar.config`:

```
{deps, [pot]}.
```

See the [Erlang examples](#examples-erlang)

### Elixir

Include POT in your `mix.exs` as a dependency:

```elixir
defp deps do
    [{:pot, "~>0.10.1"}]
end
```

## <a id="function-ref"></a>Function Reference

The functions below refer to the following common parameters:

| Parameter  | Type     |
|------------|----------|
| `Interval` | integer  |
| `Secret`   | string\* |
| `Token`    | string\* |

- `Interval` is an integer that represents the counter value, the "moving factor" referenced in [RFC 4226][rfc4226]. It is an 8 byte unsigned integer; if a negative and/or too large integer is passed, it will be 2's complemented and truncated appropriately.
- `Secret` is a base-32-encoded secret key. Generally, it should be at least 128 bits, preferably 160 bits. 
- `Token` is a HOTP/TOTP value represented as a string\*. This is generally a 6-digit number, e.g., "123456", but its length may be modulated with the `token_length` option.

\*Note: for [Erlang][erlang] uses of `pot`, all strings should be in `binary()` format.

### Token Generation Functions

#### `hotp/2,3`

Generate an [RFC 4226][rfc4226] compatible HOTP token. 

Erlang:

```
pot:hotp(Secret, Interval) -> Token
pot:hotp(Secret, Interval, Options) -> Token
```

Elixir:

```
:pot.hotp(Secret, Interval) -> Token
:pot.hotp(Secret, Interval, Options) -> Token
```

The following `Options` are allowed:

| Option          | Type        | Default |
|-----------------|-------------|---------|
| `digest_method` | atom        | sha     |
| `token_length`  | integer > 0 | 6       |

- `digest_method` controls the signing algorithm passed to the [Erlang][erlang] `crypto` module's [`hmac`][crypto_hmac] function. For [RFC 4226][rfc4226] compliant tokens, it must be set to `sha`. For [RFC 6238][rfc6238] compliant tokens, additional values such as `sha256` or `sha512` may be used.
- `token_length` controls the number of digits in output `Token`.

#### `totp/1,2`

Generate an [RFC 6238][rfc6238] compatible TOTP token. 

Erlang:

```
pot:totp(Secret) -> Token
pot:totp(Secret, Options) -> Token
```

Elixir:

```
:pot.totp(Secret) -> Token
:pot.totp(Secret, Options) -> Token
```

The following `Options` are allowed:

| Option            | Type        | Default/Reference        |
|-------------------|-------------|--------------------------|
| `addwindow`       | integer     | 0                        |
| `digest_method`   | atom        | from [hotp/2,3](#hotp23) |
| `interval_length` | integer > 0 | 30                       |
| `timestamp`       | timestamp   | [`os:timestamp()`][ts]   |
| `token_length`    | integer > 0 | from [hotp/2,3](#hotp23) |

- `addwindow` acts as an offset to the `Interval` extrapolated from dividing the `timestamp` by the `interval_length` per the algorithm described in [RFC 6238][rfc6238].
- `interval_length` controls the number of seconds for the `Interval` computation.
- `timestamp` may be passed to specify a custom timestamp (in Erlang [timestamp][ts] format) to use for computing the `Interval` used to generate a `Token`.

### Token Validation Functions

#### `valid_token/1,2`

Validate that a given `Token` has the correct format (correct length, all digits).

Erlang:

```
pot:valid_token(Token) -> Boolean
pot:valid_token(Token, Options) -> Boolean
```

Elixir:

```
:pot.valid_token(Token) -> Boolean
:pot.valid_token(Token, Options) -> Boolean
```

The following `Options` are allowed:

| Option            | Type        | Default/Reference        |
|-------------------|-------------|--------------------------|
| `token_length`    | integer > 0 | from [hotp/2,3](#hotp23) |

#### `valid_hotp/2,3`

Validate an [RFC 4226][rfc4226] compatible HOTP token. Returns `true` if the `Token` is valid. 

Erlang:

```
pot:valid_hotp(Token, Secret) -> Boolean
pot:valid_hotp(Token, Secret, Options) -> Boolean | {true, interval()}
```

Elixir:

```
:pot.valid_hotp(Token, Secret) -> Boolean
:pot.valid_hotp(Token, Secret, Options) -> Boolean | {true, interval()}
```

The following `Options` are allowed:

| Option            | Type        | Default/Reference        |
|-------------------|-------------|--------------------------|
| `digest_method`   | atom        | from [hotp/2,3](#hotp23) |
| `last`            | integer     | 1                        |
| `return_interval` | boolean     | false                     |
| `token_length`    | integer > 0 | from [hotp/2,3](#hotp23) |
| `trials`          | integer > 0 | 1000                     |

- `last` is the `Interval` value of the previous valid `Token`; the next `Interval` after `last` is used as the first candidate for validating the `Token`.
- `trials` controls the number of incremental `Interval` values after `last` to try when validating the `Token`. If a matching candidate is not found within `trials` attempts, the `Token` is considered invalid.
- `return_interval` controls whether the matching `Interval` of a valid `Token` is returned with the result. if set to `true`, then `valid_hotp/2` will return `{true, Interval}` (e.g., `{true, 123}`) when a valid `Token` is provided.

#### `valid_totp/2,3`

Validate an [RFC 6238][rfc6238] compatible TOTP token. Returns `true` if the `Token` is valid.

Erlang:

```
pot:valid_totp(Token, Secret) -> Boolean
pot:valid_totp(Token, Secret, Options) -> Boolean
```

Elixir:

```
:pot.valid_totp(Token, Secret) -> Boolean
:pot.valid_totp(Token, Secret, Options) -> Boolean
```

The following `Options` are allowed:

| Option            | Type        | Default/Reference        |
|-------------------|-------------|--------------------------|
| `addwindow`       | integer     | from [totp/1,2](#totp12) |
| `digest_method`   | atom        | from [hotp/2,3](#hotp23) |
| `interval_length` | integer > 0 | from [totp/1,2](#totp12) |
| `timestamp`       | timestamp   | from [totp/1,2](#totp12) |
| `token_length`    | integer > 0 | from [hotp/2,3](#hotp23) |
| `window`          | integer > 0 | 0                        |

- `window` is a range used for expanding `Interval` value derived from the `timestamp`. This is done by considering the `window` `Interval`s before *and* after the one derived from the `timestamp`. This allows validation to be relaxed to allow for successful validation of TOTP `Token`s generated by clients with some degree of unknown clock drift from the server, as well as some client entry delay. 

## Examples (Erlang)

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

Alternatively, to get the last interval from a validated token:

```erlang
Secret = <<"MFRGGZDFMZTWQ2LK">>,
Token = <<"123456">>,
LastUsed = 5,  % last successful trial
Options = [{last, LastUsed}, {return_interval, true}],
NewLastUsed = case pot:valid_hotp(Token, Secret, Options) of
                  {true, LastInterval} -> LastInterval;
                  false -> LastUsed
              end,
% Do something
```

### Create a time based token with 30 seconds ahead

```erlang
Secret = <<"MFRGGZDFMZTWQ2LK">>,
Token = pot:totp(Secret, [{addwindow, 1}]),
% Do something
```

### Check a time based token from a mobile device with 30 seconds ahead and a ±1 interval tolerance

```erlang
Secret = <<"MFRGGZDFMZTWQ2LK">>,
Token = <<"123456">>,
IsValid = pot:valid_totp(Token, Secret, [{window, 1}, {addwindow, 1}]),
% Do something
```

### Create a time based token for given time

Time format is `{MegaSecs, Secs, MicroSecs}` received by os:timestamp()

```erlang
Secret = <<"MFRGGZDFMZTWQ2LK">>,
Token = pot:totp(Secret, [{timestamp, {1518, 179058, 919315}}]),
% Token will be <<"151469">>
```

## Examples (Elixir)

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

Alternatively, to get the last interval from a validated token:

```elixir
secret = "MFRGGZDFMZTWQ2LK"
token = "123456"
last_used = 5  # last successful trial
options = [{:last, last_used}, {:return_token, true}]
new_last_used =
    case :pot.valid_hotp(token, secret, options) do
        {true, last_interval} -> last_interval
        false -> last_used
    end
# Do something
```


### Create a time based token with 30 seconds ahead

```elixir
secret = "MFRGGZDFMZTWQ2LK"
token = :pot.totp(secret, [addwindow: 1])
# Do something
```

### Check a time based token from a mobile device with 30 seconds ahead and a ±1 interval tolerance

```elixir
secret = "MFRGGZDFMZTWQ2LK"
token = "123456"
is_valid = :pot.valid_totp(token, secret, [window: 1, addwindow: 1])
# Do something
```

### Create a time based token for given time

Time format is `{MegaSecs, Secs, MicroSecs}` received by :os.timestamp()

```elixir
secret = "MFRGGZDFMZTWQ2LK"
token = :pot.totp(secret, [timestamp: {1518, 179058, 919315}])
# Token will be <<"151469">>
```

## Credits

- Yuce Tekol
- Tomasz Jaskowski: [OneTimePass](https://github.com/tadeck/onetimepass) Python library
- Andrew Tunnell-Jones: [base32_erlang](https://github.com/aetrion/base32_erlang) library

Thanks to [contributors](CONTRIBUTORS).

## License

Copyright (c) 2014-2019 Yüce Tekol

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

[onetimepass]: https://github.com/tadeck/onetimepass
[erlang]: http://www.erlang.org
[elixir]: http://elixir-lang.org
[rfc4226]: https://tools.ietf.org/html/rfc4226
[rfc6238]: https://tools.ietf.org/html/rfc6238
[rebar3]: https://github.com/erlang/rebar3
[google_auth_wiki]: http://en.wikipedia.org/wiki/Google_Authenticator
[hotp_wiki]: http://en.wikipedia.org/wiki/HMAC-based_One-time_Password_Algorithm
[totp_wiki]: http://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm
[crypto_hmac]: http://erlang.org/doc/man/crypto.html#hmac-3
[ts]: http://erlang.org/doc/man/os.html#timestamp-0
