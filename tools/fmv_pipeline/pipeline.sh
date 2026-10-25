#!/usr/bin/env bash
# DW7 enhanced-FMV pipeline (BYOD, local-only).
#   extract (jPSXdec, WSL) -> Real-ESRGAN 4x (Windows GPU) -> RIFE 2x (Windows GPU)
#   -> H.264 8x-native (WSL ffmpeg) -> <build>/fmv/<name>.mp4
# Nothing produced here may be committed: the videos derive from game data.
set -euo pipefail

KEY="${1:-}"
SRC_ROOT="${FMV_SRC:-/mnt/d/Opencode storage/dwarrior7/fmv_work/pipeline}"
TOOLS="${FMV_TOOLS:-/mnt/d/Opencode storage/dwarrior7/fmv_tools}"
OUT="${FMV_OUT:-$(cd "$(dirname "$0")/../.." && pwd)/build-release-win/fmv}"
WIN_TOOLS="$(wslpath -w "$TOOLS")"

case "$KEY" in
  title)           ID=50 NAME=title           FPS=15 W=256 H=224 ;;
  intro_world)     ID=51 NAME=intro_world     FPS=15 W=256 H=224 ;;
  intro_whirlpool) ID=52 NAME=intro_whirlpool FPS=15 W=256 H=224 ;;
  intro_priestess) ID=53 NAME=intro_priestess FPS=15 W=256 H=224 ;;
  intro_ship)      ID=54 NAME=intro_ship      FPS=15 W=256 H=224 ;;
  intro_lava)      ID=55 NAME=intro_lava      FPS=15 W=256 H=224 ;;
  credits)         ID=56 NAME=credits         FPS=20 W=320 H=224 ;;
  all) for k in title intro_world intro_whirlpool intro_priestess intro_ship intro_lava credits; do "$0" "$k"; done; exit 0 ;;
  *) echo "usage: $0 <title|intro_world|intro_whirlpool|intro_priestess|intro_ship|intro_lava|credits|all>" >&2; exit 2 ;;
esac

SRC="$SRC_ROOT/src_$ID"
WORK="$SRC_ROOT/work_$ID"
UP="$WORK/up"; RIF="$WORK/rif"
[ -d "$SRC" ] || { echo "missing source frames: $SRC (extract with jPSXdec first)" >&2; exit 1; }
mkdir -p "$UP" "$RIF" "$OUT"

OUT_FPS=$((FPS * 2))
OW=$((W * 8)); OH=$((H * 8))

echo "[$NAME] upscaling 4x (Real-ESRGAN) ..."
powershell.exe -NoProfile -Command "
  Set-Location '$WIN_TOOLS\\win'
  & '.\\realesrgan-ncnn-vulkan.exe' -i '$(wslpath -w "$SRC")' -o '$(wslpath -w "$UP")' -n realesr-animevideov3 -s 4 -f png 2>&1 | Select-Object -Last 1
  exit 0
"

echo "[$NAME] interpolating 2x (RIFE) ..."
powershell.exe -NoProfile -Command "
  Set-Location '$WIN_TOOLS\\win\\rife-ncnn-vulkan-20221029-windows'
  & '.\\rife-ncnn-vulkan.exe' -i '$(wslpath -w "$UP")' -o '$(wslpath -w "$RIF")' 2>&1 | Select-Object -Last 1
  exit 0
"

echo "[$NAME] encoding ${OW}x${OH} @ ${OUT_FPS}fps ..."
ffmpeg -v error -y -framerate "$OUT_FPS" -i "$RIF/%08d.png" \
  -vf "scale=${OW}:${OH}:flags=lanczos" \
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -movflags +faststart \
  "$OUT/$NAME.mp4"

ffprobe -v error -show_entries format=duration:stream=width,height,r_frame_rate -of default=nw=1 "$OUT/$NAME.mp4"
rm -rf "$UP" "$RIF"
echo "[$NAME] done -> $OUT/$NAME.mp4"
