# DW7 Recompiled

<!-- retcomm-readme-metrics -->
[![GitHub downloads (all assets, all releases)](https://img.shields.io/github/downloads/danyboy666/DW7-recomp/total)](https://github.com/danyboy666/DW7-recomp/releases)
[![GitHub downloads (latest release)](https://img.shields.io/github/downloads/danyboy666/DW7-recomp/latest/total)](https://github.com/danyboy666/DW7-recomp/releases/latest)
[![GitHub release](https://img.shields.io/github/v/release/danyboy666/DW7-recomp)](https://github.com/danyboy666/DW7-recomp/releases/latest)
<!-- /retcomm-readme-metrics -->

A native PC port of **Dragon Warrior VII** (PlayStation, 2001), built with
[psxrecomp](https://github.com/mstan/psxrecomp).

> The game's MIPS R3000A code is statically recompiled to C and compiled to
> native x64, then run against a PS1 hardware runtime on the bundled MIT
> OpenBIOS. This is **not an emulator** — the game runs as a native program.
> You must supply your own disc; no game data is included in this repository.

| | |
|---|---|
| Players | 1 |
| Region | USA |
| Publisher | Enix |
| Developer | Heart Beat / ArtePiazza / Bird Studio |
| Year | 2001 |
| Serial | SLUS-01206 (Disc 1 of 2) |

## Status

Boots and runs on **Linux** and **Windows** with the OpenGL, Vulkan or software
renderer:

- intro and title screens, and the main menu (**Continue / New Game /
  Delete File**) — menus render and accept input
- **New Game → name entry**

Under active bring-up: the opening field/story, battles, and remaining
game overlays. `main` tracks a stable, playable build; new work lands on
`dev` first.

## Requirements

- Your own **Dragon Warrior VII Disc 1** image (`.bin`/`.cue`, US release
  `SLUS-01206`).
- A BIOS is **not** required: the game runs on the bundled, MIT-licensed
  OpenBIOS. A retail PS1 BIOS may optionally be used if you have your own dump.

## Running

```bash
# Linux
build-release/DW7_Recompiled --game game.toml --disc /path/to/DW7.cue

# Windows (PowerShell)
build-release-win\DW7_Recompiled.exe --game game.toml --disc "C:\path\to\DW7.cue"
```

The disc path may also be set once in `game.toml` (`[runtime] disc = ...`).

## Repository layout

| Path | Purpose |
|---|---|
| `game.toml` | Game config: title, disc, renderer, paths |
| `generated/` | Recompiled game C (`SLUSP012.06_full_*.c`) — **committed** |
| `seeds/ghidra_funcs.txt` | Function seeds used by the recompiler |
| `psxrecomp/` | Framework submodule (recompiler, runtime, OpenBIOS) |
| `symbols.toml`, `psx_symbols.h` | Function symbol map (see *Symbols*) |
| `mods/`, `launcher_assets/` | Optional mods and box art |
| `build-release*/` | Local build output (gitignored) |

## Building from source

Requires `cmake`, `ninja`, a C/C++ toolchain, and Python 3 (Windows builds use
the bundled RetroPorting toolchain).

```bash
git submodule update --init --recursive

# 1. Regenerate the recompiled game C (see the maintenance note below first)
./psxrecomp/tools/ci/build_emitters.sh
python3 psxrecomp/psxrecomp_cli.py generate \
  --config game.toml --project-root . --disc disc/DW7.cue

# 2. Build the runtime + game
cmake -S . -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-release --target psx-runtime
```

Output: `build-release/DW7_Recompiled`. There are currently no CI workflows in
this repository; builds are produced locally.

## In-game menu

Press **F1** in-game (rebindable as `ShortcutMenu` in `config.ini [KeyMap]`) for
the shortcut menu (glass/purple theme). The game starts in **OPTIMAL** mode:
borderless fullscreen at the display's own resolution (Match display, so a 2K
screen renders 1440 internal lines), 4:3 original geometry, bilinear textures,
FXAA, mipmaps + 4x anisotropic filtering and bicubic FMVs. Everything is
persisted to `video.ini` next to the executable and re-applied at boot, and
`GAME → PERFORMANCE` remembers `tuning.ini`. The menu is organised into
categories:

- **GAME** — Quick Save / Quick Load (save-state slot 1), **Save States…** (the
  full slot browser), **Memory Cards…** (per-slot usage; **Format** and
  **Import/Export** of a 128 KB `.mcd` via a native file dialog), **Change
  Disc**, **Performance…**, and **Quit**.
- **GAME → PERFORMANCE** — **Fast Load** (host pacing off / 2x / 4x / 8x;
  safe: every guest frame and IRQ still runs), **CD Drive Speed**
  (1x authentic / 2x / 4x; deliver sectors sooner — raise gradually), and
  **Idle-Loop Skip** (verified same-PC interrupt-boundary skip). Saved to
  `tuning.ini` next to the executable; all default off/authentic.
- **VIDEO** — **Graphics Mode** (Optimal / Faithful), display ratio (4:3
  original / 16:9), upscaling (Native/720p/1080p/1440p/4K), dynamic
  resolution, fullscreen mode (windowed / borderless / exclusive), texture
  smoothing (Nearest / Bilinear / xBR), anti-aliasing (Off / FXAA / FXAA HQ),
  FMV filter + chroma smoothing, scanlines, dithering, bloom, mipmaps +
  anisotropic filtering, accurate blending, and **Restore Faithful Settings**.
  Every row is saved immediately; rows marked **(restart)** apply on the next
  launch: **Display Ratio**, **Upscaling** and the PERFORMANCE page's
  **Render Thread**. All other VIDEO rows (dynamic resolution, fullscreen,
  smoothing, AA, FMV, scanlines, dithering, bloom, mipmaps/aniso, accurate
  blending, graphics mode) apply live.

  **Optimal** is the default and is re-applicable: Match display, fullscreen
  borderless, 4:3, bilinear, FXAA, mipmaps + 4x aniso, bicubic FMV.
  **Faithful** restores the original look: native 240p, nearest, no AA/bloom/
  mipmaps/chroma, accurate blending on. **16:9** stretches the picture across
  the full screen (FMV and the game's own 24-bit menus included); DW7 has no
  widescreen rendering sites, so this is presentation-only and geometrically
  stretched — 4:3 is the undistorted choice.
- **CONTROLLER** — Player 1/2 **device** (Keyboard / a connected controller /
  none), pad mode (**Analog (DualShock)** by default, or Digital), and
  **remapping** of both the keyboard per PS1 button (persisted to
  `keybinds.ini`) and the gamepad per PS1 button (persisted to `input.ini`).

Navigate with arrows, confirm with Enter, back out with Esc; a controller's
D-pad + A/B also drive it. The menu pauses the game while open.

### Controller notes

- A connected game controller is detected automatically (shown by name in the
  menu); with none present the **keyboard is the default** input, and the
  runtime falls back to it automatically if a pad disconnects.
- Works with standard SDL controllers — **Xbox One/Series, PS4 (DualShock),
  PS5 (DualSense), Switch Pro/Joy-Con, Wii U Pro, Steam Controller/Deck** and
  more via SDL3's built-in mapping; an optional `gamecontrollerdb.txt` next to
  the executable extends it for any other pad.
- The emulated pad reports a **DualShock (analog, ID 0x73)** by default, so
  analog sticks work; per-player Digital mode is available in the menu.
- Keyboard and gamepad bindings are both remappable in-game (CONTROLLER →
  Remap P1 Keys / Remap P1 Pad Buttons) and stored in `keybinds.ini` /
  `input.ini`. The gamepad default is the classic PS1 (SDL-standard) layout;
  per-device maps are supported via `input.ini [mapping.<guid>]`.

### Multi-disc

Disc 1 and Disc 2 are both registered in `game.toml` (`discs` /
`disc_serials`), and the menu can mount either. **CHANGE DISC also records the
choice as the boot disc** (`settings.toml [disc] selected`), so the next launch
mounts that disc directly — needed for Disc-2 saves, which should be played by
booting on Disc 2 rather than swapping mid-session. Note that DW7 is an
*N-programs* title — Disc 2 boots its own executable (`SLUSP013.46`), so a
mid-game 1→2 swap still requires Disc 2 to be statically recompiled as a
second program (framework work, in progress upstream). Until then the menu
switches the mounted image but the game cannot continue onto Disc 2's program.

## Graphical enhancements

Off by default — enable what you want from the in-game **VIDEO** page (choices
persist to `settings.toml`). Highlights:

| Setting | Effect |
|---|---|
| Upscaling (Native…4K) | internal resolution (restart to apply) |
| Dynamic resolution | keeps 60 fps under load |
| Smoothing: xBR / Bilinear | 2D texture upscaling |
| Anti-aliasing: FXAA / FXAA HQ | post AA |
| FMV filter (bicubic) + chroma smoothing | cleaner FMVs |
| Mipmaps + anisotropic filtering | sharper receding 3D |
| Dithering / Bloom / Scanlines | taste / glow / CRT |

Further options (config-only today): PGXP (`perspective_texturing`,
`pgxp_depth_buffer`, `pgxp_color_correction`, `pgxp_seam = "fine"` — enable the
`psx.enhancement.pgxp` mod), HD texture packs (OpenGL), and
`internal_resolution = "8k"`.

## Enhanced FMVs (BYOD, local only)

The seven full-screen cinematics (title logo, the five intro parts, credits)
can be replaced with AI-upscaled, motion-interpolated video without touching
the game's timing: the guest keeps reading and decoding the original STR, and
only the *presented* frame is substituted, clocked by the guest's own MDEC
colour decodes. Audio stays on the untouched CD/XA → SPU path.

This repo ships the tooling and the stream manifest, **never the videos**
(they derive from game data):

```bash
# Tools: jpsxdec + ffmpeg (WSL) and realesrgan-ncnn-vulkan +
# rife-ncnn-vulkan (Windows GPU), pointed at by FMV_TOOLS.
tools/fmv_pipeline/pipeline.sh all
```

Output goes to `<exe-dir>/fmv/<name>.mp4` plus `manifest.json`. Without that
directory the runtime presents FMVs natively (bicubic + chroma smoothing) —
nothing changes. `PSX_EXTERNAL_FMV=0` disables the path for one run. The
replacement applies to both 24-bit and 15-bit movie frames so the picture never
alternates between enhanced and native.

#### ENHANCED FMV modes (F1 → VIDEO)

| Value | What it shows |
|---|---|
| `OFF` | The original disc video through the normal present path (bicubic + chroma smoothing). No external assets are used. |
| `NATIVE` (default) | The enhanced 2K video at the **original 15/20 fps cadence** — only the original frames of the 2× file are shown. |
| `SMOOTH` | The same enhanced 2K video at **30/40 fps**, including the RIFE-generated in-between frames. |

All three keep the guest's own movie timing and audio. `NATIVE` and `SMOOTH`
use the same assets, so resolution and sharpness are identical — the only
difference is **how often the picture changes**. That difference is visible on
motion (camera pans, the sailing ship, particles), not on static shots; the
title logo, for example, begins with several seconds of identical frames.

Measured on the generated `title.mp4`: in a moving segment the odd frames are
genuine interpolations (mean difference to the blend of their neighbours 0.23,
versus 0.64 to the previous frame), so `SMOOTH` really doubles the displayed
frame rate rather than duplicating frames. RIFE can shimmer or ghost on very
fast motion, which is why `NATIVE` is the default. The choice persists in
`video.ini` (`enhanced_fmv = 0/1/2`).

The 49 small 128x120 streams are battle/spell effects composited as overlays
into the framebuffer, not full-screen movies; they are deliberately excluded
(replacing them would need hardware composition at their on-screen rect).

Build flag: `-DPSX_EXTERNAL_FMV=ON` (Linux: libav*-dev; Windows: `-DFFMPEG_ROOT=`
an LGPL shared FFmpeg build). Off by default.

## Maintenance note — do not regenerate without this fix

The committed `generated/` C contains a required fix that the game-code emitter
does **not** yet produce: each `psx_syscall(...)` is preceded by
`cpu->pc = <addr>u;`. Without it, the game's custom `syscall` handoff records
EPC = 0, corrupts a thread's resume PC, and the machine livelocks before the
menu is drawn.

`generate` will drop this fix. The permanent resolution is a one-line change in
the framework emitter (`recompiler/src/code_generator.cpp`), after which
`generated/` can be regenerated cleanly. Until then, re-apply the three edits
(in `generated/SLUSP012.06_full_33.c` and `_41.c`) after any regeneration.

## Symbols

Progressive function map: `symbols.toml` → `tools/sync_symbols.py` →
`psx_symbols.h` (`PSX_FN_*`). See `psxrecomp/docs/SYMBOLS.md`.

## Framework pins

Submodule gitlinks (`psxrecomp`) are authoritative; `framework_pins.txt` is an
optional scaffold snapshot. Bump submodules deliberately — do not float on
`main` in release builds.

## Legal

You must own the original game. Disc images (`.bin`/`.cue`/`.iso`), BIOS dumps,
save data and any C derived from a retail BIOS are never committed; releases run
on the bundled MIT OpenBIOS. `generated/` (the recompiled game C) **is**
committed — it ships the compiled game.

Default app icon: `assets/psxrecomp.ico` (and `.png` / `.svg`). Optional box art
under `launcher_assets/img/` may come from
[libretro-thumbnails](https://github.com/libretro-thumbnails/libretro-thumbnails)
(`Named_Boxarts`); see `BOXART_SOURCE.txt` when present.

<!-- retcomm-readme-raid -->
---

<p align="center">
  <sub><b>R.A.I.D. — Retro AI Development</b> · a Discord for AI-assisted retro reverse-engineering, decomp &amp; recomp</sub>
</p>

<p align="center">
  <a href="https://discord.gg/Ad9BwSzctP"><img src=".github/raid-discord.png" alt="Join the Retro AI Development (R.A.I.D.) Discord" width="200"></a>
</p>
<!-- /retcomm-readme-raid -->
