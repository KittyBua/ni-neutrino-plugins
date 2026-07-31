# Tuxwetter-Neutrino: Neutrino-API Port (PoC)

## Übersicht

Dieses Plugin demonstriert die **Portierung von Tuxwetter** von direkten Framebuffer-Zugriffen auf die **Neutrino-API** (CFrameBuffer, g_RCInput, gPainter).

### Ziel

- **Plattformunabhängigkeit**: Läuft auf PC (Xvfb), Embedded, Raspberry Pi
- **Wartbarkeit**: Nutzt Neutrino-Abstraktionen statt Hardware-spezifischem Code
- **Integration**: Saubere Einbindung ins Neutrino-Ökosystem

## Status: Phase 1 - Proof of Concept

**Was funktioniert:**
- ✅ CFrameBuffer-Initialisierung
- ✅ Einfaches Rendering (paintBoxRel, paintBackgroundBoxRel)
- ✅ Input-Handling mit g_RCInput (Navigationstasten, Exit)
- ✅ Build-Integration in neutrino-make

**Was noch fehlt:**
- ⏳ Wettergrafiken-Rendering (blit2FB, image decoding)
- ⏳ Font-Rendering mit g_Font
- ⏳ HTTP-Downloads (libcurl Integration)
- ⏳ Config-Loading
- ⏳ Multi-Screen-Navigation

## Installation

### Via neutrino-make

```bash
# Plugin bauen
make tuxwetter-neutrino

# Runtime synchronisieren
make runtime-sync

# Testen
root/usr/bin/tuxwetter-poc
```

### Manuelle Build

```bash
cd plugins/tuxwetter-neutrino

# Build mit neutrino-make Umgebung
make NEUTRINO_SRC_DIR=../../sources/neutrino \
     NEUTRINO_INSTALL_DIR=../../artifacts/sysroot \
     PREFIX=/usr

# Installation
make install DESTDIR=../../artifacts/sysroot PREFIX=/usr
```

## Verwendung

```bash
# Direkter Start (benötigt X11 oder Framebuffer)
./tuxwetter-poc

# Mit Xvfb (für Headless-Testing)
xvfb-run -a ./tuxwetter-poc

# Navigation:
# - Pfeiltasten: UP/DOWN/LEFT/RIGHT (geloggt zu stdout)
# - HOME/EXIT: Beendet das Plugin
```

## Architektur

### CFrameBuffer-Nutzung

```cpp
CFrameBuffer *fb = CFrameBuffer::getInstance();
int width = fb->getScreenWidth();
int height = fb->getScreenHeight();

// Rendering
fb_pixel_t color = 0xFF001F3F; // ARGB
fb->paintBoxRel(x, y, width, height, color);
```

### g_RCInput-Nutzung

```cpp
neutrino_msg_t msg;
neutrino_msg_data_t data;
uint64_t timeout = g_RCInput->calcTimeoutEnd(100); // 100ms

g_RCInput->getMsgAbsoluteTimeout(&msg, &data, &timeout);

if (msg == CRCInput::RC_home) {
    // Exit
} else if (msg == CRCInput::RC_up) {
    // Navigate up
}
```

## Nächste Schritte (Phase 2-4)

### Phase 2: Core-Rendering (5-7 Tage)
- Portiere Wettergrafiken-Anzeige
- Image-Decoding → blit2FB
- Font-Rendering mit g_Font
- Navigation zwischen Screens

### Phase 3: Vollständigkeit (3-5 Tage)
- HTTP-Downloads für Wetterdaten
- Config-Loading (tuxwetter.conf)
- Alle Original-Features

### Phase 4: Polish & Testing (3-5 Tage)
- Memory-Leak-Fixes
- Performance-Optimierung
- Embedded-Tests auf echter Hardware

## Technische Details

### Dependencies

- **Neutrino**: CFrameBuffer, CRCInput, helpers
- **libfreetype2**: Font-Rendering (später mit g_Font)
- **libcurl**: HTTP-Downloads (Phase 3)
- **libpng/libjpeg/giflib**: Image-Decoding (Phase 2)

### Build-System-Integration

Registriert in:
- `make/plugins/plugin-tuxwetter-neutrino.mk` (4-Zeilen-Registrierung)
- `plugins/Makefile` (tuxwetter-neutrino-install Target)

### Vergleich: Alt vs. Neu

| **Aspekt** | **Alt (Original)** | **Neu (Neutrino-API)** |
|------------|-------------------|------------------------|
| Framebuffer | `open("/dev/fb0")`, `mmap()` | `CFrameBuffer::getInstance()` |
| Rendering | Direkter Memory-Zugriff | `paintBoxRel()`, `blit2FB()` |
| Input | `open("/dev/input/event1")` | `g_RCInput->getMsgAbsoluteTimeout()` |
| Keycodes | `#define KEY_UP 103` | `CRCInput::RC_up` |
| Plattform | Nur Embedded mit /dev/fb0 | PC, Embedded, RasPi |

## Bekannte Einschränkungen (PoC)

- Kein Text-Rendering (nur farbige Boxen)
- Kein echtes Wetter-Download
- Keine Grafiken (nur Platzhalter-Boxen)
- Keine Konfiguration

Diese Features werden in Phase 2-4 implementiert.

## Lizenz

GPL-2.0-or-later (wie Original-Tuxwetter)

## Autor

Portierung: Neutrino Development Team
Original: Tuxwetter Contributors (https://github.com/tuxbox-neutrino/plugin-tuxwetter)

## Referenzen

- Original-Tuxwetter: `plugins/tuxwetter/`
- Portierungsplan: `/tmp/tuxwetter_analysis.md`
- Plugin-HowTo: `docs/HOWTO_ADD_PLUGIN.de.md`
- Build-System: `docs/HOWTO_ADD_TARGET.de.md`
