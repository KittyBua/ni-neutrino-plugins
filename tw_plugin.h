/*
 * Tuxwetter-Neutrino: Plugin API
 * Converts standalone binary to Neutrino .so plugin
 */

#ifndef TW_PLUGIN_H
#define TW_PLUGIN_H

// Neutrino plugin API
extern "C" {
	void plugin_exec(void);
	void plugin_init(void);
	void plugin_del(void);
}

#endif // TW_PLUGIN_H
