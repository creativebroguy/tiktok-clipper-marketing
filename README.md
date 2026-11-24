# TikTok Video Clipper Marketing

Workspace terstruktur untuk tim **Video Clipper Marketing**: mengubah footage mentah menjadi clip vertikal TikTok (`9:16`) secara otomatis dan menyiapkan / mengupload distribusi ke semua channel TikTok yang Anda miliki.

## Struktur Folder

```text
tiktok-clipper-marketing/
├── footage/                  # Simpan footage mentah Anda di sini
├── assets/                   # Logo/watermark, intro/outro, atau file .srt subtitle
├── clips/                    # Hasil potongan video mentah per batch
├── ready_to_upload/          # Paket siap upload per channel (video + caption + manifest)
├── config/
│   ├── channels.json         # Daftar semua channel TikTok & aturan konten masing-masing
│   └── clip_presets.json     # Preset resolusi, durasi, audio, dan gaya framing 9:16
├── scripts/
│   ├── clipper.py            # Engine pemotong & converter 9:16 (FFmpeg + Python stdlib)
│   └── upload_tiktok.py      # Uploader multi-channel via TikTok Content Posting API v2
├── docs/
│   └── TEAM_WORKFLOW.md      # SOP & pembagian role tim clipper marketing
├── logs/                     # Log hasil clipping & riwayat upload
└── .env.example              # Template kredensial token per channel TikTok
```

## Cara Pakai Cepat

### 1. Daftarkan Channel TikTok Anda
Edit [config/channels.json](config/channels.json) dan tambahkan semua channel TikTok yang Anda kelola (nama channel, handle, hashtag default, tone caption, dan mode upload).

### 2. Masukkan Footage Video
Taruh file video mentah (`.mp4`, `.mov`, `.mkv`) ke folder `footage/`.

### 3. Cek Info Video
```bash
python3 scripts/clipper.py inspect footage/video_anda.mp4
```

### 4. Potong & Siapkan Paket Semua Channel
- **Potong berdasarkan timestamp pilihan (disarankan untuk hook terbaik):**
  ```bash
  python3 scripts/clipper.py clip \
    --input footage/video_anda.mp4 \
    --segments "00:00:05-00:00:25,00:00:40-00:01:05" \
    --fit crop \
    --batch promo_batch_01
  ```
- **Potong otomatis per 30 detik:**
  ```bash
  python3 scripts/clipper.py clip \
    --input footage/video_anda.mp4 \
    --chunk-seconds 30 \
    --fit blur \
    --batch promo_batch_01
  ```

Hasil potongan akan tersimpan di `clips/<batch>/` dan paket siap upload per channel otomatis dibuat di `ready_to_upload/<channel_id>/<batch>/` lengkap dengan `caption.txt` dan `manifest.json`.

### 5. Upload ke Semua Channel TikTok
- **Validasi dulu (Dry Run):**
  ```bash
  python3 scripts/upload_tiktok.py --batch promo_batch_01 --dry-run
  ```
- **Upload resmi via TikTok Content Posting API (Inbox Draft):**
  Salin `.env.example` menjadi `.env`, isi access token OAuth tiap channel, lalu jalankan:
  ```bash
  python3 scripts/upload_tiktok.py --batch promo_batch_01 --mode inbox
  ```

## Notifikasi Otomatis ke Telegram

Setiap hasil kerja tim (**Ade** rencana konten, **Uki** hasil clipping video, dan **Flo** hasil upload) otomatis dikirim ke Telegram Anda:

1. Buka Telegram dan cari **@BotFather**, lalu kirim `/newbot`.
2. Beri nama & username bot (contoh: `MyClipperTeamBot`), Anda akan menerima **HTTP API Token**.
3. Salin `.env.example` ke `.env` lalu masukkan token:
   ```env
   TELEGRAM_BOT_TOKEN=123456789:ABCdefGhI...
   ```
4. Buka bot baru Anda di Telegram, lalu klik tombol **Start** (atau kirim `/start`).
5. Jalankan perintah otomatis untuk mendeteksi Chat ID Anda:
   ```bash
   python3 scripts/notify_telegram.py --get-chat-id
   ```
6. Salin Chat ID yang muncul ke `.env`:
   ```env
   TELEGRAM_CHAT_ID=123456789
   ```
7. Uji koneksi notifikasi:
   ```bash
   python3 scripts/notify_telegram.py --test
   ```

## Catatan Penting Multi-Channel TikTok
- **API Resmi (Disarankan):** Menggunakan TikTok Content Posting API v2 (`inbox` untuk masuk sebagai draft agar aman direview sebelum publish, atau `direct` jika aplikasi sudah disetujui untuk Direct Post).
- **Anti-Duplicate Content:** Untuk menghindari penurunan jangkauan saat upload ke banyak channel, gunakan variasi hook, caption, hashtag, dan jadwal tayang per channel di `config/channels.json`.
