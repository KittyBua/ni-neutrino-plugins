/*
 * Tuxwetter-Neutrino: Input Handling
 * Phase 1: Basic navigation and exit
 */

#ifndef TW_INPUT_H
#define TW_INPUT_H

#include "tw_types.h"

// Process input events (blocks until exit requested)
// Returns 0 on normal exit, non-zero on error
int tw_input_loop(TuxwetterState *state);

#endif // TW_INPUT_H
