#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import sys
import tempfile


def get_audio_duration(path: str) -> float:
    result = subprocess.run(
        [
            "ffprobe", "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            path,
        ],
        capture_output=True, text=True, check=True,
    )
    return float(result.stdout.strip())


def build_filtergraph(
    duration: float,
    fps: int,
    zoom_amount: float,
    rotation_degrees: float,
    voice_volume: float,
    music_volume: float,
    logo_path: str | None,
    logo_width: int,
):
    total_frames = int(duration * fps)
    w, h = 1080, 1920
    inner_w, inner_h = 1400, 2560  # larger than output for zoom-out

    # Video: scale+crop to inner size → zoompan → rotate → crop back → setsar
    vid = (
        f"[0:v]scale={inner_w}:{inner_h}:force_original_aspect_ratio=increase,"
        f"crop={inner_w}:{inner_h},"
        f"zoompan=z='1-{zoom_amount}*sin(PI*on/{total_frames - 1})':"
        f"d={total_frames}:fps={fps}:s={w}x{h},"
        f"rotate={rotation_degrees}*PI/180*sin(2*PI*n/{total_frames - 1}),"
        f"crop={w}:{h},setsar=1,format=yuv420p[vid]"
    )

    # Audio: voice → volume + resample to stereo 48kHz
    voice = (
        f"[1:a]volume={voice_volume},"
        f"aformat=sample_rates=48000:channel_layouts=stereo[voice]"
    )

    # Audio: music → volume + resample
    music = (
        f"[2:a]volume={music_volume},"
        f"aformat=sample_rates=48000:channel_layouts=stereo[musicbg]"
    )

    # Mix
    amix = "[voice][musicbg]amix=inputs=2:duration=first[aud]"

    if logo_path:
        logo = f"[3:v]scale={logo_width}:-1[logo];"
        overlay = (
            f"[vid][logo]overlay=main_w-overlay_w-10:main_h-overlay_h-10,"
            f"format=yuv420p[vid_final]"
        )
        video_output = "[vid_final]"
        parts = [vid, voice, music, logo + overlay, amix]
    else:
        video_output = "[vid]"
        parts = [vid, voice, music, amix]

    return "; ".join(parts), video_output


def build_cmd(
    image: str,
    audio: str,
    music: str,
    output: str,
    logo: str | None,
    duration: float,
    fps: int,
    zoom_amount: float,
    rotation_degrees: float,
    voice_volume: float,
    music_volume: float,
    logo_width: int,
    preset: str,
    crf: int,
    audio_bitrate: str,
):
    filtergraph, video_output = build_filtergraph(
        duration, fps, zoom_amount, rotation_degrees,
        voice_volume, music_volume, logo, logo_width,
    )

    inputs = [
        "-loop", "1", "-t", str(duration + 2),
        "-i", image,
        "-i", audio,
        "-i", music,
    ]
    if logo:
        inputs += ["-loop", "1", "-t", str(duration + 2), "-i", logo]

    return [
        "ffmpeg", "-y",
        *inputs,
        "-filter_complex", filtergraph,
        "-map", video_output,
        "-map", "[aud]",
        "-t", str(duration),
        "-c:v", "libx264",
        "-preset", preset,
        "-crf", str(crf),
        "-c:a", "aac",
        "-b:a", audio_bitrate,
        output,
    ]


def main():
    parser = argparse.ArgumentParser(
        description="Edit video with TikTok-style effects (zoom, rotation, logo, audio mix).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  %(prog)s -i bg.jpg -a voice.mp3 -m music.mp3 -o out.mp4\n"
            "  %(prog)s -i bg.jpg -a voice.mp3 -m music.mp3 -l logo.png -o out.mp4\n"
            "  %(prog)s -i bg.jpg -a voice.mp3 -m music.mp3 -o out.mp4 --zoom 0.3 --rotation 4\n"
        ),
    )
    parser.add_argument("-i", "--image", required=True, help="Background image path")
    parser.add_argument("-a", "--audio", required=True, help="Main audio (voice) path")
    parser.add_argument("-m", "--music", required=True, help="Background music path")
    parser.add_argument("-l", "--logo", help="Logo image path (optional)")
    parser.add_argument("-o", "--output", default="output.mp4", help="Output video path")
    parser.add_argument("--fps", type=int, default=30, help="Frames per second (default: 30)")
    parser.add_argument("--zoom", type=float, default=0.25, help="Zoom-out amount (default: 0.25)")
    parser.add_argument("--rotation", type=float, default=5, help="Rotation degrees (default: 5)")
    parser.add_argument("--voice-volume", type=float, default=1.5, help="Voice volume multiplier (default: 1.5)")
    parser.add_argument("--music-volume", type=float, default=0.2, help="Music volume multiplier (default: 0.2)")
    parser.add_argument("--logo-width", type=int, default=150, help="Logo width in pixels (default: 150)")
    parser.add_argument("--preset", default="fast", help="x264 preset (default: fast)")
    parser.add_argument("--crf", type=int, default=23, help="x264 CRF quality (default: 23)")
    parser.add_argument("--audio-bitrate", default="128k", help="Audio bitrate (default: 128k)")

    args = parser.parse_args()

    for f in [args.image, args.audio, args.music]:
        if not os.path.isfile(f):
            sys.exit(f"Error: file not found: {f}")
    if args.logo and not os.path.isfile(args.logo):
        sys.exit(f"Error: file not found: {args.logo}")

    print("Detecting audio duration...")
    duration = get_audio_duration(args.audio)
    print(f"  Duration: {duration:.2f}s")

    cmd = build_cmd(
        image=args.image,
        audio=args.audio,
        music=args.music,
        output=args.output,
        logo=args.logo,
        duration=duration,
        fps=args.fps,
        zoom_amount=args.zoom,
        rotation_degrees=args.rotation,
        voice_volume=args.voice_volume,
        music_volume=args.music_volume,
        logo_width=args.logo_width,
        preset=args.preset,
        crf=args.crf,
        audio_bitrate=args.audio_bitrate,
    )

    print("Running ffmpeg...")
    subprocess.run(cmd, check=True)
    print(f"Done: {args.output}")


if __name__ == "__main__":
    main()
