REBAR = rebar3

.PHONY: all compile clean test dialyze

all: deps compile

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean
	rm -f erl_crash.dump

test:
	$(REBAR) eunit

dialyze:
	dialyzer -r src deps/base32/src --src
