REBAR = ./rebar

.PHONY: all deps compile clean test

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
