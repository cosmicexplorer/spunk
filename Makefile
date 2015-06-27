.PHONY: all clean distclean
.DELETE_ON_ERROR:

NODE_DIR := node_modules
DEPS := $(NODE_DIR)

NPM_BIN := $(shell npm bin)
COFFEE_CC := $(NPM_BIN)/coffee
BABEL_CC := $(NPM_BIN)/babel

BIN := parser-generator.js

all: $(BIN)

# use -compiled suffix for temporary files since we're compiling these twice,
# once from coffee->es6 and then es6->es5 with babel
%.js: %-compiled.js
	$(BABEL_CC) --optional runtime $< > $@

%-compiled.js: %.coffee $(DEPS)
	$(COFFEE_CC) -bcp --no-header $< > $@

$(DEPS):
	@echo "prep: install dependencies"
	@npm install

clean:
	@rm -f $(wildcard *.js)

distclean: clean
	@rm -rf $(DEPS)
