# Portable build + install for the tuxwetter Neutrino plugin.
#
# This Makefile is the single source of build truth for this plugin: the
# generic PC builder and the OE recipe both call `all` + `install` and pass
# the toolchain vars and destination knobs below. No build logic lives
# outside this file.
#
# It produces a real dlopen-able .so against the Neutrino API (tw_*.cpp),
# wrapping the legacy tuxwetter core (tuxwetter.c and friends) whose main()
# is renamed to tuxwetter_entry.
#
# Makefile.am / build.sh are the retired autotools + exec-model build and are
# kept for reference only; they are not the build path.

PLUGIN_NAME ?= tuxwetter-neutrino

# --- GNU install-style knobs -------------------------------------------------
PROGRAM_PREFIX ?=
PROGRAM_SUFFIX ?=
PROGRAM_TRANSFORM_NAME ?= s,x,x,
PREFIX ?= /usr
DESTDIR ?=

INSTALL ?= install
MKDIR_P ?= mkdir -p

# --- Toolchain (overridable) -------------------------------------------------
CC ?= gcc
CXX ?= g++
PKG_CONFIG ?= pkg-config

# --- Neutrino integration ----------------------------------------------------
# Defaults assume this repo sits at <builder>/sources/plugin-tuxwetter.
NEUTRINO_SRC_DIR ?= ../../sources/neutrino
NEUTRINO_BUILD_DIR ?= ../../artifacts/build/neutrino
NEUTRINO_INSTALL_DIR ?= ../../artifacts/sysroot

PLUGIN_OUTPUT_NAME := $(PROGRAM_PREFIX)$(PLUGIN_NAME)$(PROGRAM_SUFFIX)
ifneq ($(strip $(PROGRAM_TRANSFORM_NAME)),)
PLUGIN_OUTPUT_NAME := $(shell printf '%s\n' "$(PLUGIN_OUTPUT_NAME)" | sed '$(PROGRAM_TRANSFORM_NAME)')
endif
PLUGIN_SO := $(PLUGIN_OUTPUT_NAME).so
PLUGIN_CFG := tuxwetter-neutrino.cfg
# legacy aliases for loaders expecting the old base name
PLUGIN_LEGACY_SO := tuxwetter.so
PLUGIN_LEGACY_BIN := tuxwetter
PLUGIN_SYMLINKS := $(PLUGIN_OUTPUT_NAME) $(PLUGIN_OUTPUT_NAME).so $(PLUGIN_LEGACY_SO) $(PLUGIN_LEGACY_BIN)

PLUGIN_LIB_DIR ?= $(DESTDIR)$(PREFIX)/lib/tuxbox/neutrino/plugins
PLUGIN_SHARE_DIR ?= $(DESTDIR)$(PREFIX)/share/tuxbox/neutrino/plugins
PLUGIN_CONFIG_DIR ?= $(DESTDIR)$(PREFIX)/var/tuxbox/config
PLUGIN_VAR_DIR ?= $(DESTDIR)$(PREFIX)/var/tuxbox/plugins
PLUGIN_LEGACY_DIR ?= $(DESTDIR)$(PREFIX)/var/tuxbox/plugins

# --- Compiler flags ----------------------------------------------------------
CXXFLAGS += -std=gnu++11 -fPIC -Wall -Wextra
# Neutrino's own config.h must win over the fallback shipped here: on a real
# box it carries the correct HAVE_* / hardware settings. The local config.h is
# only a fallback for a standalone build without a configured Neutrino tree.
CXXFLAGS += -I$(NEUTRINO_BUILD_DIR)
CXXFLAGS += -I.
CXXFLAGS += -I$(NEUTRINO_SRC_DIR)/src
CXXFLAGS += -I$(NEUTRINO_SRC_DIR)/src/zapit/include
CXXFLAGS += -I$(NEUTRINO_SRC_DIR)/lib
CXXFLAGS += -I$(NEUTRINO_INSTALL_DIR)$(PREFIX)/include

# pkg-config for dependencies (respects PKG_CONFIG_SYSROOT_DIR)
CXXFLAGS += $(shell PKG_CONFIG_SYSROOT_DIR=$(NEUTRINO_INSTALL_DIR) $(PKG_CONFIG) --cflags freetype2 2>/dev/null || $(PKG_CONFIG) --cflags freetype2 2>/dev/null)
CXXFLAGS += $(shell PKG_CONFIG_SYSROOT_DIR=$(NEUTRINO_INSTALL_DIR) $(PKG_CONFIG) --cflags sigc++-2.0 2>/dev/null || $(PKG_CONFIG) --cflags sigc++-2.0 2>/dev/null)
# host fallbacks (useful for native dev builds without staged sigc++)
CXXFLAGS += -I/usr/include/sigc++-2.0 -I/usr/lib/x86_64-linux-gnu/sigc++-2.0/include

# --- Link flags for the .so (split so libs come after the objects) -----------
SO_LDFLAGS_PRE := -shared -Wl,-soname,$(PLUGIN_SO)
# export only the plugin symbols
SO_LDFLAGS_PRE += -Wl,--version-script=$(CURDIR)/tuxwetter.map
SO_LDFLAGS_POST = $(LDFLAGS) \
	-L$(NEUTRINO_INSTALL_DIR)$(PREFIX)/lib \
	$(shell PKG_CONFIG_SYSROOT_DIR=$(NEUTRINO_INSTALL_DIR) $(PKG_CONFIG) --libs freetype2 2>/dev/null || $(PKG_CONFIG) --libs freetype2 2>/dev/null) \
	$(shell PKG_CONFIG_SYSROOT_DIR=$(NEUTRINO_INSTALL_DIR) $(PKG_CONFIG) --libs sigc++-2.0 2>/dev/null || $(PKG_CONFIG) --libs sigc++-2.0 2>/dev/null || echo '-lsigc-2.0') \
	$(TW_LIBS) \
	-Wl,-rpath,'$$ORIGIN/../../lib:$(NEUTRINO_INSTALL_DIR)$(PREFIX)/lib'

# --- Sources -----------------------------------------------------------------
# Neutrino-API layer
CORE_SOURCES = tw_render.cpp tw_input.cpp
PLUGIN_SOURCES = tw_plugin.cpp

# Legacy tuxwetter core, now local to this repo
TW_SRC_DIR := $(CURDIR)
TW_C_SOURCES := \
	fb_display.c \
	gfx.c \
	gif.c \
	gifdecomp.c \
	http.c \
	jpeg.c \
	parser.c \
	php.c \
	rc_device.c \
	resize.c \
	text.c \
	tuxwetter.c \
	io.c
TW_CPP_SOURCES := \
	pngw.cpp \
	png_helper.cpp

TW_C_OBJECTS := $(TW_C_SOURCES:.c=.o)
TW_CPP_OBJECTS := $(TW_CPP_SOURCES:.cpp=.o)
TW_OBJECTS := $(TW_C_OBJECTS) $(TW_CPP_OBJECTS)

# Config path for the legacy code (target absolute)
CONFIGDIR_VAL := $(if $(strip $(N_LOCALSTATEDIR)),$(N_LOCALSTATEDIR)/tuxbox/config,$(PREFIX)/var/tuxbox/config)
TW_CONFIG_DEF := -DCONFIGDIR=\"$(CONFIGDIR_VAL)\"

# Hardware mode must match Neutrino's own build: the generic PC build uses
# HAVE_GENERIC_HARDWARE=1 (skips the framebuffer-device display path). A box
# build passes 0 and the legacy path is compiled. Keep this in sync with the
# value in Neutrino's config.h, otherwise the macro is redefined.
HAVE_GENERIC_HARDWARE ?= 1
TW_HW_DEF := -DHAVE_GENERIC_HARDWARE=$(HAVE_GENERIC_HARDWARE)

TW_INCLUDES := -I$(NEUTRINO_BUILD_DIR) -I$(TW_SRC_DIR) -I$(NEUTRINO_SRC_DIR)/src \
	-I$(NEUTRINO_INSTALL_DIR)$(PREFIX)/include \
	-I$(NEUTRINO_INSTALL_DIR)$(PREFIX)/include/freetype2 \
	-I$(NEUTRINO_INSTALL_DIR)$(PREFIX)/include/libpng16 \
	-I/usr/include/freetype2

TW_CFLAGS := $(CFLAGS) -fPIC -Wall -Wextra -Wno-unused-parameter -Wno-format-nonliteral \
	$(TW_CONFIG_DEF) $(TW_HW_DEF) $(TW_INCLUDES)
TW_CPPFLAGS := $(CXXFLAGS) -fPIC -Wall -Wextra $(TW_CONFIG_DEF) $(TW_HW_DEF) $(TW_INCLUDES)

# Link libs: use sysroot libs (multiarch-aware)
MULTIARCH_TRIPLET := $(shell $(CC) -print-multiarch 2>/dev/null || echo '')
TW_LIBS := \
	-L$(NEUTRINO_INSTALL_DIR)$(PREFIX)/lib \
	$(if $(MULTIARCH_TRIPLET),-L$(NEUTRINO_INSTALL_DIR)$(PREFIX)/lib/$(MULTIARCH_TRIPLET)) \
	-lpng -ljpeg -lgif -lcurl -lz -lm

CORE_OBJECTS = $(CORE_SOURCES:.cpp=.o)
PLUGIN_OBJECTS = $(PLUGIN_SOURCES:.cpp=.o)

HEADERS = tw_types.h tw_render.h tw_input.h tw_plugin.h
TW_HEADERS := $(wildcard $(TW_SRC_DIR)/*.h)

.PHONY: all plugin install uninstall clean

all: plugin

plugin: $(PLUGIN_SO)

$(PLUGIN_SO): $(CORE_OBJECTS) $(PLUGIN_OBJECTS) $(TW_OBJECTS)
	@echo "[tuxwetter] Linking $@ (shared library)"
	$(CXX) $(SO_LDFLAGS_PRE) -o $@ \
		$(CORE_OBJECTS) $(PLUGIN_OBJECTS) $(TW_OBJECTS) \
		$(SO_LDFLAGS_POST)

# Neutrino-API layer (C++)
$(CORE_OBJECTS) $(PLUGIN_OBJECTS): %.o: %.cpp $(HEADERS)
	@echo "[tuxwetter] Compiling $<"
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Legacy core: main() is renamed so it can live inside the plugin
$(TW_C_OBJECTS): %.o: %.c $(TW_HEADERS)
	@echo "[tuxwetter] Compiling (C) $<"
	$(CC) $(TW_CFLAGS) -Dmain=tuxwetter_entry -c -o $@ $<

$(TW_CPP_OBJECTS): %.o: %.cpp $(TW_HEADERS)
	@echo "[tuxwetter] Compiling (C++) $<"
	$(CXX) $(TW_CPPFLAGS) -Dmain=tuxwetter_entry -c -o $@ $<

install: $(PLUGIN_SO)
	@echo "[tuxwetter] Installing plugin (.so + cfg) for Neutrino dlopen"
	@$(MKDIR_P) "$(PLUGIN_VAR_DIR)" "$(PLUGIN_LEGACY_DIR)" "$(PLUGIN_LIB_DIR)"
	@$(MKDIR_P) "$(PLUGIN_SHARE_DIR)" "$(PLUGIN_CONFIG_DIR)"
	@if [ -f metadata.json ]; then \
		$(INSTALL) -m 0644 metadata.json "$(PLUGIN_SHARE_DIR)/$(PLUGIN_OUTPUT_NAME).json"; \
	 fi
	@if [ -f "$(PLUGIN_CFG)" ]; then \
		$(INSTALL) -m 0644 "$(PLUGIN_CFG)" "$(PLUGIN_SHARE_DIR)/$(PLUGIN_CFG)"; \
		ln -sf "../../../share/tuxbox/neutrino/plugins/$(PLUGIN_CFG)" "$(PLUGIN_VAR_DIR)/$(PLUGIN_CFG)"; \
		ln -sf "../../../share/tuxbox/neutrino/plugins/$(PLUGIN_CFG)" "$(PLUGIN_LEGACY_DIR)/$(PLUGIN_CFG)"; \
	fi
	@echo "[tuxwetter] Installing shared library to share dir (for plugin scan)"
	@$(INSTALL) -m 0755 "$(PLUGIN_SO)" "$(PLUGIN_SHARE_DIR)/$(PLUGIN_SO)"
	@ln -sf "../../../share/tuxbox/neutrino/plugins/$(PLUGIN_SO)" "$(PLUGIN_VAR_DIR)/$(PLUGIN_SO)"
	@ln -sf "../../../share/tuxbox/neutrino/plugins/$(PLUGIN_SO)" "$(PLUGIN_LEGACY_DIR)/$(PLUGIN_SO)"
	@ln -sf "../../../share/tuxbox/neutrino/plugins/$(PLUGIN_SO)" "$(PLUGIN_VAR_DIR)/$(PLUGIN_OUTPUT_NAME)"
	@ln -sf "../../../share/tuxbox/neutrino/plugins/$(PLUGIN_SO)" "$(PLUGIN_LEGACY_DIR)/$(PLUGIN_OUTPUT_NAME)"
	@ln -sf "../../../share/tuxbox/neutrino/plugins/$(PLUGIN_SO)" "$(PLUGIN_VAR_DIR)/$(PLUGIN_LEGACY_SO)"
	@ln -sf "../../../share/tuxbox/neutrino/plugins/$(PLUGIN_SO)" "$(PLUGIN_LEGACY_DIR)/$(PLUGIN_LEGACY_SO)"
	@echo "[tuxwetter] Cleaning old wrappers/bin"
	@for stale in \
		"$(PLUGIN_VAR_DIR)/$(PLUGIN_OUTPUT_NAME)-bin" \
		"$(PLUGIN_VAR_DIR)/$(PLUGIN_OUTPUT_NAME).sh" \
		"$(PLUGIN_LEGACY_DIR)/$(PLUGIN_OUTPUT_NAME)-bin" \
		"$(PLUGIN_LEGACY_DIR)/$(PLUGIN_OUTPUT_NAME).sh" \
		"$(PLUGIN_VAR_DIR)/$(PLUGIN_LEGACY_BIN)" \
		"$(PLUGIN_LEGACY_DIR)/$(PLUGIN_LEGACY_BIN)"; do \
		if [ -L "$$stale" ] || [ -f "$$stale" ]; then rm -f "$$stale"; fi; \
	done
	@echo "[tuxwetter] Deploying legacy configs/assets"
	@dest_cfg="$(DESTDIR)$(PREFIX)/var/tuxbox/config/tuxwetter"; \
	dest_cfg_alt="$(DESTDIR)/var/tuxbox/config/tuxwetter"; \
	dest_share="$(PLUGIN_SHARE_DIR)/tuxwetter"; \
	$(MKDIR_P) "$$dest_cfg" "$$dest_cfg_alt" "$$dest_share"; \
	$(INSTALL) -m 0644 tuxwetter.cfg tuxwetter.conf tuxwetter.mcfg "$$dest_cfg/"; \
	$(INSTALL) -m 0644 tuxwetter.cfg tuxwetter.conf tuxwetter.mcfg "$$dest_cfg_alt/" || true; \
	$(INSTALL) -m 0644 tuxwetter.png tuxwetter_hint.png startbild.jpg "$$dest_share/"; \
	if [ -f convert.list ]; then $(INSTALL) -m 0644 convert.list "$$dest_cfg/"; fi; \
	if [ -f convert.list ]; then $(INSTALL) -m 0644 convert.list "$$dest_cfg_alt/" || true; fi; \
	if [ -d icons ]; then $(MKDIR_P) "$$dest_share/icons"; cp -a icons/. "$$dest_share/icons/"; fi; \
	if [ -d translator ]; then $(MKDIR_P) "$$dest_share/translator"; cp -a translator/. "$$dest_share/translator/"; fi

uninstall:
	@echo "[tuxwetter] Uninstalling"
	@rm -f "$(PLUGIN_LIB_DIR)/$(PLUGIN_SO)"
	@rm -f "$(PLUGIN_SHARE_DIR)/$(PLUGIN_SO)"
	@rm -f "$(PLUGIN_VAR_DIR)/$(PLUGIN_SO)" "$(PLUGIN_LEGACY_DIR)/$(PLUGIN_SO)"
	@for link in $(PLUGIN_SYMLINKS); do \
		rm -f "$(PLUGIN_VAR_DIR)/$$link" "$(PLUGIN_LEGACY_DIR)/$$link"; \
	done
	@rm -f "$(PLUGIN_SHARE_DIR)/$(PLUGIN_OUTPUT_NAME).json"
	@rm -f "$(PLUGIN_SHARE_DIR)/$(PLUGIN_CFG)" "$(PLUGIN_VAR_DIR)/$(PLUGIN_CFG)" "$(PLUGIN_LEGACY_DIR)/$(PLUGIN_CFG)"

clean:
	@echo "[tuxwetter] Cleaning build artifacts"
	@rm -f $(CORE_OBJECTS) $(PLUGIN_OBJECTS) $(TW_OBJECTS) $(PLUGIN_SO)
