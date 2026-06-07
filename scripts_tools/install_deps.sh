#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing FFmpeg (required for video_editor.py) ==="

if command -v ffmpeg &>/dev/null; then
    echo "FFmpeg already installed: $(ffmpeg -version | head -1)"
    exit 0
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt &>/dev/null; then
        sudo apt update
        sudo apt install -y ffmpeg
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y ffmpeg
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm ffmpeg
    else
        echo "Unsupported package manager. Install FFmpeg manually: https://ffmpeg.org/download.html"
        exit 1
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null; then
        brew install ffmpeg
    else
        echo "Install Homebrew first: https://brew.sh, then run: brew install ffmpeg"
        exit 1
    fi
else
    echo "Unsupported OS. Install FFmpeg manually: https://ffmpeg.org/download.html"
    exit 1
fi

echo "FFmpeg installed: $(ffmpeg -version | head -1)"
