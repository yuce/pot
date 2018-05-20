REBAR = rebar3

.PHONY: all compile clean cover coveralls test dialyze

all: deps compile

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean
	rm -f erl_crash.dump

cover: test
	$(REBAR) cover --verbose

coveralls: compile cover
	$(REBAR) coveralls send

test:
	$(REBAR) eunit

dialyze:
	$(REBAR) dialyzer
