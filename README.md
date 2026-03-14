# plugin-lua-logoupdater

Standalone Neutrino Lua plugin for channel logo updates (`logoupdater`).

## Contents

- `plugin/logoupdater.lua`
- `plugin/logoupdater.cfg`
- `plugin/logoupdater.png`
- `LICENSE`

## Install

```bash
make install DESTDIR=/tmp/pkgroot PREFIX=/usr
```

This installs files to:
`/tmp/pkgroot/usr/share/neutrino/plugins/lua/logoupdater`

For a quick local test tree:

```bash
make install-local
```
