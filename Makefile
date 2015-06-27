.PHONY: all clean distclean

NODE_DIR := node_modules
DEPS := $(NODE_DIR)

NPM_BIN := $(shell npm bin)
COFFEE_CC := $(NPM_BIN)/coffee
BABEL_CC := $(NPM_BIN)/babel

BIN := test-full.js

all: test-full.js

%-full.js: %.js
	$(BABEL_CC) --optional runtime $< > $@

%.js: %.coffee $(DEPS)
	$(COFFEE_CC) -bc --no-header $<

clean:
	@rm -f $(wildcard *.js)

distclean: clean
	@rm -rf $(DEPS)
