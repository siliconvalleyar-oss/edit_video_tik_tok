#!/usr/bin/env bash
set -euo pipefail

# Example: generate a TikTok-style video with default effects
# Usage: ./scripts_tools/run_example.sh

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

IMAGE="${1:-copo_de_nieve_01.jpeg}"
AUDIO="${2:-copo_nieve.mp3}"
MUSIC="${3:-reggae_2min.mp3}"
LOGO="${4:-grasas.png}"
OUTPUT="${5:-video_final.mp4}"

# Check required files
for f in "$IMAGE" "$AUDIO" "$MUSIC"; do
    if [[ ! -f "$f" ]]; then
        echo "Error: required file not found: $f"
        echo "Usage: $0 [image] [audio] [music] [logo] [output]"
        exit 1
    fi
done

LOGO_ARGS=()
if [[ -f "$LOGO" ]]; then
    LOGO_ARGS=(-l "$LOGO")
    echo "Logo: $LOGO"
else
    echo "No logo found, proceeding without it"
fi

echo "Image: $IMAGE"
echo "Audio: $AUDIO"
echo "Music: $MUSIC"
echo "Output: $OUTPUT"
echo ""

python3 video_editor.py \
    -i "$IMAGE" \
    -a "$AUDIO" \
    -m "$MUSIC" \
    "${LOGO_ARGS[@]}" \
    -o "$OUTPUT" \
    --zoom 0.25 \
    --rotation 5 \
    --voice-volume 1.5 \
    --music-volume 0.2
