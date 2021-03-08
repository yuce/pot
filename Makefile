REBAR = rebar3

.PHONY: all compile clean cover coveralls release test dialyze

all: compile

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean
	rm -f erl_crash.dump

cover: test
	$(REBAR) cover --verbose

coveralls: compile cover
	$(REBAR) as test coveralls send

release:
	rebar3 hex publish

test:
	$(REBAR) eunit

dialyze:
	$(REBAR) dialyzer
