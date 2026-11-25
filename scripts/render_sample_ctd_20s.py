#!/usr/bin/env python3
"""
Render 1 Sample 20s Marketing Clip (9:16 vertical 1080x1920)
Source: Close The Door Podcast (Deddy Corbuzier reviewing Broguy.id)
Highlight: Deddy admiring fabric quality & shock at 70k price point
Style: 3-Zone Vertical Layout, Floating White Speech Card, Brand Orange Highlights, TikTok -14 LUFS Audio
"""

import subprocess
import sys
import time
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
RAW_VIDEO = ROOT_DIR / "footage" / "ctd_gdrive" / "raw_ctd_source.mp4"
ASSETS_DIR = ROOT_DIR / "assets" / "sample_ctd"
OUT_DIR = ROOT_DIR / "clips" / "sample_ctd_20s"
OUT_DIR.mkdir(parents=True, exist_ok=True)

OUT_FILE = OUT_DIR / "sample_ctd_broguy_20s.mp4"

HOOK_PNG = ASSETS_DIR / "hook_card.png"
CTA_PNG = ASSETS_DIR / "cta_banner.png"

START_TIME = 51.0
DURATION = 20.0

def render_sample() -> None:
    print("=== RENDERING 20S CTD MARKETING CLIP ===")
    print(f"Source: {RAW_VIDEO}")
    print(f"Output: {OUT_FILE}")
    print(f"Start: {START_TIME}s, Duration: {DURATION}s\n")

    filter_complex = (
        # 1. Blurred and slightly darkened background
        "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=24:5,eq=brightness=-0.08:contrast=1.05[bg];"
        # 2. Main video window scaled to 1080x608, centered at y=512
        "[0:v]scale=1080:608[fg];"
        "[bg][fg]overlay=x=0:y=512[base];"
        # 3. Floating Hook Card overlay with smooth micro-slide at start
        "[base][1:v]overlay=x=0:y='if(lte(t,0.35), 80*(1-sin(t/0.35*PI/2)), 0)'[v_hook];"
        # 4. CTA Banner popup at last 4 seconds (16.0s - 20.0s)
        "[v_hook][2:v]overlay=x=0:y='if(lte(t-16.0,0.3), 120*(1-sin((t-16.0)/0.3*PI/2)), 0)':enable='between(t,16.0,20.0)'[v_out]"
    )

    cmd = [
        "ffmpeg", "-y",
        "-ss", f"{START_TIME:.2f}",
        "-t", f"{DURATION:.2f}",
        "-i", str(RAW_VIDEO),
        "-i", str(HOOK_PNG),
        "-i", str(CTA_PNG),
        "-filter_complex", filter_complex,
        "-map", "[v_out]",
        "-map", "0:a",
        "-af", "loudnorm=I=-14:TP=-1.5:LRA=11",
        "-r", "30",
        "-c:v", "libx264",
        "-preset", "medium",
        "-crf", "20",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac",
        "-b:a", "192k",
        "-ar", "48000",
        "-movflags", "+faststart",
        str(OUT_FILE),
    ]

    t0 = time.time()
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print("FFmpeg error:", res.stderr, file=sys.stderr)
        sys.exit(1)

    dt = time.time() - t0
    size_mb = round(OUT_FILE.stat().st_size / (1024 * 1024), 2)
    print(f"Render sukses dalam {dt:.1f} detik!")
    print(f"File size: {size_mb} MB")

if __name__ == "__main__":
    render_sample()
