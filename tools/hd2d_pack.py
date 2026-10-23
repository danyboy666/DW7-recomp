#!/usr/bin/env python3
"""hd2d_pack.py - build HD-2D texture replacements from runtime texture dumps.

The runtime's HD Texture Packs mod writes original textures to
  <pack>/dumps/texupload-*.png  (and texpage-*.png)
Repaint or upscale those images and place them (same filename) in
  <pack>/replacements/
to have the OpenGL renderer display them.

This tool automates the mechanical part: high-quality upscaling that keeps
the exact filenames the renderer matches on. For hand-painted art, drop your
own files in replacements/ instead.
"""
import argparse
import os
import re
import sys

NAME_RE = re.compile(r"^(texupload|texpage)-.+\.(png|jpg|jpeg|webp)$", re.IGNORECASE)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--pack", default="mods/texture-packs/SLUS-P0120",
                    help="texture pack root (has dumps/ and replacements/)")
    ap.add_argument("--scale", type=int, default=4, choices=(1, 2, 4, 8),
                    help="upscale factor (default 4)")
    ap.add_argument("--filter", default="lanczos", choices=("lanczos", "nearest", "bicubic"),
                    help="resampling filter (default lanczos)")
    ap.add_argument("--sharp", type=float, default=0.6,
                    help="unsharp-mask amount after scaling, 0 disables (default 0.6)")
    ap.add_argument("--only-missing", action="store_true",
                    help="skip images that already have a replacement")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    try:
        from PIL import Image, ImageFilter
    except ImportError:
        print("error: Pillow is required (pip install pillow)", file=sys.stderr)
        return 2

    pack = os.path.abspath(args.pack)
    dumps = os.path.join(pack, "dumps")
    repl = os.path.join(pack, "replacements")
    if not os.path.isdir(dumps):
        print(f"error: no dumps directory: {dumps}", file=sys.stderr)
        print("Enable DUMP TEXTURES in the in-game Video page, play, then quit.", file=sys.stderr)
        return 1
    os.makedirs(repl, exist_ok=True)

    filt = {"lanczos": Image.LANCZOS, "nearest": Image.NEAREST,
            "bicubic": Image.BICUBIC}[args.filter]

    done = skipped = failed = 0
    for name in sorted(os.listdir(dumps)):
        if not NAME_RE.match(name):
            continue
        src = os.path.join(dumps, name)
        stem = os.path.splitext(name)[0]
        dst = os.path.join(repl, stem + ".png")
        if args.only_missing and os.path.exists(dst):
            skipped += 1
            continue
        try:
            with Image.open(src) as im:
                im = im.convert("RGBA")
                w, h = im.size
                out = im.resize((w * args.scale, h * args.scale), filt)
                if args.sharp > 0:
                    out = out.filter(ImageFilter.UnsharpMask(
                        radius=1.2, percent=int(args.sharp * 100), threshold=2))
                if args.dry_run:
                    print(f"would write {dst} ({w}x{h} -> {out.size[0]}x{out.size[1]})")
                else:
                    out.save(dst, "PNG", optimize=True)
            done += 1
        except Exception as exc:  # noqa: BLE001 - report and continue
            failed += 1
            print(f"warn: {name}: {exc}", file=sys.stderr)

    print(f"hd2d_pack: {done} written, {skipped} skipped, {failed} failed -> {repl}")
    if done and not args.dry_run:
        print("Enable HD TEXTURES (or toggle HD-2D) to display them.")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
