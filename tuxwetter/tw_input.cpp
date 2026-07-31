/*
 * Tuxwetter-Neutrino: Input Handling Implementation
 * Phase 1: Basic key events
 */

#include "tw_input.h"
#include <cstdio>
#include <driver/rcinput.h>

int tw_input_loop(TuxwetterState *state)
{
	if (!state || !state->rcinput)
		return -1;

	CRCInput *rcInput = state->rcinput;
	neutrino_msg_t msg;
	neutrino_msg_data_t data;

	printf("[tw_input] Waiting for user input (HOME/EXIT to quit)...\n");
	tw_log("[tw_input] loop start");

	while (state->running) {
		// Timeout: 100ms for responsive UI
		uint64_t timeout = rcInput->calcTimeoutEnd(100);
		rcInput->getMsgAbsoluteTimeout(&msg, &data, &timeout);

		if (msg == 0) {
			// nothing received
			continue;
		}

		// Handle keys
		if (msg == CRCInput::RC_home || msg == CRCInput::RC_setup) {
			printf("[tw_input] Exit requested (RC_home)\n");
			tw_log("[tw_input] Exit requested RC_home/setup");
			state->running = false;
			return 0;
		}
		else if (msg == CRCInput::RC_up) {
			printf("[tw_input] UP pressed\n");
			tw_log("[tw_input] UP");
			// TODO Phase 2: Navigate to previous screen/item
		}
		else if (msg == CRCInput::RC_down) {
			printf("[tw_input] DOWN pressed\n");
			tw_log("[tw_input] DOWN");
			// TODO Phase 2: Navigate to next screen/item
		}
		else if (msg == CRCInput::RC_left) {
			printf("[tw_input] LEFT pressed\n");
			tw_log("[tw_input] LEFT");
			// TODO Phase 2: Navigate to previous day
		}
		else if (msg == CRCInput::RC_right) {
			printf("[tw_input] RIGHT pressed\n");
			tw_log("[tw_input] RIGHT");
			// TODO Phase 2: Navigate to next day
		}
		else if (msg == CRCInput::RC_ok) {
			printf("[tw_input] OK pressed\n");
			tw_log("[tw_input] OK");
			// TODO Phase 2: Select item / show details
		}
		else if (msg == CRCInput::RC_timeout) {
			// Normal: no input within timeout
			// TODO Phase 2: Check for weather data updates
		}
		else if (msg != 0) {
			printf("[tw_input] Unknown key: %lu\n", (unsigned long)msg);
			tw_log("[tw_input] Unknown key: %lu", (unsigned long)msg);
		}
	}

	return 0;
}
