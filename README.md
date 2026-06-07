# Edit Video Tik Tok

Automated TikTok-style video editor using FFmpeg. Takes a background image, voice audio, background music, and optional logo, then generates a vertical video (1080×1920) with:

- **Zoom out/in**: smooth sine-wave zoom (goes back, then returns)
- **Rotation**: oscillating rotation that reverses direction mid-segment ("mareo" effect)
- **Logo overlay**: scalable logo at bottom-right corner
- **Audio mix**: separate volume control for voice and background music

## Requirements

- Python 3.10+
- FFmpeg 6.x (with libx264 and aac support)
- Available via `ffmpeg` and `ffprobe` in PATH

## Installation

```bash
git clone https://github.com/siliconvalleyar-oss/edit_video_tik_tok.git
cd edit_video_tik_tok
chmod +x video_editor.py
```

No additional Python packages required (uses only stdlib).

## Usage

```bash
python3 video_editor.py -i background.jpg -a voice.mp3 -m music.mp3 -o output.mp4
```

### Options

| Argument | Default | Description |
|----------|---------|-------------|
| `-i, --image` | required | Background image path |
| `-a, --audio` | required | Main audio (voice) path |
| `-m, --music` | required | Background music path |
| `-l, --logo` | — | Optional logo image (bottom-right) |
| `-o, --output` | `output.mp4` | Output video path |
| `--zoom` | `0.25` | Zoom-out amount (0.25 = zooms to 75%) |
| `--rotation` | `5` | Rotation degrees (oscillates ±this value) |
| `--voice-volume` | `1.5` | Voice volume multiplier |
| `--music-volume` | `0.2` | Music volume multiplier |
| `--logo-width` | `150` | Logo width in pixels (height auto) |
| `--fps` | `30` | Output frames per second |
| `--preset` | `fast` | x264 encoding preset |
| `--crf` | `23` | x264 quality (lower = better) |
| `--audio-bitrate` | `128k` | Output audio bitrate |

### Examples

```bash
# Basic usage
python3 video_editor.py -i bg.jpg -a voice.mp3 -m music.mp3 -o out.mp4

# With logo and custom effects
python3 video_editor.py -i bg.jpg -a voice.mp3 -m music.mp3 -l logo.png \
  -o out.mp4 --zoom 0.3 --rotation 4 --voice-volume 2.0 --music-volume 0.15

# Subtle effects
python3 video_editor.py -i bg.jpg -a voice.mp3 -m music.mp3 -o out.mp4 \
  --zoom 0.1 --rotation 2 --voice-volume 1.0 --music-volume 0.3
```

## Effects explained

### Zoom
The zoom oscillates as a half-sine wave: `1 - zoom * sin(π · frame / total)`. The image starts at full size, zooms out to `(1 - zoom)`×, then returns to full size.

### Rotation
The rotation oscillates as a full sine wave: `angle · sin(2π · frame / total)`. As the image zooms out it rotates in one direction; as it zooms back in the rotation reverses, creating a dizzy/"mareo" effect.

### Image sizing
The background image is scaled to 1400×2560 (larger than the 1080×1920 output) so the zoom-out effect has room to reveal more of the image without showing empty borders.

## Project structure

```
.
├── README.md
├── video_editor.py       # Main script
├── imagenes/             # Place source images here (gitignored)
├── mp3/                  # Place audio files here (gitignored)
└── mp4/                  # Output directory (gitignored)
```
