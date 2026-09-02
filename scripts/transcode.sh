#!/bin/bash
set -euo pipefail

# ============================================================
# Personal website video transcode
# Encodes src/videos/scene*-source.mp4
# → public/videos/bg*-{vp9.webm, hevc.mp4, h264.mp4}
# ============================================================

# --- Resolve ffmpeg ---
resolve_ffmpeg() {
  if command -v ffmpeg >/dev/null 2>&1; then
    command -v ffmpeg
  elif [ -x "/Applications/MiniMax Design.app/Contents/Resources/ffmpeg/ffmpeg" ]; then
    echo "/Applications/MiniMax Design.app/Contents/Resources/ffmpeg/ffmpeg"
  elif [ -x "/usr/local/bin/ffmpeg" ]; then
    echo "/usr/local/bin/ffmpeg"
  elif [ -x "/opt/homebrew/bin/ffmpeg" ]; then
    echo "/opt/homebrew/bin/ffmpeg"
  else
    echo "" >&2
    echo "ERROR: ffmpeg not found. Install: brew install ffmpeg" >&2
    exit 1
  fi
}

FFMPEG="$(resolve_ffmpeg)"
echo "Using ffmpeg: $FFMPEG"
"$FFMPEG" -version 2>&1 | head -1

# --- Resolve paths ---
PROJ_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$PROJ_ROOT/src/videos"
OUT="$PROJ_ROOT/public/videos"
mkdir -p "$OUT"

# --- Helper: transcode one scene ---
transcode() {
  local src="$1" prefix="$2" desc="$3"

  if [ ! -f "$src" ]; then
    echo "SKIP $desc — source not found: $src" >&2
    return 0
  fi

  echo
  echo "================================================"
  echo "Transcoding $desc"
  echo "  in:  $src"
  echo "  out: $OUT/${prefix}-*"
  echo "================================================"

  # 1. VP9 + alpha (Chrome/Firefox/Safari 17+ best)
  echo "[1/3] VP9 + alpha → ${prefix}-vp9.webm"
  "$FFMPEG" -y -i "$src" \
    -vf "scale=1920:-2,format=yuva420p" \
    -c:v libvpx-vp9 -pix_fmt yuva420p -crf 36 -b:v 0 \
    -row-mt 1 -deadline good -cpu-used 1 -an \
    "$OUT/${prefix}-vp9.webm" \
    -loglevel error -stats

  # 2. HEVC 10-bit (Safari 14-16 fallback; alpha plane 会被 ffmpeg/libx265 吞掉)
  echo "[2/3] HEVC 10-bit → ${prefix}-hevc.mp4"
  "$FFMPEG" -y -i "$src" \
    -vf "scale=1920:-2,format=yuva420p10le" \
    -c:v libx265 -tag:v hvc1 -pix_fmt yuva420p10le \
    -crf 28 -preset slow -x265-params "alpha=1:range=tv" \
    -movflags +faststart -an \
    "$OUT/${prefix}-hevc.mp4" \
    -loglevel error -stats

  # 3. H.264 + 米色合成背景 fallback
  echo "[3/3] H.264 fallback → ${prefix}-h264.mp4"
  "$FFMPEG" -y -i "$src" \
    -filter_complex "[0:v]scale=1920:-2[fg];color=c=0xf5f1ea:size=1920x1080:duration=8[bg];[bg][fg]overlay=format=auto:eof_action=pass,format=yuv420p" \
    -c:v libx264 -pix_fmt yuv420p -crf 26 -preset slow \
    -movflags +faststart -an \
    "$OUT/${prefix}-h264.mp4" \
    -loglevel error -stats

  echo "✓ $desc done"
}

# --- Run ---
transcode "$SRC/scene1-source.mp4" "bg"  "Scene 1 (background)"
transcode "$SRC/scene2-source.mp4" "bg2" "Scene 2 (scrolled-in)"

echo
echo "================================================"
echo "✓ All videos transcoded to $OUT"
ls -lh "$OUT"
