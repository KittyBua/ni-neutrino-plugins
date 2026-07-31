/*
 * Tuxwetter-Neutrino: Rendering Functions
 * Phase 1: Static test screen with colored boxes
 */

#ifndef TW_RENDER_H
#define TW_RENDER_H

#include "tw_types.h"

// Render the main test screen (Phase 1: colored boxes)
void tw_render_test_screen(TuxwetterState *state);

// Future rendering functions for Phase 2:
// void tw_render_weather_screen(TuxwetterState *state, WeatherData *data);
// void tw_render_detail_screen(TuxwetterState *state, DayData *day);
// void tw_render_settings_screen(TuxwetterState *state);

#endif // TW_RENDER_H
