/*
 * Tuxwetter-Neutrino: Rendering Implementation
 * Phase 1: Static test screen
 */

#include "tw_render.h"
#include <driver/framebuffer.h>
#include <cstdio>

void tw_render_test_screen(TuxwetterState *state)
{
	if (!state || !state->framebuffer) {
		printf("[tw_render] No framebuffer available\n");
		tw_log("[tw_render] No framebuffer available");
		return;
	}

	CFrameBuffer *fb = state->framebuffer;
	const int w = state->screen_width > 0 ? state->screen_width : fb->getScreenWidth(true);
	const int h = state->screen_height > 0 ? state->screen_height : fb->getScreenHeight(true);

	const int header_h = 60;
	const int footer_h = 36;
	const int margin   = 20;

	// Background
	fb->paintBoxRel(0, 0, w, h, TuxwetterColors::DARK_BLUE);

	// Header + footer bars
	fb->paintBoxRel(0, 0, w, header_h, TuxwetterColors::ROYAL_BLUE);
	fb->paintBoxRel(0, h - footer_h, w, footer_h, TuxwetterColors::DIM_GRAY);

	// Content placeholder box
	const int body_y = header_h + margin;
	const int body_h = h - header_h - footer_h - 2 * margin;
	fb->paintBoxRel(margin, body_y, w - 2 * margin, body_h, TuxwetterColors::GRAY);

	// Simple crosshair to make sure something is visible
	const int cx = w / 2;
	const int cy = body_y + body_h / 2;
	const int cross = 60;
	fb->paintBoxRel(cx - 2, cy - cross, 4, 2 * cross, TuxwetterColors::ROYAL_BLUE);
	fb->paintBoxRel(cx - cross, cy - 2, 2 * cross, 4, TuxwetterColors::ROYAL_BLUE);

	fb->blit();

	printf("[tw_render] Test screen drawn (%dx%d)\n", w, h);
	tw_log("[tw_render] Test screen drawn %dx%d", w, h);
}
