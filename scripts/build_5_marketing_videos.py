#!/usr/bin/env python3
"""
Master Engine: Render 5 Viral TikTok Marketing Clips
Memotong footage 24Nov menjadi 5 video 9:16 (1080x1920) dengan:
- Dynamic Hook Card (animasi slide-down di 3 detik pertama)
- Highlight terbaik & cutting pas
- Word-level highlighted captions (bright yellow/white)
- Motion CTA popup di akhir
- Audio normalisasi standar TikTok (-14 LUFS)
- Auto-package ke ready_to_upload/ lengkap dengan caption & hashtag
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))
OVERLAYS_DIR = ROOT_DIR / "assets" / "overlays"
CLIPS_OUT_DIR = ROOT_DIR / "clips" / "marketing_batch_24nov"
READY_DIR = ROOT_DIR / "ready_to_upload"
CHANNELS_CFG = ROOT_DIR / "config" / "channels.json"

RAW_DIR = Path("/Users/user/Movies/ClipperMarketing/24Nov")

CLIPS_METADATA = [
    {
        "id": "video_01",
        "title": "Signature Look: Corduroy Dark Brown",
        "file_name": "marketing_clip_01_signature_brown.mp4",
        "source": "VID-20261124-WA0000.mp4",
        "start": 3.0,
        "duration": 30.0,
        "hook_title": "JANGAN SALAH PILIH! INI WARNA CORDUROY PALING GANTENG!",
        "captions": [
            (0.0, 5.0, "cap_0.png"),
            (5.0, 10.0, "cap_1.png"),
            (10.0, 15.5, "cap_2.png"),
            (15.5, 21.0, "cap_3.png"),
            (21.0, 25.5, "cap_4.png"),
            (25.5, 30.0, "cap_5.png"),
        ],
        "default_caption": (
            "Warna Corduroy Dark Brown ini bener-bener gak ada obat gantengnya! 🔥\n"
            "Cuttingan drop shoulder bikin badan keliatan tegap dan macho.\n\n"
            "Kalian tim warna gelap atau terang? Tulis di komen!\n\n"
            "#fyp #outfitcowok #corduroyjacket #fashionpria #rekomendasijaket"
        ),
    },
    {
        "id": "video_02",
        "title": "All-Black Clean Fit: Corduroy Hitam + Pocket Tee",
        "file_name": "marketing_clip_02_black_combo.mp4",
        "source": "VID-20261124-WA0001.mp4",
        "start": 2.0,
        "duration": 30.0,
        "hook_title": "COMBO OUTFIT MAUT YANG BIKIN CEWEK AUTO LILIK!",
        "captions": [
            (0.0, 5.0, "cap_0.png"),
            (5.0, 10.5, "cap_1.png"),
            (10.5, 16.0, "cap_2.png"),
            (16.0, 21.5, "cap_3.png"),
            (21.5, 26.0, "cap_4.png"),
            (26.0, 30.0, "cap_5.png"),
        ],
        "default_caption": (
            "Combo anti gagal paling aman tapi paling auto dilirik! ⭐\n"
            "Outer corduroy hitam pekat dipadu inner pocket tee putih.\n\n"
            "Klaim voucher diskon live sekarang di keranjang kuning!\n\n"
            "#fyp #ootdindo #blackoutfit #corduroy #tipsfashionpria"
        ),
    },
    {
        "id": "video_03",
        "title": "Spill Detail & Kualitas Bahan Distro Premium",
        "file_name": "marketing_clip_03_quality_detail.mp4",
        "source": "VID-20261124-WA0002.mp4",
        "start": 2.0,
        "duration": 30.0,
        "hook_title": "JANGAN DULU BELI SEBELUM LIHAT DETAIL JAHITAN INI!",
        "captions": [
            (0.0, 5.0, "cap_0.png"),
            (5.0, 10.5, "cap_1.png"),
            (10.5, 16.0, "cap_2.png"),
            (16.0, 21.5, "cap_3.png"),
            (21.5, 26.0, "cap_4.png"),
            (26.0, 30.0, "cap_5.png"),
        ],
        "default_caption": (
            "Kualitas jahitannya sedetail dan serapi ini dong! 🔍\n"
            "Bahan corduroy tebal tapi lemas dan adem dipakai seharian.\n\n"
            "Stok promo terbatas, langsung amankan size kamu sebelum ludes!\n\n"
            "#fyp #reviewjujur #spilljaket #kualitaspremium #lokalpride"
        ),
    },
    {
        "id": "video_04",
        "title": "Battle Warna: Maroon Kemeja vs Black Jacket",
        "file_name": "marketing_clip_04_battle_maroon_black.mp4",
        "source": "VID-20261124-WA0003.mp4",
        "start": 15.0,
        "duration": 30.0,
        "hook_title": "PILIH MAROON ATAU HITAM? KALIAN LEBIH COCOK MANA?",
        "captions": [
            (0.0, 5.0, "cap_0.png"),
            (5.0, 10.5, "cap_1.png"),
            (10.5, 16.0, "cap_2.png"),
            (16.0, 21.5, "cap_3.png"),
            (21.5, 26.0, "cap_4.png"),
            (26.0, 30.0, "cap_5.png"),
        ],
        "default_caption": (
            "Maroon yang elegan cerah di kulit vs Hitam yang versatile formal. 👀\n"
            "Dua-duanya punya karakter kuat buat OOTD harian kamu.\n\n"
            "Kalian tim Maroon atau tim Hitam? Vote di komentar ya!\n\n"
            "#fyp #battleoutfit #maroonshirt #blackjacket #ootdpria"
        ),
    },
    {
        "id": "video_05",
        "title": "Sizing & Fit Guide Model Pria (TB 172 BB 65)",
        "file_name": "marketing_clip_05_sizing_tryon.mp4",
        "source": "VID-20261124-WA0004.mp4",
        "start": 3.0,
        "duration": 30.0,
        "hook_title": "TB 172 BB 65 PAKAI SIZE APA? INI HASIL TRY-ON NYATA!",
        "captions": [
            (0.0, 5.0, "cap_0.png"),
            (5.0, 10.5, "cap_1.png"),
            (10.5, 16.0, "cap_2.png"),
            (16.0, 21.5, "cap_3.png"),
            (21.5, 26.0, "cap_4.png"),
            (26.0, 30.0, "cap_5.png"),
        ],
        "default_caption": (
            "Biar gak bingung milih size pas checkout! 📏\n"
            "Model TB 172 cm BB 65 kg pas banget pakai Size L.\n\n"
            "Cek panduan lingkar dada lengkapnya di keranjang kuning ya!\n\n"
            "#fyp #fitcheck #sizechart #tryonhaul #tipsbelanja"
        ),
    },
]


def render_single_video(meta: dict) -> Path:
    out_path = CLIPS_OUT_DIR / meta["file_name"]
    source_file = RAW_DIR / meta["source"]
    vid_overlay_dir = OVERLAYS_DIR / meta["id"]

    hook_png = vid_overlay_dir / "hook.png"
    cta_png = vid_overlay_dir / "cta.png"

    # Build input arguments
    inputs = [
        "-ss", f"{meta['start']:.2f}",
        "-t", f"{meta['duration']:.2f}",
        "-i", str(source_file),
        "-i", str(hook_png),
        "-i", str(cta_png),
    ]

    for _, _, cap_file in meta["captions"]:
        inputs.extend(["-i", str(vid_overlay_dir / cap_file)])

    # Build filter_complex
    # 0 = video
    # 1 = hook
    # 2 = cta
    # 3..8 = cap_0..cap_5
    fc_parts = [
        # 1. Background blur
        "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=22:5[bg]",
        # 2. Foreground centered
        "[0:v]scale=-1:1920[fg]",
        "[bg][fg]overlay=(W-w)/2:(H-h)/2[base0]",
        # 3. Hook Card overlay with slide-down motion at 0.0s to 4.0s
        "[base0][1:v]overlay=x=0:y='if(lte(t,0.35), -350+350*sin(t/0.35*PI/2), 0)':enable='between(t,0,4.0)'[base1]",
        # 4. CTA overlay at 25.0s to 30.0s
        "[base1][2:v]overlay=x=0:y=0:enable='between(t,25.0,30.0)'[base2]",
    ]

    last_label = "base2"
    for idx, (cap_start, cap_end, _) in enumerate(meta["captions"]):
        input_idx = 3 + idx
        next_label = f"cap_out_{idx}"
        fc_parts.append(
            f"[{last_label}][{input_idx}:v]overlay=x=0:y=0:enable='between(t,{cap_start:.2f},{cap_end:.2f})'[{next_label}]"
        )
        last_label = next_label

    filter_complex_str = ";".join(fc_parts)

    cmd = [
        "ffmpeg", "-y",
        *inputs,
        "-filter_complex", filter_complex_str,
        "-map", f"[{last_label}]",
        "-map", "0:a?",
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
        str(out_path),
    ]

    t0 = time.time()
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
    dt = time.time() - t0
    size_mb = round(out_path.stat().st_size / (1024 * 1024), 2)
    print(f"  [DONE] {out_path.name} ({size_mb} MB) rendered in {dt:.1f}s")
    return out_path


def distribute_packages(rendered_files: list[tuple[dict, Path]]) -> None:
    channels_data = json.loads(CHANNELS_CFG.read_text(encoding="utf-8")).get("channels", [])
    active_channels = [c for c in channels_data if c.get("enabled", True)]

    batch_name = "marketing_batch_24nov"

    for ch in active_channels:
        ch_dir = READY_DIR / ch["id"] / batch_name
        ch_dir.mkdir(parents=True, exist_ok=True)

        manifest_items = []
        for idx, (meta, vid_path) in enumerate(rendered_files, start=1):
            dst_video = ch_dir / f"{batch_name}_{meta['id']}.mp4"
            shutil.copy2(vid_path, dst_video)

            # Generate channel-specific custom caption
            template = ch.get("caption_template", "{hook}\n\n{cta}\n\n{hashtags}")
            custom_caption = template.format(
                hook=meta["hook_title"],
                cta=ch.get("default_cta", "Cek keranjang kuning sekarang!"),
                hashtags=" ".join(ch.get("default_hashtags", ["#fyp", "#outfitpria"])),
            )

            caption_file = ch_dir / f"{batch_name}_{meta['id']}.caption.txt"
            caption_file.write_text(custom_caption.strip() + "\n", encoding="utf-8")

            manifest_items.append({
                "clip_id": meta["id"],
                "title": meta["title"],
                "video_file": dst_video.name,
                "caption_file": caption_file.name,
                "duration_seconds": meta["duration"],
            })

        manifest = {
            "batch": batch_name,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "channel": {
                "id": ch["id"],
                "name": ch["name"],
                "handle": ch["handle"],
            },
            "clips": manifest_items,
        }
        (ch_dir / "manifest.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"  [PACKAGE] Channel {ch['name']} ({ch['id']}): {len(manifest_items)} video siap upload di {ch_dir}")


def main() -> int:
    CLIPS_OUT_DIR.mkdir(parents=True, exist_ok=True)
    print("=== PROSES RENDERING 5 OUTPUT VIDEO MARKETING TIKTOK ===")
    print(f"Direktori Output: {CLIPS_OUT_DIR}\n")

    rendered = []
    for idx, meta in enumerate(CLIPS_METADATA, start=1):
        print(f"Rendering Video #{idx:02d}: {meta['title']}...")
        out_vid = render_single_video(meta)
        rendered.append((meta, out_vid))

    print("\n=== DISTRIBUSI PAKET KE CHANNEL TIKTOK ===")
    distribute_packages(rendered)

    # Optional Telegram Notification
    try:
        from scripts.notify_telegram import get_credentials, send_telegram_message, format_clipping_report
        token, chat_id = get_credentials()
        if token and chat_id:
            msg = format_clipping_report("marketing_batch_24nov", len(rendered), ["channel_utama", "channel_clipper_1"])
            send_telegram_message(msg, token, chat_id)
            print("  [TELEGRAM] Laporan clipping otomatis dikirim ke Telegram!")
    except Exception:
        pass

    print("\nSemua 5 video berhasil dibuat & paket upload siap!")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
