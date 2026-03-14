PREFIX    ?= /usr
DESTDIR   ?=
INSTALL_BASE := $(DESTDIR)$(PREFIX)/share/neutrino/plugins/lua
PLUGIN_DIR := $(INSTALL_BASE)/logoupdater
SOURCE_DIR := $(CURDIR)/plugin

.PHONY: install install-local uninstall clean

install:
	@mkdir -p $(PLUGIN_DIR)
	@cp -a $(SOURCE_DIR)/* $(PLUGIN_DIR)/

install-local:
	@$(MAKE) install DESTDIR=$(CURDIR)/dist PREFIX=/usr

uninstall:
	@rm -rf $(PLUGIN_DIR)

clean:
	@rm -rf $(CURDIR)/dist
