#!/usr/bin/env python3
"""
TikTok Multi-Channel Uploader (TikTok Content Posting API v2)

Mendukung:
- --dry-run : validasi paket, file video, caption, dan ketersediaan token tanpa upload.
- --mode inbox  : upload ke TikTok Creator Inbox sebagai draft (disarankan).
- --mode direct : publish langsung (membutuhkan izin Direct Post di TikTok Developer App).

Kredensial token dibaca dari environment variable atau file .env lokal.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT_DIR = Path(__file__).resolve().parent.parent
READY_DIR = ROOT_DIR / "ready_to_upload"
LOGS_DIR = ROOT_DIR / "logs"

TIKTOK_API_BASE = "https://open.tiktokapis.com"
CHUNK_SIZE_BYTES = 10 * 1024 * 1024  # 10 MB


def load_dotenv(dotenv_path: Path) -> None:
    if not dotenv_path.exists():
        return
    for line in dotenv_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, val = line.split("=", 1)
        key = key.strip()
        val = val.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = val


def api_post_json(url: str, token: str, payload: dict[str, Any]) -> dict[str, Any]:
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json; charset=UTF-8",
        },
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def upload_video_chunks(upload_url: str, video_path: Path) -> None:
    total_size = video_path.stat().st_size
    chunk_size = min(CHUNK_SIZE_BYTES, total_size)
    offset = 0
    with video_path.open("rb") as f:
        while offset < total_size:
            data = f.read(chunk_size)
            if not data:
                break
            end = offset + len(data) - 1
            req = urllib.request.Request(
                upload_url,
                data=data,
                method="PUT",
                headers={
                    "Content-Type": "video/mp4",
                    "Content-Length": str(len(data)),
                    "Content-Range": f"bytes {offset}-{end}/{total_size}",
                },
            )
            with urllib.request.urlopen(req, timeout=180) as resp:
                if resp.status not in (200, 201, 206):
                    raise RuntimeError(f"Chunk upload gagal dengan status HTTP {resp.status}")
            offset += len(data)


def upload_single_clip(
    token: str,
    video_path: Path,
    caption: str,
    mode: str,
    privacy_level: str,
) -> dict[str, Any]:
    total_size = video_path.stat().st_size
    chunk_size = min(CHUNK_SIZE_BYTES, total_size)
    total_chunks = (total_size + chunk_size - 1) // chunk_size

    source_info = {
        "source": "FILE_UPLOAD",
        "video_size": total_size,
        "chunk_size": chunk_size,
        "total_chunk_count": total_chunks,
    }

    if mode == "inbox":
        endpoint = f"{TIKTOK_API_BASE}/v2/post/publish/inbox/video/init/"
        payload: dict[str, Any] = {"source_info": source_info}
    elif mode == "direct":
        endpoint = f"{TIKTOK_API_BASE}/v2/post/publish/video/init/"
        payload = {
            "post_info": {
                "title": caption[:2200],
                "privacy_level": privacy_level,
                "disable_duet": False,
                "disable_comment": False,
                "disable_stitch": False,
            },
            "source_info": source_info,
        }
    else:
        raise ValueError(f"Mode upload tidak dikenal: {mode}")

    init_resp = api_post_json(endpoint, token, payload)
    error = init_resp.get("error", {})
    if error.get("code") not in (None, "ok"):
        raise RuntimeError(f"TikTok init error: {error}")

    data = init_resp.get("data", {})
    upload_url = data.get("upload_url")
    publish_id = data.get("publish_id")
    if not upload_url:
        raise RuntimeError(f"upload_url tidak ditemukan pada respons TikTok: {init_resp}")

    upload_video_chunks(upload_url, video_path)
    return {"publish_id": publish_id, "mode": mode, "status": "uploaded"}


def discover_manifests(batch: str, channel_filter: set[str] | None) -> list[Path]:
    manifests: list[Path] = []
    if not READY_DIR.exists():
        return manifests
    for ch_dir in sorted(READY_DIR.iterdir()):
        if not ch_dir.is_dir():
            continue
        if channel_filter and ch_dir.name not in channel_filter:
            continue
        m_path = ch_dir / batch / "manifest.json"
        if m_path.exists():
            manifests.append(m_path)
    return manifests


def main() -> int:
    parser = argparse.ArgumentParser(description="Upload batch clip ke multi-channel TikTok")
    parser.add_argument("--batch", required=True, help="Nama batch di ready_to_upload/<channel>/<batch>/")
    parser.add_argument("--channels", help="Opsional: filter channel ID (pisahkan koma)")
    parser.add_argument("--mode", choices=["inbox", "direct"], help="Override mode upload dari manifest")
    parser.add_argument(
        "--privacy",
        default="SELF_ONLY",
        choices=["PUBLIC_TO_EVERYONE", "MUTUAL_FOLLOW_FRIENDS", "FOLLOWER_OF_CREATOR", "SELF_ONLY"],
        help="Level privasi khusus untuk --mode direct (default: SELF_ONLY agar aman)",
    )
    parser.add_argument("--dry-run", action="store_true", help="Validasi saja tanpa mengirim ke API TikTok")
    args = parser.parse_args()

    load_dotenv(ROOT_DIR / ".env")
    channel_filter = {c.strip() for c in args.channels.split(",") if c.strip()} if args.channels else None
    manifests = discover_manifests(args.batch, channel_filter)

    if not manifests:
        print(f"Error: tidak ditemukan manifest untuk batch '{args.batch}' di {READY_DIR}", file=sys.stderr)
        return 1

    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    report: dict[str, Any] = {
        "batch": args.batch,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "dry_run": args.dry_run,
        "results": [],
    }

    for m_path in manifests:
        manifest = json.loads(m_path.read_text(encoding="utf-8"))
        ch = manifest["channel"]
        ch_id = ch["id"]
        token_var = ch.get("token_env_var") or ""
        token = os.environ.get(token_var, "").strip()
        mode = args.mode or ch.get("upload_mode", "inbox")
        batch_dir = m_path.parent

        print(f"\n=== Channel: {ch['name']} ({ch['handle']}) [mode={mode}] ===")
        for clip in manifest.get("clips", []):
            video_path = batch_dir / clip["video_file"]
            caption_path = batch_dir / clip["caption_file"]
            caption = caption_path.read_text(encoding="utf-8").strip() if caption_path.exists() else ""

            if not video_path.exists():
                msg = f"File video hilang: {video_path}"
                print(f"  [ERROR] {msg}")
                report["results"].append({"channel_id": ch_id, "video": clip["video_file"], "status": "missing_file"})
                continue

            size_mb = round(video_path.stat().st_size / (1024 * 1024), 2)
            if args.dry_run:
                token_state = "OK (token terisi)" if token else f"BELUM DISET ({token_var})"
                print(
                    f"  [DRY-RUN] {video_path.name} ({size_mb} MB, {clip['duration_seconds']}s) | "
                    f"Token: {token_state} | Caption: {len(caption)} chars"
                )
                report["results"].append(
                    {
                        "channel_id": ch_id,
                        "video": video_path.name,
                        "size_mb": size_mb,
                        "token_ready": bool(token),
                        "status": "dry_run_ok",
                    }
                )
                continue

            if not token:
                print(f"  [SKIP] Token belum diset pada environment variable '{token_var}'")
                report["results"].append(
                    {"channel_id": ch_id, "video": video_path.name, "status": "skipped_missing_token"}
                )
                continue

            try:
                res = upload_single_clip(token, video_path, caption, mode, args.privacy)
                print(f"  [UPLOADED] {video_path.name} -> publish_id={res['publish_id']}")
                report["results"].append(
                    {"channel_id": ch_id, "video": video_path.name, **res}
                )
            except (urllib.error.URLError, RuntimeError) as exc:
                print(f"  [FAILED] {video_path.name}: {exc}", file=sys.stderr)
                report["results"].append(
                    {"channel_id": ch_id, "video": video_path.name, "status": "failed", "error": str(exc)}
                )

    log_file = LOGS_DIR / f"upload_{args.batch}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    log_file.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nLog disimpan ke: {log_file}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
