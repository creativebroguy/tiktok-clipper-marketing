#!/usr/bin/env python3
"""
Batch Engine: Render 5 CTD Newsroom Broadcast Clips (9:16 Vertical 1080x1920)
Output Directory: /Users/user/Movies/ClipperMarketing/26Nov/
Naming: CTD_Clip(1).mp4 .. CTD_Clip(5).mp4
Style: Newsroom Broadcast Overlay, Dark Graphite Container, Dot Matrix, Official Logo, TikTok -14 LUFS
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

RAW_VIDEO = ROOT_DIR / "footage" / "ctd_gdrive" / "raw_ctd_source.mp4"
ASSETS_DIR = ROOT_DIR / "assets" / "ctd_newsroom"
TARGET_OUT_DIR = Path("/Users/user/Movies/ClipperMarketing/26Nov")
READY_DIR = ROOT_DIR / "ready_to_upload"
CHANNELS_CFG = ROOT_DIR / "config" / "channels.json"

CLIPS_DATA = [
    {
        "id": "clip_01",
        "output_name": "CTD_Clip(1).mp4",
        "title": "Om Deddy Gak Bakal Mau Pakai Kaos Kaleng-Kaleng",
        "start": 0.0,
        "duration": 21.0,
        "hook": "OM DEDDY: 'GUE GAK BAKAL MAU PAKE KAOS KALENG-KALENG!'",
        "cta": "🛒 CEK KERANJANG KUNING SEKARANG • STOK TERBATAS!",
        "caption": (
            "Om Deddy tegas: 'Gue gak bakal mau pake kaos kaleng-kaleng!' 💥\n"
            "Brand lokal asal Kuningan ini membuktikan kalau kaos terjangkau bisa punya kualitas distro juara.\n\n"
            "Buktikan sendiri kenyamanannya, klaim voucher diskon di keranjang kuning! 🛒⚡\n\n"
            "#broguy #closethedoor #deddycorbuzier #kaospria #brandlokal #kualitasdistro #fyp"
        ),
    },
    {
        "id": "clip_02",
        "output_name": "CTD_Clip(2).mp4",
        "title": "Om Deddy Kaget: Harga Sama Bahannya Gak Logis",
        "start": 25.0,
        "duration": 20.0,
        "hook": "OM DEDDY KAGET: 'HARGA SAMA BAHANNYA GAK LOGIS!'",
        "cta": "🛒 KLAIM VOUCHER DISKON DI KERANJANG KUNING SEKARANG!",
        "caption": (
            "Dengar harga 70 ribuan, Om Deddy kaget: 'Harga sama bahannya gak logis!' 😱\n"
            "Bahan tebal, adem, dan jahitan super rapi standar pakaian jutaan rupiah.\n\n"
            "Stok promo terbatas, checkout size kamu di keranjang kuning sekarang! 🛒✨\n\n"
            "#broguy #closethedoor #deddycorbuzier #hargamurahkualitasmewah #outfitcowok #fyp"
        ),
    },
    {
        "id": "clip_03",
        "output_name": "CTD_Clip(3).mp4",
        "title": "Deddy Corbuzier: Gue Tarik Sekuat Tenaga Kerahnya Gak Melar",
        "start": 45.0,
        "duration": 20.0,
        "hook": "DEDDY CORBUZIER: 'GUE TARIK SEKUAT TENAGA, KERAHNYA GAK MELAR!'",
        "cta": "🛒 AMANKAN SIZE KAMU DI KERANJANG KUNING SEKARANG!",
        "caption": (
            "Stress-test kerah langsung di depan kamera Close The Door! 💪\n"
            "Ditarik sekuat tenaga sama Om Deddy, kerahnya tetap kokoh dan gak gampang belel.\n\n"
            "Solusi kaos awet bertahun-tahun, order sekarang di keranjang kuning! 🛒📦\n\n"
            "#broguy #closethedoor #deddycorbuzier #kaosantimelar #stresstest #rekomendasikaos #fyp"
        ),
    },
    {
        "id": "clip_04",
        "output_name": "CTD_Clip(4).mp4",
        "title": "Seriusan 70 Ribu? Gila Sih Bagus Banget",
        "start": 58.0,
        "duration": 20.0,
        "hook": "'SERIUSAN 70 RIBU? GILA SIH BAGUS BANGET!'",
        "cta": "🛒 BUKTIKAN SENDIRI DI KERANJANG KUNING SEKARANG!",
        "caption": (
            "'Seriusan 70 ribu? Gila sih bagus banget! Bahannya guys luar biasa!' 🔥\n"
            "Bukan sekadar kata-kata, Om Deddy langsung jatuh cinta sama kualitas bahan kaos Broguy.\n\n"
            "Jangan sampai kehabisan voucher diskon, klik keranjang kuning sekarang! 🛒⚡\n\n"
            "#broguy #closethedoor #deddycorbuzier #kaospriaadem #racuntiktok #fyp"
        ),
    },
    {
        "id": "clip_05",
        "output_name": "CTD_Clip(5).mp4",
        "title": "Om Deddy: Gua Gak Bohong, Bahannya Enak Banget",
        "start": 82.0,
        "duration": 20.0,
        "hook": "OM DEDDY: 'GUA GAK BOHONG, BAHANNYA ENAK BANGET!'",
        "cta": "🛒 DAPATKAN KUALITAS MEWAH DI KERANJANG KUNING!",
        "caption": (
            "'Gua gak bohong ketika dipegang bahannya enak banget!' Review jujur tanpa endorse basa-basi. 💯\n"
            "Kain katun premium lembut, sejuk dipakai seharian bahkan saat cuaca panas.\n\n"
            "Garansi puas! Langsung amankan koleksi Broguy di keranjang kuning! 🛒👕\n\n"
            "#broguy #closethedoor #deddycorbuzier #reviewjujur #kaosdistro #ootdindo #fyp"
        ),
    },
]


def render_clip(meta: dict) -> Path:
    out_file = TARGET_OUT_DIR / meta["output_name"]
    clip_assets = ASSETS_DIR / meta["id"]
    hook_png = clip_assets / "hook_card.png"
    cta_png = clip_assets / "cta_banner.png"

    cta_start = meta["duration"] - 4.0

    filter_complex = (
        "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=26:5,eq=brightness=-0.10:contrast=1.06[bg];"
        "[0:v]scale=1080:608[fg];"
        "[bg][fg]overlay=x=0:y=520[base];"
        "[base][1:v]overlay=x=0:y='if(lte(t,0.35), 80*(1-sin(t/0.35*PI/2)), 0)'[v_hook];"
        f"[v_hook][2:v]overlay=x=0:y='if(lte(t-{cta_start:.2f},0.3), 120*(1-sin((t-{cta_start:.2f})/0.3*PI/2)), 0)':enable='between(t,{cta_start:.2f},{meta['duration']:.2f})'[v_out]"
    )

    cmd = [
        "ffmpeg", "-y",
        "-ss", f"{meta['start']:.2f}",
        "-t", f"{meta['duration']:.2f}",
        "-i", str(RAW_VIDEO),
        "-i", str(hook_png),
        "-i", str(cta_png),
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
        str(out_file),
    ]

    t0 = time.time()
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
    dt = time.time() - t0
    size_mb = round(out_file.stat().st_size / (1024 * 1024), 2)
    print(f"  [DONE] {out_file.name} ({size_mb} MB) rendered in {dt:.1f}s")
    return out_file


def distribute(rendered_files: list[tuple[dict, Path]]) -> None:
    channels_data = json.loads(CHANNELS_CFG.read_text(encoding="utf-8")).get("channels", [])
    active_channels = [c for c in channels_data if c.get("enabled", True)]
    batch_name = "ctd_newsroom_26nov"

    for ch in active_channels:
        ch_dir = READY_DIR / ch["id"] / batch_name
        ch_dir.mkdir(parents=True, exist_ok=True)

        manifest_items = []
        for meta, vid_path in rendered_files:
            dst_video = ch_dir / meta["output_name"]
            shutil.copy2(vid_path, dst_video)

            caption_file = ch_dir / f"{meta['output_name']}.caption.txt"
            caption_file.write_text(meta["caption"].strip() + "\n", encoding="utf-8")

            manifest_items.append({
                "clip_id": meta["id"],
                "file_name": meta["output_name"],
                "title": meta["title"],
                "duration_seconds": meta["duration"],
                "hook": meta["hook"],
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
        print(f"  [PACKAGE] {ch['name']}: {len(manifest_items)} video siap upload di {ch_dir}")


def main() -> int:
    TARGET_OUT_DIR.mkdir(parents=True, exist_ok=True)
    print("=== RENDERING 5 CTD NEWSROOM MARKETING CLIPS (26NOV) ===")
    print(f"Destination: {TARGET_OUT_DIR}\n")

    rendered = []
    for idx, meta in enumerate(CLIPS_DATA, start=1):
        print(f"Rendering Clip #{idx:02d}: {meta['output_name']} ({meta['duration']}s)...")
        out_path = render_clip(meta)
        rendered.append((meta, out_path))

    print("\n=== DISTRIBUSI PAKET KE READY_TO_UPLOAD ===")
    distribute(rendered)

    # Telegram Notification
    try:
        from scripts.notify_telegram import get_credentials, send_telegram_message, format_clipping_report
        token, chat_id = get_credentials()
        if token and chat_id:
            msg = format_clipping_report("ctd_newsroom_26nov", len(rendered), ["channel_utama", "channel_clipper_1"])
            send_telegram_message(msg, token, chat_id)
            print("  [TELEGRAM] Notifikasi laporan batch terkirim ke Telegram!")
    except Exception as e:
        print(f"  [TELEGRAM] Gagal kirim notifikasi: {e}")

    print(f"\nSemua 5 video berhasil dirender ke {TARGET_OUT_DIR}!")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
