# Makefile for a Neovim plugin.

# Variables
NVIM = nvim
TEST_DIR = ./test
PLUGINS_DIR = ./test/plenary
MODEL = gpt-4-1106-preview
-include .env

all: README.md test/.last

.PHONY: all test manual helptags continous helpdoc

# Test target
test: test/.last

test/.last: test/*.lua test/plenary/* lua/genie/* Makefile
	@$(NVIM) \
		--headless \
		-c "set rtp+=." \
		-c "runtime plugin/genie.vim" \
		-c "PlenaryBustedDirectory $(TEST_DIR)/ {minimal_init = '$(PLUGINS_DIR)/minimal_init.vim'}" \
		-c "qa!"
	@touch test/.last

continuous:
	@while true; do make -s; sleep 2; done

manual:
	@$(NVIM) \
		-c "set rtp+=." \
		-c "runtime plugin/genie.vim" \
		-c "PlenaryBustedDirectory $(TEST_DIR)/ {minimal_init = '$(PLUGINS_DIR)/minimal_init.vim'}"

# Generate help tags
helptags:
	@$(NVIM) \
		--headless \
		-c "helptags doc" \
		-c "qa!"

# Don't depenency check because we don't want to automate
helpdoc:
	@doc/gendoc.sh

README.md: doc/genie.txt Makefile
	@openai api chat.completions.create -m $(MODEL) -g user \
		"Convert this vim plugin help to direct *raw* markdown: `cat doc/genie.txt`" \
		> README.md

