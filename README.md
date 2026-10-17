# DW7-recomp

Native PC port of **Dragon Warrior VII** (PlayStation 1, SLUS-01206, 2 discs)
via static recompilation — not an emulator.

**Status: early development — not yet playable.**

Built on [PSXRecomp](https://github.com/RetroPortingToolKit/psxrecomp): the
game's MIPS R3000A code is translated to C ahead of time, compiled to native
x64, and linked against a PS1 hardware runtime. The bundled open-source
[OpenBIOS](https://github.com/grumpycoders/pcsx-redux) runs as the kernel —
no retail BIOS dump is required.

## What this is

- The game becomes a native Linux/Windows program. Your CPU runs the
  recompiled code directly; there is no instruction-by-instruction
  emulation on the hot path.
- PS1 games stream code off the disc at runtime (overlays). PSXRecomp
  captures each overlay the moment it loads and compiles it to native code,
  cached and reused from then on. Anything not yet compiled runs on a
  correctness-first MIPS interpreter until it is.
- Targets: **Linux** and **Windows**, 64-bit.

## Bring your own disc

This repository contains **no game data**. To build and play, you need your
own legally obtained disc images of Dragon Warrior VII (Disc 1 and Disc 2),
as `.bin`/`.cue` or `.iso` (raw MODE2/2352 dumps work). You are responsible
for complying with the law in your jurisdiction.

## Building

> Build instructions will land here once the game project scaffolding is
> committed. Development follows the
> [PSXRecomp game project setup](https://github.com/RetroPortingToolKit/psxrecomp/blob/master/docs/GAME_PROJECT_SETUP.md).

Prerequisites (high level):

- Git, Python 3, CMake 3.20+, Ninja, C/C++ toolchain
  (MSVC or the bundled [RetroPorting toolchain](https://github.com/RetroPortingToolKit/RetroPorting-Toolchains/releases/latest) on Windows)
- Your two DW7 disc images

## Development

Work happens on the `dev` branch; `main` stays stable.

## Credits

- [RetroPortingToolKit](https://github.com/RetroPortingToolKit) / mstan —
  [PSXRecomp](https://github.com/RetroPortingToolKit/psxrecomp) framework
- [PCSX-Redux project](https://github.com/grumpycoders/pcsx-redux) — OpenBIOS
- Enix (original developer/publisher of Dragon Warrior VII) — this project
  is a fan preservation effort; all rights to the game belong to their
  respective owners

## Legal

This project does not distribute Dragon Warrior VII, any Sony PlayStation
BIOS, or any other copyrighted game content. It is not affiliated with or
endorsed by Sony, Enix, or Square Enix.
