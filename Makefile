.PHONY: all clean distclean
.DELETE_ON_ERROR:

NODE_DIR := node_modules
DEPS := $(NODE_DIR)

NPM_BIN := $(shell npm bin)
COFFEE_CC := $(NPM_BIN)/coffee

BIN := parser-generator.js

all: $(BIN)

%.js: %.coffee $(DEPS)
	@echo "coffee-compile: [$<]->$@"
	$(COFFEE_CC) -bcp --no-header $< > $@

$(DEPS):
	@echo "prep: install dependencies"
	@npm install

clean:
	@rm -f $(wildcard *.js)

distclean: clean
	@rm -rf $(DEPS)
