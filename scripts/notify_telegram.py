#!/usr/bin/env python3
"""
Telegram Notification Engine for TikTok Clipper Marketing Team
Mengirim laporan dari Ade (Planning), Uki (Clipping/Editor), dan Flo (Uploader/Admin)
langsung ke Telegram pribadi atau grup melalui Telegram Bot API.

Hanya menggunakan Python 3 stdlib (urllib + json).
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Any

ROOT_DIR = Path(__file__).resolve().parent.parent
DOTENV_PATH = ROOT_DIR / ".env"


def load_dotenv(path: Path) -> None:
    if not path.exists():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, val = line.split("=", 1)
        key = key.strip()
        val = val.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = val


def get_credentials() -> tuple[str, str]:
    load_dotenv(DOTENV_PATH)
    token = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
    chat_id = os.environ.get("TELEGRAM_CHAT_ID", "").strip()
    return token, chat_id


def send_telegram_message(
    text: str,
    token: str | None = None,
    chat_id: str | None = None,
    parse_mode: str = "HTML",
) -> dict[str, Any]:
    env_token, env_chat_id = get_credentials()
    bot_token = token or env_token
    target_chat = chat_id or env_chat_id

    if not bot_token:
        raise ValueError("TELEGRAM_BOT_TOKEN belum diset di .env atau environment!")
    if not target_chat:
        raise ValueError("TELEGRAM_CHAT_ID belum diset di .env atau environment!")

    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {
        "chat_id": int(target_chat) if str(target_chat).lstrip("-").isdigit() else target_chat,
        "text": text,
        "parse_mode": parse_mode,
        "disable_web_page_preview": True,
    }

    body = json.dumps(payload)
    cmd = [
        "curl",
        "-s",
        "-m",
        "15",
        "--http1.1",
        "-X",
        "POST",
        url,
        "-H",
        "Content-Type: application/json",
        "-d",
        body,
    ]

    max_attempts = 2
    for attempt in range(max_attempts):
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode != 0:
            raise RuntimeError(f"Gagal memanggil Telegram curl (code {res.returncode}): {res.stderr}")

        try:
            data = json.loads(res.stdout)
        except Exception:
            raise RuntimeError(f"Respons Telegram tidak valid: {res.stdout}")

        if data.get("ok"):
            return data

        retry = data.get("parameters", {}).get("retry_after")
        if retry and attempt < max_attempts - 1:
            print(f"  [TELEGRAM] Menunggu cooldown aktivasi {retry + 1} detik...")
            time.sleep(retry + 1)
            continue

        err_desc = data.get("description", str(data))
        if retry:
            raise RuntimeError(f"Telegram Rate Limit (429): Tunggu {retry} detik lagi.")
        raise RuntimeError(f"Telegram API Error: {err_desc}")

    return {}


def fetch_recent_chat_id(token: str | None = None) -> list[dict[str, Any]]:
    env_token, _ = get_credentials()
    bot_token = token or env_token
    if not bot_token:
        raise ValueError("TELEGRAM_BOT_TOKEN belum diisi!")

    url = f"https://api.telegram.org/bot{bot_token}/getUpdates"
    req = urllib.request.Request(url, method="GET")
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read().decode("utf-8"))
        results = data.get("result", [])
        chats = []
        seen = set()
        for item in results:
            msg = item.get("message") or item.get("channel_post") or {}
            chat = msg.get("chat", {})
            c_id = chat.get("id")
            if c_id and c_id not in seen:
                seen.add(c_id)
                chats.append({
                    "id": c_id,
                    "type": chat.get("type"),
                    "first_name": chat.get("first_name", ""),
                    "username": chat.get("username", ""),
                    "title": chat.get("title", ""),
                })
        return chats


def format_clipping_report(batch_name: str, total_clips: int, channels: list[str]) -> str:
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    ch_list = "\n".join([f"  • <code>{ch}</code>" for ch in channels])
    return (
        f"🎬 <b>[LAPORAN UKI - VIDEO CLIPPING]</b>\n"
        f"━━━━━━━━━━━━━━━━━━━\n"
        f"<b>Batch:</b> <code>{batch_name}</code>\n"
        f"<b>Waktu:</b> {now_str}\n"
        f"<b>Jumlah Klip:</b> {total_clips} video (9:16 vertikal)\n"
        f"<b>Format:</b> 1080x1920 | 30 FPS | Normalisasi -14 LUFS\n\n"
        f"<b>Didistribusikan ke Channel:</b>\n{ch_list}\n\n"
        f"<i>Status: Paket video + caption siap direview di ready_to_upload/</i>"
    )


def format_upload_report(log_data: dict[str, Any]) -> str:
    batch = log_data.get("batch", "Unknown")
    is_dry = log_data.get("dry_run", False)
    status_tag = "SIMULASI (DRY-RUN)" if is_dry else "PUBLIKASI RESMI"
    results = log_data.get("results", [])

    items_text = []
    for r in results:
        ch = r.get("channel_id", "N/A")
        vid = r.get("video", "N/A")
        st = r.get("status", "unknown")
        pub_id = r.get("publish_id")
        pub_info = f" (ID: <code>{pub_id}</code>)" if pub_id else ""
        icon = "✅" if "ok" in st.lower() or "uploaded" in st.lower() else "⚠️"
        items_text.append(f"{icon} <b>{ch}</b>: <code>{vid}</code> → <i>{st}</i>{pub_info}")

    body = "\n".join(items_text) if items_text else "Tidak ada klip."
    return (
        f"🚀 <b>[LAPORAN FLO - TIKTOK UPLOAD]</b>\n"
        f"━━━━━━━━━━━━━━━━━━━\n"
        f"<b>Batch:</b> <code>{batch}</code>\n"
        f"<b>Mode:</b> {status_tag}\n"
        f"<b>Total Klip Diproses:</b> {len(results)}\n\n"
        f"<b>Detail Channel:</b>\n{body}\n\n"
        f"<i>Semua log tersimpan otomatis di logs/</i>"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Telegram Reporter untuk TikTok Clipper Marketing")
    parser.add_argument("--test", action="store_true", help="Kirim pesan uji coba ke Telegram")
    parser.add_argument("--get-chat-id", action="store_true", help="Ambil Chat ID otomatis dari pesan /start terakhir")
    parser.add_argument("--message", help="Kirim pesan teks kustom ke Telegram")
    parser.add_argument("--report-upload-log", help="Kirim laporan dari file log JSON upload")
    parser.add_argument("--batch-clipped", help="Nama batch yang baru saja selesai dipotong")
    parser.add_argument("--clips-count", type=int, default=1, help="Jumlah klip dalam batch")
    parser.add_argument("--channels", help="Daftar channel (pisahkan koma)")

    args = parser.parse_args()
    token, chat_id = get_credentials()

    if args.get_chat_id:
        if not token:
            print("Error: TELEGRAM_BOT_TOKEN belum diset di .env!", file=sys.stderr)
            return 1
        print("Mengecek pesan masuk di Telegram Bot...")
        chats = fetch_recent_chat_id(token)
        if not chats:
            print("Belum ada pesan masuk. Silakan buka bot Anda di Telegram dan klik tombol 'Start' atau ketik /start.")
            return 1
        print("Ditemukan Chat ID berikut:")
        for c in chats:
            name = c.get("first_name") or c.get("title") or c.get("username") or "User"
            print(f"  • ID: {c['id']} | Nama: {name} (Tipe: {c['type']})")
        print("\nSilakan salin ID di atas dan masukkan ke .env sebagai TELEGRAM_CHAT_ID=<ID>")
        return 0

    if args.test:
        if not token or not chat_id:
            print(f"Error: Token atau Chat ID belum diset!\nToken: {'OK' if token else 'KOSONG'}, Chat ID: {'OK' if chat_id else 'KOSONG'}", file=sys.stderr)
            return 1
        msg = (
            "🔔 <b>Test Notifikasi Tim TikTok Clipper Marketing</b>\n\n"
            "Bot Telegram berhasil terkoneksi dengan project Anda!\n"
            "Semua report dari <b>Ade</b> (Planner), <b>Uki</b> (Editor), dan <b>Flo</b> (Admin) akan dikirimkan ke sini secara otomatis."
        )
        try:
            res = send_telegram_message(msg)
            print(f"Sukses mengirim test notifikasi ke Telegram (Message ID: {res.get('result', {}).get('message_id')})!")
            return 0
        except Exception as e:
            print(f"Gagal mengirim pesan: {e}", file=sys.stderr)
            return 1

    if args.message:
        try:
            send_telegram_message(args.message)
            print("Pesan berhasil terkirim ke Telegram!")
            return 0
        except Exception as e:
            print(f"Gagal: {e}", file=sys.stderr)
            return 1

    if args.report_upload_log:
        log_path = Path(args.report_upload_log)
        if not log_path.exists():
            print(f"File log tidak ditemukan: {log_path}", file=sys.stderr)
            return 1
        data = json.loads(log_path.read_text(encoding="utf-8"))
        report_text = format_upload_report(data)
        try:
            send_telegram_message(report_text)
            print("Laporan upload berhasil dikirim ke Telegram!")
            return 0
        except Exception as e:
            print(f"Peringatan: Gagal mengirim laporan ke Telegram: {e}", file=sys.stderr)
            return 1

    if args.batch_clipped:
        chs = [c.strip() for c in (args.channels or "").split(",") if c.strip()]
        report_text = format_clipping_report(args.batch_clipped, args.clips_count, chs)
        try:
            send_telegram_message(report_text)
            print("Laporan clipping berhasil dikirim ke Telegram!")
            return 0
        except Exception as e:
            print(f"Peringatan: Gagal mengirim laporan ke Telegram: {e}", file=sys.stderr)
            return 1

    parser.print_help()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
