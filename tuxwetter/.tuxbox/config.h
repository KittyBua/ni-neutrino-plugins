/* Minimal config.h for tuxwetter-neutrino PoC build
 * This is a dummy config to allow building without full Neutrino build tree.
 * For production builds, use the config.h from Neutrino's build directory.
 */

#ifndef _CONFIG_H_
#define _CONFIG_H_

/* Package information */
#define PACKAGE "neutrino"
#define PACKAGE_NAME "neutrino"
#define PACKAGE_VERSION "git"
#define VERSION "git"

/* Common defines for generic PC build */
#define HAVE_CONFIG_H 1
#define HAVE_DLFCN_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_MEMORY_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_STRINGS_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_UNISTD_H 1

/* X11 support for PC build */
#define USE_OPENGL 1

#endif /* _CONFIG_H_ */
