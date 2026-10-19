# DW7 Recompiled

<!-- retcomm-readme-metrics -->
[![GitHub downloads (all assets, all releases)](https://img.shields.io/github/downloads/danyboy666/DW7-recomp/total)](https://github.com/danyboy666/DW7-recomp/releases)
[![GitHub downloads (latest release)](https://img.shields.io/github/downloads/danyboy666/DW7-recomp/latest/total)](https://github.com/danyboy666/DW7-recomp/releases/latest)
[![GitHub release](https://img.shields.io/github/v/release/danyboy666/DW7-recomp)](https://github.com/danyboy666/DW7-recomp/releases/latest)
<!-- /retcomm-readme-metrics -->

Static recompilation of **Dragon Warrior VII** (PlayStation, 2001) built on
[psxrecomp](https://github.com/mstan/psxrecomp) and
[recomp-ui](https://github.com/RetroPortingToolKit/recomp-ui).

> A native PC port of Dragon Warrior VII: the game's MIPS R3000A code is
> statically recompiled to C and compiled to native x64, linked against a PS1
> hardware runtime on the bundled OpenBIOS. Not an emulator — the game runs as
> a native program. Bring your own disc; this repository ships no game data.

| | |
|---|---|
| Players | 1 |
| Region | USA |
| Publisher | Enix |
| Developer | Heart Beat / ArtePiazza / Bird Studio |
| Year | 2001 |
| Serial | SLUS-01206 |

## Status

Boots and plays on Linux and Windows (OpenGL, Vulkan and software renderers).
The title → **Continue / New Game / Delete File** menu and the New Game
name-entry screen render and accept input; the field story and battles are
under active bring-up. See the `dev` branch for the latest state.

> **Generator note (dev):** the committed `generated/` C carries a local fix —
> `cpu->pc = <addr>` before each `psx_syscall` — that the game-code emitter
> currently omits (the BIOS emitter sets it). Re-running `generate` drops it;
> land the one-line fix in `recompiler/src/code_generator.cpp` so it is
> permanent, then regenerate.

Scaffolded with the New Project Layout. See
`psxrecomp/docs/GAME_PROJECT_SETUP.md` for the full flow.

<!-- retcomm-readme-launcher -->
## Retro Launcher

You can run this title **standalone** (download the release zip, point it at
your disc, play), or manage installs, updates, and disc/BIOS wiring with
**[Retro Launcher](https://github.com/RetroPortingToolKit/Retro-Launcher)** —
the Retro Compilation Manager hub for self-compiling recomps.

[Downloads](https://github.com/RetroPortingToolKit/Retro-Launcher/releases) ·
[Full README & features](https://github.com/RetroPortingToolKit/Retro-Launcher#readme)

<p align="center">
  <img src="https://raw.githubusercontent.com/RetroPortingToolKit/Retro-Launcher/main/docs/screenshots/hub-and-game-launcher.png" alt="Retro hub with a background build, next to a title’s recomp-ui launcher" width="720">
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/RetroPortingToolKit/Retro-Launcher/main/docs/screenshots/queue-and-background-build.png" alt="Background cmake build with titles queued" width="720">
</p>

Retro checks for updates, installs the prebuilt release zips, and automates
BIOS/ROM/save plumbing so you are not stuck repeating each game’s first run by hand.
<!-- /retcomm-readme-launcher -->

## Legal

You must own the original game. Disc images under `disc/` are gitignored and
must never be committed. Retail BIOS dumps are not redistributed and no C
derived from one may be committed; releases run on the bundled MIT OpenBIOS.

`generated/` (the recompiled game C) **is committed**: releases ship the
compiled game, built by CI from that tree. Regenerate and commit it whenever
seeds or the framework pin change.

Default app icon: `assets/psxrecomp.ico` (and `.png` / `.svg`) — Retro-themed controller mark from `psxrecomp/assets/`. Windows builds embed it via `APP_ICON`.

Optional box art under `launcher_assets/img/` may come from
[libretro-thumbnails](https://github.com/libretro-thumbnails/libretro-thumbnails)
(`Named_Boxarts`); see `BOXART_SOURCE.txt` when present.

## Quick start (dev)

```bash
git submodule update --init --recursive
./psxrecomp/tools/ci/build_emitters.sh
python3 psxrecomp/psxrecomp_cli.py generate \
  --config game.toml --project-root . --disc disc/<your>.cue
git add generated && git commit -m "Regenerate game C"
cmake -S . -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-release --target psx-runtime
```

Releases: tag `vX.Y.Z` (or run the *Release builds* workflow). CI builds the
committed `generated/` C on Linux, Windows and macOS and attaches
`dw7-<version>-<platform>.zip`, the compiled game. Locally:
`scripts/package_release.sh build-release linux-x64`.

## Symbols

Progressive map: `symbols.toml` → `python3 tools/sync_symbols.py` →
`psx_symbols.h` (`PSX_FN_*`). See `psxrecomp/docs/SYMBOLS.md`.

## Framework pins

Submodule gitlinks (`psxrecomp`, optional `recomp-ui`, nested `recomp-net`)
are authoritative. `framework_pins.txt` is an optional scaffold snapshot;
release CI logs SHAs with `record_pins.sh` but builds whatever the gitlinks
resolve to. Bump submodules deliberately — do not float on `main`/`master`
in release CI.

<!-- retcomm-readme-raid -->
---

<p align="center">
  <sub><b>R.A.I.D. — Retro AI Development</b> · a Discord for AI-assisted retro reverse-engineering, decomp &amp; recomp</sub>
</p>

<p align="center">
  <a href="https://discord.gg/Ad9BwSzctP"><img src=".github/raid-discord.png" alt="Join the Retro AI Development (R.A.I.D.) Discord" width="200"></a>
</p>
<!-- /retcomm-readme-raid -->
