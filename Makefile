REBAR = ./rebar

.PHONY: all deps compile clean test dialyze

all: deps compile

deps:
	$(REBAR) get-deps

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean
	rm -f erl_crash.dump

test:
	$(REBAR) skip_deps=true eunit

dialyze:
	dialyzer -r src deps/base32/src --src
