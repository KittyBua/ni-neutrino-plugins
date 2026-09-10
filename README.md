# NI \o/ - Neutrino-Plugins

Tuxbox-Plugins were added with

```
#!bash
for plugin in cooliTSclimax getrc input logomask logoview msgbox scripts-lua shellexec sysinfo tuxcal tuxcom tuxmail tuxwetter; do
	git subtree add --prefix=$plugin https://github.com/tuxbox-neutrino/plugin-$plugin.git master
done
git subtree add --prefix=scripts-lua/mediathek https://github.com/tuxbox-neutrino/plugin-lua-neutrino-mediathek.git master
git subtree add --prefix=scripts-lua/logoupdater https://github.com/tuxbox-neutrino/plugin-lua-logoupdater.git master
git subtree add --prefix=scripts-lua/stb-startup https://github.com/tuxbox-neutrino/plugin-lua-stb-startup.git master
```
