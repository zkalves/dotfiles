# Front door for the dotfiles repo. Run `make` for the target list.

.DEFAULT_GOAL := help

DOTFILES_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

include $(DOTFILES_DIR)/libs.mk

.PHONY: help install links plugins

help:
	@echo "dotfiles targets:"
	@echo "  install      symlink dotfiles into \$$HOME, then install tmux plugins"
	@echo "  links        symlink home/ and seed skel/ files that are missing"
	@echo "  plugins      install tmux plugins only"
	@echo "  libs         build every tool into $(PREFIX)"
	@echo "  <tool>       build one of: $(LIBS)"
	@echo "  libs-clean   drop build stamps so 'make libs' rebuilds"

install:
	bash $(DOTFILES_DIR)/install.sh all

links:
	bash $(DOTFILES_DIR)/install.sh links

plugins:
	bash $(DOTFILES_DIR)/install.sh plugins
