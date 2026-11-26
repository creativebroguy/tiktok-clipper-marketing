#!/usr/bin/env python3
"""
Batch Engine: Render 5 Varied High-Trust CTD Marketing Clips (9:16 Vertical 1080x1920)
Source: Close The Door Podcast (Deddy Corbuzier reviewing Broguy.id)
Style: 3-Zone Vertical Layout, Official White Logo, Speech Bubble Card, Brand Orange Highlights, TikTok -14 LUFS
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
ASSETS_DIR = ROOT_DIR / "assets" / "ctd_batch_5"
OUT_DIR = ROOT_DIR / "clips" / "ctd_batch_5"
READY_DIR = ROOT_DIR / "ready_to_upload"
CHANNELS_CFG = ROOT_DIR / "config" / "channels.json"

CLIPS_DATA = [
    {
        "id": "clip_01",
        "file_name": "ctd_01_local_pride_kuningan.mp4",
        "title": "Brand Lokal Asal Kuningan Yang Bikin Om Deddy Takjub",
        "start": 0.0,
        "duration": 21.0,
        "hook": "OM DEDDY KAGET: 'BRAND LOKAL DARI KUNINGAN, TAPI BAHANNYA BAGUS BANGET!'",
        "cta": "🛒 DUKUNG BRAND LOKAL • CEK KERANJANG KUNING SEKARANG!",
        "caption": (
            "Siapa sangka brand lokal asal Kuningan kualitas bahannya bisa bikin Om Deddy takjub di Close The Door! 🔥\n"
            "Potongan pas, bahan adem, dan jahitan standar distro premium.\n\n"
            "Dukung karya anak bangsa, klaim voucher diskon di keranjang kuning sekarang! 🛒⚡\n\n"
            "#broguy #closethedoor #deddycorbuzier #brandlokal #lokalpride #kaospria #fyp"
        ),
    },
    {
        "id": "clip_02",
        "file_name": "ctd_02_price_shock_70rb.mp4",
        "title": "Price Shock Kaos 70 Ribuan Kualitas Distro Mewah",
        "start": 25.0,
        "duration": 20.0,
        "hook": "OM DEDDY: 'SERIUSAN HARGA 70 RIBUAN? MURAH TAPI BAHANNYA BAGUS BANGET!'",
        "cta": "🛒 KLAIM VOUCHER DISKON DI KERANJANG KUNING SEKARANG!",
        "caption": (
            "Dengar harganya 70 ribuan, Om Deddy langsung kaget 'SERIUSAN?!' 😱\n"
            "Harga boleh terjangkau, tapi kualitas kain dan kerapian jahitannya bener-bener gak main-main.\n\n"
            "Mumpung stok promo masih ada, langsung checkout di keranjang kuning! 🛒✨\n\n"
            "#broguy #closethedoor #deddycorbuzier #kaosmurahberkualitas #outfitpria #fyp"
        ),
    },
    {
        "id": "clip_03",
        "file_name": "ctd_03_deddy_ambil_satu.mp4",
        "title": "Om Deddy Langsung Mau Ambil Satu Buat Dipake Sendiri",
        "start": 50.5,
        "duration": 20.0,
        "hook": "OM DEDDY: 'GUA AMBIL SATU BUAT GUA PAKE! BUAT 70 RIBU INI LUAR BIASA!'",
        "cta": "🛒 AMANKAN SIZE KAMU DI KERANJANG KUNING SEKARANG!",
        "caption": (
            "Gak ada settingan, Om Deddy langsung bilang 'Gua ambil satu nih entar gua pake!' 👏\n"
            "Buat harga 70 ribuan, kualitas kaos ini beneran luar biasa dan nyaman banget di badan.\n\n"
            "Pilih warna dan size favorit kamu di keranjang kuning sekarang! 🛒⚡\n\n"
            "#broguy #closethedoor #deddycorbuzier #rekomendasikaos #fashionpria #fyp"
        ),
    },
    {
        "id": "clip_04",
        "file_name": "ctd_04_the_gucci_test.mp4",
        "title": "The Gucci Test: Dikasih Brand Mewah Orang Pasti Percaya",
        "start": 75.0,
        "duration": 20.0,
        "hook": "'DIKASIH LOGO BRAND MEWAH GUCCI, ORANG JUGA PERCAYA! SAKING BAGUSNYA BAHAN INI!'",
        "cta": "🛒 DAPATKAN KUALITAS MEWAH DI KERANJANG KUNING!",
        "caption": (
            "Kata co-host: 'Kalau dikasih logo Gucci yang gede, orang juga percaya!' Saking mewahnya bahan ini! ⭐\n"
            "Kain tebal tapi jatuh lemas dan adem, gak kalah sama brand jutaan rupiah.\n\n"
            "Upgrade penampilan kamu tanpa bikin kantong jebol, klik keranjang kuning! 🛒🔥\n\n"
            "#broguy #closethedoor #deddycorbuzier #kualitasmewah #tipsfashion #fyp"
        ),
    },
    {
        "id": "clip_05",
        "file_name": "ctd_05_rekomendasi_jujur_tekstur.mp4",
        "title": "Rekomendasi Nyata: Pas Dipegang Bahannya Beneran Enak Banget",
        "start": 84.0,
        "duration": 20.0,
        "hook": "OM DEDDY: 'GUA GAK BOHONG, KETIKA DIPEGANG BAHANNYA ENAK BANGET!'",
        "cta": "🛒 BUKTIKAN SENDIRI DI KERANJANG KUNING SEKARANG!",
        "caption": (
            "'Gua gak bohong, ketika dipegang bahannya enak banget!' Review tulus dari Om Deddy. 💯\n"
            "Buktikan sendiri kenyamanan bahan kaos Broguy buat aktivitas harian kamu.\n\n"
            "Garansi puas! Order langsung di keranjang kuning sebelum kehabisan size! 🛒📦\n\n"
            "#broguy #closethedoor #deddycorbuzier #reviewjujur #kaosadem #ootdindo #fyp"
        ),
    },
]


def render_clip(meta: dict) -> Path:
    out_file = OUT_DIR / meta["file_name"]
    clip_assets = ASSETS_DIR / meta["id"]
    hook_png = clip_assets / "hook_card.png"
    cta_png = clip_assets / "cta_banner.png"

    cta_start = meta["duration"] - 4.0

    filter_complex = (
        "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=24:5,eq=brightness=-0.08:contrast=1.05[bg];"
        "[0:v]scale=1080:608[fg];"
        "[bg][fg]overlay=x=0:y=540[base];"
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
    batch_name = "ctd_batch_5"

    for ch in active_channels:
        ch_dir = READY_DIR / ch["id"] / batch_name
        ch_dir.mkdir(parents=True, exist_ok=True)

        manifest_items = []
        for meta, vid_path in rendered_files:
            dst_video = ch_dir / f"{batch_name}_{meta['id']}.mp4"
            shutil.copy2(vid_path, dst_video)

            caption_file = ch_dir / f"{batch_name}_{meta['id']}.caption.txt"
            caption_file.write_text(meta["caption"].strip() + "\n", encoding="utf-8")

            manifest_items.append({
                "clip_id": meta["id"],
                "title": meta["title"],
                "video_file": dst_video.name,
                "caption_file": caption_file.name,
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
        print(f"  [PACKAGE] {ch['name']}: 5 video siap upload di {ch_dir}")


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print("=== RENDERING 5 CTD HIGH-RETENTION MARKETING CLIPS ===")
    rendered = []
    for idx, meta in enumerate(CLIPS_DATA, start=1):
        print(f"Rendering Clip #{idx:02d}: {meta['title']} ({meta['duration']}s)...")
        out_path = render_clip(meta)
        rendered.append((meta, out_path))

    print("\n=== DISTRIBUSI PAKET KE READY_TO_UPLOAD ===")
    distribute(rendered)

    # Telegram Notification
    try:
        from scripts.notify_telegram import get_credentials, send_telegram_message, format_clipping_report
        token, chat_id = get_credentials()
        if token and chat_id:
            msg = format_clipping_report("ctd_batch_5", len(rendered), ["channel_utama", "channel_clipper_1"])
            send_telegram_message(msg, token, chat_id)
            print("  [TELEGRAM] Notifikasi laporan batch terkirim ke Telegram!")
    except Exception as e:
        print(f"  [TELEGRAM] Gagal kirim notifikasi: {e}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
