# DW7 HD texture pack (SLUS-P0120)

This folder is the replacement pack used by the **HD Texture Packs** mod
(open: in-game Video page -> HD TEXTURES, or the Mods page).

## Authoring workflow
1. Enable **Dump textures** (Video page -> DUMP TEXTURES, or Mods).
2. Play through the scenes you want to retexture, then quit the game. The
   runtime finishes capture PNGs under `dumps/`.
3. Open a dumped PNG, upscale/repaint it, and save it as PNG, JPEG or WebP
   under `replacements/` using the SAME filename as the dump.
4. Turn Dump off and enable **Load replacements** (HD TEXTURES on).
   Matches are shown in OpenGL; anything missing keeps the original artwork.

Dumps encode the texture's VRAM state in the filename (DuckStation format);
keep names unchanged so matching stays exact. Only OpenGL displays
replacements.
