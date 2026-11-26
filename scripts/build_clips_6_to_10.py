#!/usr/bin/env python3
"""
Master Engine: Render 5 MORE DISTINCT Layout CTD Marketing Clips (Clips 6-10)
Output Directory: /Users/user/Movies/ClipperMarketing/26Nov/
Naming: CTD_Clip(6).mp4 .. CTD_Clip(10).mp4
Styles:
- Clip 6: Cyber Tech Slate & Corner Brackets (Titanium Slate, Neon Orange L-Brackets, Monospace Tag)
- Clip 7: Luxury Gold & Jet Black Executive Card (Jet Black, 2.5px Metallic Gold Border, Serif)
- Clip 8: Split Two-Tone Dual Card (Orange Top Band, Crisp White Body, Checkmark Header)
- Clip 9: Vibrant Sunset Gradient Glassmorphism (Crimson to Amber Gradient, Glowing Inner Rim)
- Clip 10: Editorial QC Inspection Ticket Stub (Japanese Linen Off-White, Circular QC Stamp)
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
ASSETS_DIR = ROOT_DIR / "assets" / "ctd_clips_6_10"
TARGET_OUT_DIR = Path("/Users/user/Movies/ClipperMarketing/26Nov")
READY_DIR = ROOT_DIR / "ready_to_upload"
CHANNELS_CFG = ROOT_DIR / "config" / "channels.json"

CLIPS_DATA = [
    {
        "id": "clip_06",
        "output_name": "CTD_Clip(6).mp4",
        "title": "Om Deddy Langsung Bungkus: Gua Ambil Satu Buat Gua Pake",
        "style_name": "Cyber Tech Slate & Corner Brackets",
        "start": 58.0,
        "duration": 20.0,
        "hook": "OM DEDDY LANGSUNG BUNGKUS: 'GUA AMBIL SATU BUAT GUA PAKE, INI LUAR BIASA!'",
        "cta": "🛒 AMBIL PROMONYA HARI INI • STOK MENIPIS!",
        "caption": (
            "Host Close The Door langsung bungkus di studio! 💥\n"
            "'Gua ambil satu buat gua pake, ini beneran luar biasa banget!' Pengakuan jujur tanpa script.\n\n"
            "Jangan sampai kehabisan size favoritmu, klik keranjang kuning sekarang! 🛒⚡\n\n"
            "#broguy #closethedoor #deddycorbuzier #kaosdistro #rekomendasipria #reviewjujur #fyp"
        ),
    },
    {
        "id": "clip_07",
        "output_name": "CTD_Clip(7).mp4",
        "title": "Om Deddy Bingung: Pabrik Lu Untung Dari Mana Jual 70 Ribuan",
        "style_name": "Luxury Gold & Jet Black Executive Card",
        "start": 30.0,
        "duration": 20.0,
        "hook": "OM DEDDY BINGUNG: 'PABRIK LU UNTUNG DARI MANA KALAU JUAL 70 RIBUAN?!'",
        "cta": "✦ KLAIM HARGA PABRIK 70 RIBUAN DI KERANJANG KUNING ✦",
        "caption": (
            "'Pabrik lu untung dari mana kalau jual 70 ribuan?!' Om Deddy kaget gak masuk akal! 😱\n"
            "Kualitas bahan tebal 24s premium standar distro mall, tapi langsung harga konveksi tangan pertama.\n\n"
            "Klaim voucher subsidi pabrik di keranjang kuning hari ini! 🛒✨\n\n"
            "#broguy #closethedoor #deddycorbuzier #hargagrosir #hargapabrik #kaospolos #fyp"
        ),
    },
    {
        "id": "clip_08",
        "output_name": "CTD_Clip(8).mp4",
        "title": "Kaos Murah Leher Melar? Yang Ini Ditarik Tetap Gak Melar",
        "style_name": "Split Two-Tone Dual Card",
        "start": 48.0,
        "duration": 20.0,
        "hook": "KAOS MURAH BIASANYA GAMPANG BELEL, TAPI YANG INI DITARIK TETAP GAK MELAR!",
        "cta": "🛒 ORDER KAOS ANTI-MELAR SEKARANG • GARANSI AWET!",
        "caption": (
            "Uji ketahanan kerah ekstrem di Close The Door! 💪\n"
            "Kaos biasa dicuci sekali kerah langsung belel? Broguy pakai double rib collar standar ekspor yang gak bakal melar.\n\n"
            "Solusi kaos awet bertahun-tahun, order sekarang di keranjang kuning! 🛒📦\n\n"
            "#broguy #closethedoor #deddycorbuzier #kaosantimelar #stresstest #tipskaos #fyp"
        ),
    },
    {
        "id": "clip_09",
        "output_name": "CTD_Clip(9).mp4",
        "title": "Dari Kuningan Jawa Barat Bikin Om Deddy Kagum Kualitasnya",
        "style_name": "Vibrant Sunset Gradient Glassmorphism",
        "start": 0.0,
        "duration": 20.0,
        "hook": "DARI KUNINGAN JAWA BARAT, BIKIN OM DEDDY KAGUM SAMA KUALITASNYA!",
        "cta": "🛒 DUKUNG BRAND LOKAL KEBANGGAAN • CEK PROMO HARI INI!",
        "caption": (
            "Karya anak bangsa dari Kuningan Jawa Barat berhasil taklukkan standar Om Deddy! 🇮🇩🔥\n"
            "Buktikan sendiri kalau produk lokal kita kualitasnya bisa bersaing dengan brand branded internasional.\n\n"
            "Bangga buatan Indonesia! Checkout sekarang di keranjang kuning! 🛒👕\n\n"
            "#broguy #closethedoor #deddycorbuzier #brandlokal #kuninganjawabarat #banggabuatanindonesia #fyp"
        ),
    },
    {
        "id": "clip_10",
        "output_name": "CTD_Clip(10).mp4",
        "title": "Review Jujur Om Deddy: Jahitannya Rapi Banget Bahan Adem",
        "style_name": "Editorial QC Inspection Ticket Stub",
        "start": 85.0,
        "duration": 20.0,
        "hook": "REVIEW JUJUR OM DEDDY: 'JAHITANNYA RAPI BANGET, BAHAN ADEM GAK GERAH!'",
        "cta": "🛒 CHECKOUT SEKARANG • JAMINAN KUALITAS & KEPUASAN 100%",
        "caption": (
            "Bedah kualitas detail kaos Broguy bareng Om Deddy! 🔍💯\n"
            "Jahitan kumis & overdeck rapi tanpa benang sisa, bahan katun adem, jatuh lemas di badan.\n\n"
            "Garansi puas 100%! Dapatkan warna favoritmu di keranjang kuning! 🛒⚡\n\n"
            "#broguy #closethedoor #deddycorbuzier #qualitycontrol #detailkaos #ootdindonesia #fyp"
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
        "-c:v", "libx264",
        "-preset", "fast",
        "-crf", "20",
        "-r", "30",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac",
        "-b:a", "192k",
        "-ar", "48000",
        str(out_file),
    ]

    print(f"🎬 Rendering {meta['output_name']} [{meta['style_name']}] ({meta['duration']}s)...")
    t0 = time.time()
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        print(f"❌ FFmpeg error on {meta['output_name']}:\n{res.stderr[-800:]}")
        sys.exit(1)
    
    elapsed = time.time() - t0
    size_mb = out_file.stat().st_size / (1024 * 1024)
    print(f"✅ Rendered {meta['output_name']} ({size_mb:.2f} MB) in {elapsed:.1f}s")
    return out_file


def distribute_to_channels(rendered_clips: list[dict]):
    batch_slug = "ctd_5_distinct_batch2_26nov"

    channels = ["channel_utama", "channel_clipper_1"]
    for ch_name in channels:
        ch_dir = READY_DIR / ch_name / batch_slug
        ch_dir.mkdir(parents=True, exist_ok=True)

        manifest = {
            "batch_id": batch_slug,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "channel": ch_name,
            "clips": []
        }

        for meta in rendered_clips:
            src_file = TARGET_OUT_DIR / meta["output_name"]
            dest_file = ch_dir / meta["output_name"]
            shutil.copy2(src_file, dest_file)

            caption_file = ch_dir / f"{meta['output_name']}.caption.txt"
            caption_file.write_text(meta["caption"], encoding="utf-8")

            manifest["clips"].append({
                "file": meta["output_name"],
                "title": meta["title"],
                "style_name": meta["style_name"],
                "duration": meta["duration"],
                "hook": meta["hook"],
                "cta": meta["cta"],
                "caption": meta["caption"]
            })

        manifest_file = ch_dir / "manifest.json"
        manifest_file.write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"📦 Staged {len(rendered_clips)} clips for {ch_name} -> {ch_dir}")


def main():
    TARGET_OUT_DIR.mkdir(parents=True, exist_ok=True)
    print("=" * 70)
    print("🚀 PRODUCING 5 MORE DISTINCT CTD MARKETING CLIPS (Clips 6 - 10)")
    print(f"📁 Target Output: {TARGET_OUT_DIR}")
    print("=" * 70)

    rendered = []
    for item in CLIPS_DATA:
        render_clip(item)
        rendered.append(item)

    print("\n📦 Distributing to multi-channel packages...")
    distribute_to_channels(rendered)

    print("\n🎉 ALL 5 NEW DISTINCT CLIPS RENDERED SUCCESSFULLY!")


if __name__ == "__main__":
    main()
