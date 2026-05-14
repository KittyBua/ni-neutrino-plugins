# plugin-lua-logoupdater

Standalone Neutrino Lua plugin for channel logo updates.

## What This Plugin Does

- Downloads the current logo bundle from `neutrino-images/ni-logo-stuff`.
- Installs channel logos into the logo directory configured in Neutrino.
- Optionally installs event logos and popup logos.
- Builds channel-logo links using the upstream linker script/database.

## Repository Layout

- `plugin/logoupdater.lua`
- `plugin/logoupdater.cfg`
- `plugin/logoupdater.png`
- `metadata.json`
- `LICENSE`

## Runtime Requirements

- Neutrino Lua runtime with `filehelpers` and `configfile` APIs.
- Lua module: `luaposix` (used for `posix.glob`).
- External tools: `curl`, `rsync`, `unzip`.
- Optional: `git` (only used when `use_git=1` in plugin settings).

Configuration file:

- Path: `/var/tuxbox/config/logoupdater.cfg`
- Keys: `eventlogos`, `popuplogos`, `use_git`, `keep_files`
- Internal bookkeeping (do not edit): `last_logodir`

Destination logo directory:

- Read from `neutrino.conf` key `logo_hdd_dir` on every plugin launch.
  A path change in Neutrino takes effect the next time the plugin is
  opened, provided Neutrino has persisted the setting (save Neutrino
  settings or exit/restart Neutrino to flush).
- Fallback: `/share/tuxbox/neutrino/icons`.
- When the path changes between runs, the plugin moves image files
  (`*.png`, `*.jpg`, `*.jpeg`, `*.gif`) and their symlinks from the
  previous location into the new one so the old storage isn't wasted.
  Symlinks pointing to absolute paths inside the old directory may end
  up broken; if any logos appear missing after a path change, run the
  in-plugin update to regenerate the per-channel mapping.

## Build And Install

Default install (real root or staging via `DESTDIR`):

```bash
make install
```

Package/staging install example:

```bash
make install DESTDIR=/tmp/pkgroot PREFIX=/usr/share/tuxbox/neutrino PLUGIN_SUBDIR=plugins
```

Quick local test tree:

```bash
make install-local
```

OpenEmbedded recipe-style install:

```bash
oe_runmake \
  DESTDIR=${D} \
  PREFIX=${N_PREFIX}${N_DATADIR}/neutrino \
  PLUGIN_SUBDIR=$(basename ${N_PLUGIN_DIR}) \
  install
```

## Cleanup

```bash
make uninstall DESTDIR=/tmp/pkgroot PREFIX=/usr/share/tuxbox/neutrino PLUGIN_SUBDIR=plugins
make clean
```

## License

BSD-2-Clause
