/*
 * Tuxwetter-Neutrino: Common Types and Definitions
 * Phase 1: PoC
 */

#ifndef TW_TYPES_H
#define TW_TYPES_H

#include <cstdint>

// Forward declarations
class CFrameBuffer;
class CRCInput;

// Pixel type (defined in Neutrino's fb_generic.h, but repeated here for clarity)
#ifndef fb_pixel_t
typedef uint32_t fb_pixel_t;
#endif

// Color constants (ARGB format)
namespace TuxwetterColors {
	const fb_pixel_t DARK_BLUE    = 0xFF001F3F; // Background
	const fb_pixel_t ROYAL_BLUE   = 0xFF4169E1; // Title bar
	const fb_pixel_t GRAY         = 0xFF808080; // Info box
	const fb_pixel_t DIM_GRAY     = 0xFF696969; // Footer
	const fb_pixel_t WHITE        = 0xFFFFFFFF; // Text (future)
	const fb_pixel_t BLACK        = 0xFF000000; // Borders (future)
}

// Simple logging helper (implemented in tw_plugin.cpp)
void tw_log(const char *fmt, ...);

// Application state
struct TuxwetterState {
	CFrameBuffer *framebuffer;
	CRCInput *rcinput;
	bool running;
	int screen_width;
	int screen_height;

	TuxwetterState()
		: framebuffer(nullptr)
		, rcinput(nullptr)
		, running(true)
		, screen_width(0)
		, screen_height(0)
	{}
};

#endif // TW_TYPES_H
