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
the shortcut menu. The game starts with **faithful PSX defaults**; everything
here is opt-in. The menu is organised into categories:

- **GAME** — Quick Save / Quick Load (save-state slot 1), **Save States…** (the
  full slot browser), **Memory Cards…** (per-slot usage; **Format** and
  **Import/Export** of a 128 KB `.mcd` via a native file dialog), **Change
  Disc**, and **Quit**.
- **VIDEO** — display ratio (original 4:3 / widescreen 16:9), upscaling
  (Native/720p/1080p/1440p/4K — restart), dynamic resolution, fullscreen mode
  (windowed / borderless / exclusive), texture smoothing (Nearest / Bilinear /
  xBR), anti-aliasing (Off / FXAA / FXAA HQ), FMV filter + chroma smoothing,
  scanlines, dithering, bloom, mipmaps + anisotropic filtering, and accurate
  blending.
- **CONTROLLER** — Player 1/2 **device** (Keyboard / a connected controller /
  none), pad mode (**Analog (DualShock)** by default, or Digital), and
  **keyboard remapping** per PS1 button (persisted to `keybinds.ini`).

Navigate with arrows, confirm with Enter, back out with Esc; a controller's
D-pad + A/B also drive it. The menu pauses the game while open.

### Controller notes

- A connected game controller is detected automatically; with none present the
  **keyboard is the default** input.
- The emulated pad reports a **DualShock (analog, ID 0x73)** by default, so
  analog sticks work; per-player Digital mode is available in the menu.
- Keyboard bindings are remappable in-game (CONTROLLER → Remap P1 Keys) and
  stored in `keybinds.ini`. Gamepad buttons currently use the classic fixed
  PS1 mapping (SDL-standard layout); remapping them is a follow-up.

### Multi-disc

Disc 1 and Disc 2 are both registered in `game.toml` (`discs` /
`disc_serials`), and the menu can mount either. Note that DW7 is an
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
