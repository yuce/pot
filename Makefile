REBAR = rebar3

.PHONY: all compil0e clean cover test dialyze

all: deps compile

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean
	rm -f erl_crash.dump

cover:
	$(REBAR) cover --verbose

test:
	$(REBAR) eunit

dialyze:
	$(REBAR) dialyzer
