# DW7 HD texture pack (SLUS-P0120)

Used by the **HD Texture Packs** mod and by **HD-2D mode** (which enables the
pack automatically when replacements exist). OpenGL displays the replacements.

```
mods/texture-packs/SLUS-P0120/
  dumps/         original textures captured by the runtime (Dump textures)
  replacements/  your HD versions, SAME filename as the dump
  config.yaml    optional DuckStation pack settings
```

## Workflow
1. In-game: **F1 -> VIDEO -> DUMP TEXTURES** (on), then play the scenes you
   want to improve. Quit through the menu so the dumps flush.
   Dumps are `texupload-*.png` / `texpage-*.png` in `dumps/`.
2. Either repaint a dump by hand, or upscale them mechanically:
   ```
   python3 tools/hd2d_pack.py --pack mods/texture-packs/SLUS-P0120 --scale 4
   ```
   This writes same-named PNGs into `replacements/` (Pillow, Lanczos + mild
   unsharp; PNG/JPEG/WebP are all accepted by the runtime).
3. Enable **HD TEXTURES** (or just toggle **HD-2D MODE**) and the matched
   textures are drawn instead of the originals. Anything missing keeps the
   original art.

Filenames encode the texture + palette hashes (DuckStation format), so keep
them exactly as dumped — the renderer matches on the name.
