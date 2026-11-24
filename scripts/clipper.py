#!/usr/bin/env python3
"""
TikTok Video Clipper Engine
Memotong footage mentah menjadi clip vertikal 9:16 (1080x1920) dan menyiapkan
paket siap upload (video + caption + manifest) untuk semua channel aktif.

Hanya memerlukan Python 3 stdlib + ffmpeg/ffprobe.
"""

from __future__ import annotations

import argparse
import json
import math
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT_DIR = Path(__file__).resolve().parent.parent
CONFIG_DIR = ROOT_DIR / "config"
CLIPS_DIR = ROOT_DIR / "clips"
READY_DIR = ROOT_DIR / "ready_to_upload"


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def parse_timestamp(value: str) -> float:
    """Parse HH:MM:SS(.ms), MM:SS(.ms), or seconds into float seconds."""
    value = value.strip()
    parts = value.split(":")
    if len(parts) == 1:
        return float(parts[0])
    if len(parts) == 2:
        return int(parts[0]) * 60 + float(parts[1])
    if len(parts) == 3:
        return int(parts[0]) * 3600 + int(parts[1]) * 60 + float(parts[2])
    raise ValueError(f"Format timestamp tidak valid: {value}")


def parse_segments(spec: str) -> list[tuple[float, float]]:
    segments: list[tuple[float, float]] = []
    for raw in spec.split(","):
        raw = raw.strip()
        if not raw:
            continue
        if "-" not in raw:
            raise ValueError(f"Segment harus memakai format start-end, dapat: {raw}")
        start_s, end_s = raw.split("-", 1)
        start = parse_timestamp(start_s)
        end = parse_timestamp(end_s)
        if end <= start:
            raise ValueError(f"End ({end_s}) harus lebih besar dari start ({start_s})")
        segments.append((start, end))
    if not segments:
        raise ValueError("Tidak ada segment valid yang diberikan.")
    return segments


def probe_video(video_path: Path) -> dict[str, Any]:
    cmd = [
        "ffprobe",
        "-v",
        "quiet",
        "-print_format",
        "json",
        "-show_format",
        "-show_streams",
        str(video_path),
    ]
    res = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(res.stdout)
    video_stream = next(
        (s for s in data.get("streams", []) if s.get("codec_type") == "video"), {}
    )
    audio_stream = next(
        (s for s in data.get("streams", []) if s.get("codec_type") == "audio"), None
    )
    duration = float(data.get("format", {}).get("duration", 0.0))
    return {
        "file": str(video_path),
        "duration_seconds": round(duration, 2),
        "width": video_stream.get("width"),
        "height": video_stream.get("height"),
        "fps": video_stream.get("r_frame_rate"),
        "video_codec": video_stream.get("codec_name"),
        "has_audio": audio_stream is not None,
        "audio_codec": audio_stream.get("codec_name") if audio_stream else None,
        "size_mb": round(video_path.stat().st_size / (1024 * 1024), 2),
    }


def build_video_filter(
    width: int,
    height: int,
    fit_mode: str,
    subtitle_path: Path | None = None,
) -> tuple[list[str], str]:
    """Return ffmpeg filter arguments and mapped video stream label."""
    if fit_mode == "crop":
        vf = (
            f"scale={width}:{height}:force_original_aspect_ratio=increase,"
            f"crop={width}:{height},setsar=1"
        )
        if subtitle_path:
            escaped = str(subtitle_path).replace("\\", "\\\\").replace(":", "\\:").replace("'", "\\'")
            vf += f",subtitles='{escaped}'"
        return ["-vf", vf], ""

    if fit_mode == "blur":
        fc = (
            f"[0:v]scale={width}:{height}:force_original_aspect_ratio=increase,"
            f"crop={width}:{height},boxblur=20:5[bg];"
            f"[0:v]scale={width}:{height}:force_original_aspect_ratio=decrease[fg];"
            f"[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1"
        )
        if subtitle_path:
            escaped = str(subtitle_path).replace("\\", "\\\\").replace(":", "\\:").replace("'", "\\'")
            fc += f",subtitles='{escaped}'"
        fc += "[vout]"
        return ["-filter_complex", fc], "[vout]"

    raise ValueError(f"Mode fit tidak dikenal: {fit_mode} (gunakan 'crop' atau 'blur')")


def render_clip(
    input_path: Path,
    output_path: Path,
    start: float,
    end: float,
    preset: dict[str, Any],
    fit_mode: str,
    has_audio: bool,
    subtitle_path: Path | None = None,
) -> None:
    duration = end - start
    width = int(preset["width"])
    height = int(preset["height"])
    filter_args, v_map = build_video_filter(width, height, fit_mode, subtitle_path)

    cmd = [
        "ffmpeg",
        "-y",
        "-ss",
        f"{start:.3f}",
        "-i",
        str(input_path),
        "-t",
        f"{duration:.3f}",
        *filter_args,
    ]

    if v_map:
        cmd.extend(["-map", v_map])
        if has_audio:
            cmd.extend(["-map", "0:a?"])
    else:
        cmd.extend(["-map", "0:v:0"])
        if has_audio:
            cmd.extend(["-map", "0:a?"])

    cmd.extend(
        [
            "-r",
            str(preset["fps"]),
            "-c:v",
            preset["video_codec"],
            "-preset",
            preset["preset"],
            "-crf",
            str(preset["crf"]),
            "-pix_fmt",
            preset["pixel_format"],
            "-movflags",
            "+faststart",
        ]
    )

    if has_audio:
        if preset.get("normalize_audio", True):
            cmd.extend(["-af", "loudnorm=I=-14:TP=-1.5:LRA=11"])
        cmd.extend(
            [
                "-c:a",
                preset["audio_codec"],
                "-b:a",
                preset["audio_bitrate"],
                "-ar",
                str(preset["audio_sample_rate"]),
            ]
        )
    else:
        cmd.append("-an")

    cmd.append(str(output_path))
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)


def render_caption(channel: dict[str, Any], custom_hook: str | None = None, custom_cta: str | None = None) -> str:
    template = channel.get("caption_template", "{hook}\n\n{cta}\n\n{hashtags}")
    hook = custom_hook or channel.get("default_hook", "")
    cta = custom_cta or channel.get("default_cta", "")
    hashtags = " ".join(channel.get("default_hashtags", []))
    return template.format(hook=hook, cta=cta, hashtags=hashtags).strip() + "\n"


def cmd_inspect(args: argparse.Namespace) -> int:
    video_path = Path(args.input).expanduser().resolve()
    if not video_path.exists():
        print(f"Error: file tidak ditemukan: {video_path}", file=sys.stderr)
        return 1
    info = probe_video(video_path)
    print(json.dumps(info, indent=2, ensure_ascii=False))
    return 0


def cmd_clip(args: argparse.Namespace) -> int:
    input_path = Path(args.input).expanduser().resolve()
    if not input_path.exists():
        print(f"Error: footage tidak ditemukan: {input_path}", file=sys.stderr)
        return 1

    presets = load_json(CONFIG_DIR / "clip_presets.json")
    preset = presets[args.preset]
    channels_cfg = load_json(CONFIG_DIR / "channels.json")
    channels = [c for c in channels_cfg.get("channels", []) if c.get("enabled", True)]

    if args.channels:
        wanted = {c.strip() for c in args.channels.split(",") if c.strip()}
        channels = [c for c in channels if c["id"] in wanted]

    if not channels:
        print("Error: tidak ada channel aktif yang cocok di config/channels.json.", file=sys.stderr)
        return 1

    info = probe_video(input_path)
    total_duration = info["duration_seconds"]
    if total_duration <= 0:
        print("Error: durasi video tidak valid.", file=sys.stderr)
        return 1

    if args.segments:
        segments = parse_segments(args.segments)
    elif args.chunk_seconds:
        chunk = float(args.chunk_seconds)
        if chunk <= 0:
            raise ValueError("--chunk-seconds harus > 0")
        count = math.ceil(total_duration / chunk)
        segments = []
        min_dur = float(preset.get("min_duration_seconds", 5))
        for i in range(count):
            start = i * chunk
            end = min((i + 1) * chunk, total_duration)
            if end - start >= min_dur or i == 0:
                segments.append((start, end))
    else:
        max_dur = float(preset.get("max_duration_seconds", 60))
        segments = [(0.0, min(total_duration, max_dur))]

    batch_name = args.batch or f"{input_path.stem}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    batch_clips_dir = CLIPS_DIR / batch_name
    batch_clips_dir.mkdir(parents=True, exist_ok=True)

    subtitle_path = Path(args.subtitle).expanduser().resolve() if args.subtitle else None
    if subtitle_path and not subtitle_path.exists():
        print(f"Error: file subtitle tidak ditemukan: {subtitle_path}", file=sys.stderr)
        return 1

    # Render unik berdasarkan fit_mode yang dibutuhkan oleh channel aktif (atau override --fit)
    needed_fits = {args.fit} if args.fit else {c.get("fit_mode", "crop") for c in channels}
    rendered_files: dict[tuple[int, str], Path] = {}

    print(f"Memproses footage: {input_path.name} ({total_duration}s) -> {len(segments)} clip(s)")
    for idx, (start, end) in enumerate(segments, start=1):
        clamped_end = min(end, total_duration)
        if clamped_end <= start:
            continue
        for fit_mode in sorted(needed_fits):
            out_name = f"clip_{idx:02d}_{fit_mode}.mp4"
            out_path = batch_clips_dir / out_name
            print(f"  - Render clip #{idx:02d} [{start:.1f}s - {clamped_end:.1f}s] mode={fit_mode} -> {out_path.name}")
            render_clip(
                input_path=input_path,
                output_path=out_path,
                start=start,
                end=clamped_end,
                preset=preset,
                fit_mode=fit_mode,
                has_audio=bool(info["has_audio"]),
                subtitle_path=subtitle_path,
            )
            rendered_files[(idx, fit_mode)] = out_path

    # Distribusi paket siap upload untuk setiap channel aktif
    summary_channels = []
    for ch in channels:
        ch_fit = args.fit or ch.get("fit_mode", "crop")
        ch_dir = READY_DIR / ch["id"] / batch_name
        ch_dir.mkdir(parents=True, exist_ok=True)

        items = []
        for idx, (start, end) in enumerate(segments, start=1):
            src_clip = rendered_files.get((idx, ch_fit))
            if not src_clip:
                continue
            dst_clip = ch_dir / f"{batch_name}_clip_{idx:02d}.mp4"
            shutil.copy2(src_clip, dst_clip)

            caption_text = render_caption(ch, custom_hook=args.hook, custom_cta=args.cta)
            caption_file = ch_dir / f"{batch_name}_clip_{idx:02d}.caption.txt"
            caption_file.write_text(caption_text, encoding="utf-8")

            items.append(
                {
                    "clip_index": idx,
                    "start_seconds": round(start, 2),
                    "end_seconds": round(min(end, total_duration), 2),
                    "duration_seconds": round(min(end, total_duration) - start, 2),
                    "video_file": dst_clip.name,
                    "caption_file": caption_file.name,
                    "fit_mode": ch_fit,
                }
            )

        manifest = {
            "batch": batch_name,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "source_footage": input_path.name,
            "channel": {
                "id": ch["id"],
                "name": ch["name"],
                "handle": ch["handle"],
                "upload_mode": ch.get("upload_mode", "inbox"),
                "token_env_var": ch.get("token_env_var"),
                "posting_window": ch.get("posting_window"),
            },
            "clips": items,
        }
        (ch_dir / "manifest.json").write_text(
            json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8"
        )
        summary_channels.append({"channel_id": ch["id"], "clips_count": len(items), "dir": str(ch_dir)})

    print("\nSelesai! Paket siap upload dibuat untuk channel berikut:")
    for row in summary_channels:
        print(f"  - {row['channel_id']}: {row['clips_count']} clip -> {row['dir']}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="TikTok Video Clipper Engine")
    sub = parser.add_subparsers(dest="command", required=True)

    p_inspect = sub.add_parser("inspect", help="Periksa metadata footage video")
    p_inspect.add_argument("input", help="Path ke file video mentah")
    p_inspect.set_defaults(func=cmd_inspect)

    p_clip = sub.add_parser("clip", help="Potong footage ke format 9:16 & siapkan paket per channel")
    p_clip.add_argument("--input", required=True, help="Path ke file footage mentah")
    p_clip.add_argument("--segments", help='Timestamp manual, mis: "00:00:05-00:00:25,00:00:40-00:01:05"')
    p_clip.add_argument("--chunk-seconds", type=float, help="Potong otomatis tiap N detik")
    p_clip.add_argument("--fit", choices=["crop", "blur"], help="Override mode framing 9:16 untuk semua channel")
    p_clip.add_argument("--preset", default="tiktok_vertical", help="Nama preset di config/clip_presets.json")
    p_clip.add_argument("--batch", help="Nama folder batch output")
    p_clip.add_argument("--channels", help="Filter ID channel tertentu (pisahkan dengan koma)")
    p_clip.add_argument("--subtitle", help="Opsional: path file .srt untuk burn-in subtitle")
    p_clip.add_argument("--hook", help="Opsional: override teks hook untuk batch ini")
    p_clip.add_argument("--cta", help="Opsional: override teks CTA untuk batch ini")
    p_clip.set_defaults(func=cmd_clip)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
