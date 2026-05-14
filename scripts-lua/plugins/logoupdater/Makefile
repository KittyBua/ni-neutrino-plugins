PREFIX         ?= /usr/share/tuxbox/neutrino
PLUGIN_SUBDIR  ?= plugins
INSTALLDIR     ?= $(PREFIX)/$(PLUGIN_SUBDIR)
DESTDIR        ?=

PROGRAM_PREFIX ?=
PROGRAM_SUFFIX ?=
PROGRAM_TRANSFORM_NAME ?=

PLUGIN_NAME    ?= logoupdater
SOURCE_DIR     ?= $(CURDIR)/plugin

INSTALL ?= install
SED     ?= sed
RM      ?= rm -f
RMR     ?= rm -rf
MKDIR   ?= install -d

.PHONY: install install-local uninstall clean

define compute_names
name='$(PLUGIN_NAME)'; \
name="$(PROGRAM_PREFIX)$${name}$(PROGRAM_SUFFIX)"; \
if [ -n "$(PROGRAM_TRANSFORM_NAME)" ]; then \
	name=$$(printf '%s' "$$name" | sed '$(PROGRAM_TRANSFORM_NAME)'); \
fi; \
lua_dst="$$name.lua"; \
cfg_dst="$$name.cfg"; \
png_dst="$$name.png"
endef

install:
	@set -e; \
	$(call compute_names); \
	$(MKDIR) "$(DESTDIR)$(INSTALLDIR)"; \
	$(INSTALL) -m 0755 "$(SOURCE_DIR)/$(PLUGIN_NAME).lua" "$(DESTDIR)$(INSTALLDIR)/$$lua_dst"; \
	$(INSTALL) -m 0644 "$(SOURCE_DIR)/$(PLUGIN_NAME).cfg" "$(DESTDIR)$(INSTALLDIR)/$$cfg_dst"; \
	$(INSTALL) -m 0644 "$(SOURCE_DIR)/$(PLUGIN_NAME).png" "$(DESTDIR)$(INSTALLDIR)/$$png_dst"

install-local:
	@$(MAKE) install DESTDIR=$(CURDIR)/dist PREFIX=/usr/share/tuxbox/neutrino PLUGIN_SUBDIR=plugins

uninstall:
	@set -e; \
	$(call compute_names); \
	$(RM) "$(DESTDIR)$(INSTALLDIR)/$$lua_dst"; \
	$(RM) "$(DESTDIR)$(INSTALLDIR)/$$cfg_dst"; \
	$(RM) "$(DESTDIR)$(INSTALLDIR)/$$png_dst"

clean:
	@$(RMR) "$(CURDIR)/dist"
