/*
 * Tuxwetter-Neutrino: Plugin API Implementation
 * Makes the plugin loadable as .so by Neutrino
 */

#include "tw_plugin.h"
#include "tw_types.h"
#include "tw_render.h"
#include "tw_input.h"

#include <cstdio>
#include <cstdarg>
#include <cstdlib>
#include <ctime>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include <driver/framebuffer.h>
#include <driver/rcinput.h>

// Legacy tuxwetter main (we alias original main to this symbol)
extern "C" int tuxwetter_entry(int argc, char **argv);

extern CRCInput *g_RCInput;

// Log to tmp so we always have a writable path
#define TW_LOG_PATH "/tmp/tuxwetter-neutrino.log"

#ifndef CONFIGDIR
#define CONFIGDIR "/usr/var/tuxbox/config"
#endif
static const char *tw_configdir_macro = CONFIGDIR;

// Global state (persistent across plugin invocations)
static TuxwetterState g_state;
static bool g_initialized = false;
static FILE *g_log_fp = nullptr;
static int g_log_enabled = -1;

static void tw_raw_log(const char *msg)
{
	int fd = ::open(TW_LOG_PATH, O_WRONLY | O_CREAT | O_APPEND, 0644);
	if (fd >= 0) {
		::write(fd, msg, std::strlen(msg));
		::write(fd, "\n", 1);
		::close(fd);
	}
}

// Constructor/Destructor to see dlopen activity
__attribute__((constructor))
static void tw_ctor(void)
{
	tw_raw_log("ctor: tuxwetter-neutrino loaded");
}

__attribute__((destructor))
static void tw_dtor(void)
{
	tw_raw_log("dtor: tuxwetter-neutrino unloaded");
}

void tw_log(const char *fmt, ...)
{
	if (g_log_enabled == 0)
		return;
	if (g_log_enabled < 0) {
		const char *env = std::getenv("TUXWETTER_LOG");
		g_log_enabled = (env && !std::strcmp(env, "0")) ? 0 : 1;
	}
	if (g_log_enabled == 0)
		return;
	if (!g_log_fp) {
		g_log_fp = std::fopen(TW_LOG_PATH, "a");
		if (!g_log_fp) {
			g_log_enabled = 0;
			std::fprintf(stderr, "[tuxwetter-neutrino] log open failed: %s\n", TW_LOG_PATH);
			return;
		}
		std::setvbuf(g_log_fp, nullptr, _IOLBF, 0);
	}

	std::time_t now = std::time(nullptr);
	char tbuf[32];
	std::strftime(tbuf, sizeof(tbuf), "%Y-%m-%d %H:%M:%S", std::localtime(&now));

	std::fprintf(g_log_fp, "[%s] ", tbuf);
	va_list ap;
	va_start(ap, fmt);
	std::vfprintf(g_log_fp, fmt, ap);
	va_end(ap);
	std::fputc('\n', g_log_fp);
	std::fflush(g_log_fp);
}

static bool tw_plugin_init_internal()
{
	if (g_initialized)
		return true;

	printf("[tuxwetter-plugin] Initializing...\n");
	std::fflush(stdout);
	tw_log("plugin_init_internal");
	g_state.framebuffer = CFrameBuffer::getInstance();
	g_state.rcinput = g_RCInput;
	if (!g_state.framebuffer) {
		tw_log("failed to acquire framebuffer");
		return false;
	}
	if (!g_state.rcinput) {
		tw_log("failed to acquire rcinput");
		return false;
	}
	g_state.screen_width = g_state.framebuffer->getScreenWidth(true);
	g_state.screen_height = g_state.framebuffer->getScreenHeight(true);

	g_state.running = true;
	g_initialized = true;

	printf("[tuxwetter-plugin] Initialization complete\n");
	std::fflush(stdout);
	tw_log("init complete");
	return true;
}

static void tw_plugin_cleanup_internal()
{
	if (!g_initialized)
		return;

	printf("[tuxwetter-plugin] Cleaning up...\n");
	tw_log("cleanup");

	if (g_state.rcinput) {
		g_state.rcinput = nullptr;
	}

	// CFrameBuffer is a singleton, don't delete
	g_state.framebuffer = nullptr;

	g_initialized = false;
}

// Neutrino Plugin API implementation

extern "C" void plugin_init(void)
{
	printf("[tuxwetter-plugin] plugin_init() called\n");
	tw_log("plugin_init()");
	// Initialization happens in plugin_exec() for now
}

extern "C" void plugin_exec(void)
{
	tw_raw_log("plugin_exec entry");
	fprintf(stderr, "[tuxwetter-plugin] plugin_exec entry\n");
	std::fflush(stderr);
	tw_log("plugin_exec()");
	tw_log("CONFIGDIR macro=%s", tw_configdir_macro);

	// Call legacy tuxwetter main (aliased via -Dmain=tuxwetter_entry)
	char prog[] = "tuxwetter-neutrino";
	char *argv[] = { prog, nullptr };
	int ret = tuxwetter_entry(1, argv);

	printf("[tuxwetter-plugin] plugin_exec() finished (code %d)\n", ret);
	tw_log("plugin_exec finished ret=%d", ret);
}

extern "C" void plugin_del(void)
{
	printf("[tuxwetter-plugin] plugin_del() called\n");
	tw_log("plugin_del()");
	tw_plugin_cleanup_internal();

	if (g_log_fp) {
		std::fflush(g_log_fp);
		std::fclose(g_log_fp);
		g_log_fp = nullptr;
	}
}
