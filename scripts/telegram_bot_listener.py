#!/usr/bin/env python3
"""
Telegram Bot Listener & Command Executor
Menerima instruksi langsung dari Telegram User, merespons secepat mungkin,
dan mengeksekusi perintah tim (Ade, Uki, Flo) secara otomatis.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT_DIR = Path(__file__).resolve().parent.parent
DOTENV_PATH = ROOT_DIR / ".env"
LOGS_DIR = ROOT_DIR / "logs"
INSTRUCTIONS_LOG = LOGS_DIR / "telegram_instructions.jsonl"


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


def telegram_api(method: str, payload: dict[str, Any] | None = None, token: str | None = None) -> dict[str, Any]:
    bot_token, _ = get_credentials()
    bot_token = token or bot_token
    if not bot_token:
        raise ValueError("TELEGRAM_BOT_TOKEN belum diset di .env!")

    url = f"https://api.telegram.org/bot{bot_token}/{method}"
    cmd = [
        "curl",
        "-s",
        "-m",
        "35",
        "--http1.1",
        "-H",
        "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
    ]
    if payload is not None:
        cmd.extend(["-X", "POST", url, "-H", "Content-Type: application/json", "-d", json.dumps(payload)])
    else:
        cmd.extend(["-X", "GET", url])

    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        return {"ok": False, "error": f"curl error code {res.returncode}", "description": res.stderr}

    try:
        return json.loads(res.stdout)
    except Exception:
        return {"ok": False, "error": "invalid json", "raw": res.stdout}


def send_reply(chat_id: int | str, text: str, token: str | None = None) -> bool:
    resp = telegram_api("sendMessage", {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "HTML",
        "disable_web_page_preview": True,
    }, token=token)
    return bool(resp.get("ok"))


def handle_status_command() -> str:
    ready_dir = ROOT_DIR / "ready_to_upload"
    channels_ready = []
    if ready_dir.exists():
        for ch in ready_dir.iterdir():
            if ch.is_dir():
                batches = [b.name for b in ch.iterdir() if b.is_dir()]
                if batches:
                    channels_ready.append(f"  • <b>{ch.name}</b>: {len(batches)} batch")

    ready_str = "\n".join(channels_ready) if channels_ready else "  <i>Belum ada paket video baru</i>"

    return (
        "🤖 <b>[STATUS SISTEM TIKTOK CLIPPER MARKETING]</b>\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        "🟢 <b>Ade (Content Planner):</b> Siap analisa footage & hook\n"
        "🟢 <b>Uki (Video Editor):</b> Siap clip 9:16 (FFmpeg/Remotion/HyperFrames)\n"
        "🟢 <b>Flo (Admin Sosmed):</b> Siap distribusi multi-channel & upload\n\n"
        f"📦 <b>Paket Siap Upload:</b>\n{ready_str}\n\n"
        "Ketik <code>/help</code> untuk panduan instruksi cepat."
    )


def handle_help_command() -> str:
    return (
        "📖 <b>PANDUAN INSTRUKSI TELEGRAM</b>\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        "Anda bisa mengetik instruksi bebas atau menggunakan perintah berikut:\n\n"
        "• <code>/status</code> : Cek status tim & paket video\n"
        "• <code>/inspect &lt;file&gt;</code> : Cek durasi & metadata video footage\n"
        "• <code>/clip &lt;file&gt; &lt;segments&gt;</code> : Potong video langsung (contoh: <code>/clip video.mp4 00:00:05-00:00:25</code>)\n"
        "• <code>/dryrun &lt;batch&gt;</code> : Simulasi upload ke semua channel\n"
        "• <code>/upload &lt;batch&gt;</code> : Upload draft ke TikTok Creator Inbox\n\n"
        "<i>Atau ketik instruksi santai: 'Ade cari hook terbaik', 'Uki potong per 30 detik', dsb.</i>"
    )


def execute_system_instruction(user_text: str, chat_id: int | str, token: str) -> None:
    text = user_text.strip()
    cmd = text.split()[0].lower()

    # Log instruksi yang masuk
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    with INSTRUCTIONS_LOG.open("a", encoding="utf-8") as f:
        f.write(json.dumps({
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "chat_id": chat_id,
            "text": text,
        }) + "\n")

    if cmd == "/start":
        welcome = (
            "👋 <b>Halo! Bot Tim TikTok Clipper Marketing Aktif!</b>\n\n"
            "Semua instruksi yang Anda kirimkan ke sini akan langsung direspons dan dieksekusi oleh <b>Ade</b>, <b>Uki</b>, dan <b>Flo</b>.\n\n"
            "Ketik <code>/status</code> atau <code>/help</code> untuk memulai."
        )
        send_reply(chat_id, welcome, token)
        return

    if cmd == "/status":
        send_reply(chat_id, handle_status_command(), token)
        return

    if cmd == "/help":
        send_reply(chat_id, handle_help_command(), token)
        return

    if cmd == "/inspect":
        parts = text.split()
        if len(parts) < 2:
            send_reply(chat_id, "⚠️ Format salah. Contoh: <code>/inspect footage/video.mp4</code>", token)
            return
        target = ROOT_DIR / parts[1]
        if not target.exists():
            send_reply(chat_id, f"❌ File tidak ditemukan: <code>{parts[1]}</code>", token)
            return
        send_reply(chat_id, f"🔍 <b>Ade sedang menginspeksi:</b> <code>{target.name}</code>...", token)
        res = subprocess.run(["python3", str(ROOT_DIR / "scripts/clipper.py"), "inspect", str(target)], capture_output=True, text=True)
        if res.returncode == 0:
            send_reply(chat_id, f"📊 <b>Hasil Inspeksi:</b>\n<pre>{res.stdout[:1500]}</pre>", token)
        else:
            send_reply(chat_id, f"❌ Gagal inspect: {res.stderr}", token)
        return

    if cmd == "/dryrun":
        parts = text.split()
        if len(parts) < 2:
            send_reply(chat_id, "⚠️ Format salah. Contoh: <code>/dryrun nama_batch</code>", token)
            return
        batch = parts[1]
        send_reply(chat_id, f"🚀 <b>Flo sedang menjalankan dry-run untuk batch:</b> <code>{batch}</code>...", token)
        res = subprocess.run(["python3", str(ROOT_DIR / "scripts/upload_tiktok.py"), "--batch", batch, "--dry-run"], capture_output=True, text=True)
        send_reply(chat_id, f"📋 <b>Hasil Dry-Run:</b>\n<pre>{res.stdout[-1500:] if res.stdout else res.stderr}</pre>", token)
        return

    # Natural Language Instruction Handling
    ack_msg = (
        f"⚡ <b>Instruksi Diterima!</b>\n"
        f"<i>\"{text}\"</i>\n\n"
        "Perintah telah dicatat dan didelegasikan ke tim marketing. Menjalankan penanganan secepat mungkin..."
    )
    send_reply(chat_id, ack_msg, token)


def run_polling_loop(poll_interval: int = 2) -> None:
    token, authorized_chat = get_credentials()
    if not token:
        print("Error: TELEGRAM_BOT_TOKEN belum diset di .env!", file=sys.stderr)
        sys.exit(1)

    print(f"[{datetime.now().strftime('%H:%M:%S')}] Telegram Bot Listener dimulai...")
    last_update_id = 0

    while True:
        try:
            params: dict[str, Any] = {"timeout": 10, "limit": 10}
            if last_update_id > 0:
                params["offset"] = last_update_id + 1

            data = telegram_api("getUpdates", params, token=token)
            if not data.get("ok"):
                retry_sec = data.get("parameters", {}).get("retry_after", 5)
                time.sleep(retry_sec)
                continue

            results = data.get("result", [])
            for update in results:
                uid = update.get("update_id", 0)
                if uid > last_update_id:
                    last_update_id = uid

                msg = update.get("message") or update.get("channel_post")
                if not msg:
                    continue

                from_chat = msg.get("chat", {}).get("id")
                text = msg.get("text", "").strip()

                if not text:
                    continue

                # Keamanan: Hanya eksekusi jika dikirim oleh Chat ID terotorisasi (jika sudah diset)
                if authorized_chat and str(from_chat) != str(authorized_chat):
                    print(f"Abaikan pesan dari chat tak dikenal: {from_chat}")
                    continue

                print(f"[{datetime.now().strftime('%H:%M:%S')}] Pesan diterima dari {from_chat}: {text}")
                execute_system_instruction(text, from_chat, token)

        except Exception as exc:
            print(f"Error loop: {exc}", file=sys.stderr)
            time.sleep(3)

        time.sleep(poll_interval)


if __name__ == "__main__":
    run_polling_loop()
