---
name: social-media-admin
description: >-
  Use this skill when managing TikTok channels, customizing captions and hashtags, verifying upload manifests,
  and executing multi-channel uploads using scripts/upload_tiktok.py.
---

# Social Media Admin Skill (Flo)

Skill ini digunakan untuk mengelola channel TikTok, memastikan kesiapan paket upload, dan mengeksekusi distribusi konten.

## Prosedur Eksekusi

### 1. Kelola Channel TikTok
Konfigurasi channel berada di `config/channels.json`:
- Atur `enabled: true` untuk channel yang aktif.
- Sesuaikan `caption_template`, `default_hook`, `default_cta`, dan `default_hashtags`.
- Pastikan nama variabel token di `.env` sesuai dengan `token_env_var`.

### 2. Audit Kesiapan Paket Upload
Sebelum upload, periksa paket di `ready_to_upload/<channel_id>/<batch>/`:
- Cek file video (`.mp4`) ada dan tidak kosong.
- Cek `caption.txt` sudah mengandung hook, isi, CTA, dan hashtag yang variatif.
- Cek `manifest.json` berisi metadata lengkap.

### 3. Uji Coba (Pre-Flight / Dry Run)
Selalu jalankan dry run terlebih dahulu:
```bash
python3 scripts/upload_tiktok.py --batch <nama_batch> --dry-run
```
Periksa apakah ada file yang hilang atau token yang belum terkonfigurasi.

### 4. Eksekusi Upload Resmi
- **Mode Inbox / Draft (Direkomendasikan)**:
  Video akan masuk ke Creator Inbox di aplikasi TikTok pengguna, memungkinkan review akhir sebelum tayang.
  ```bash
  python3 scripts/upload_tiktok.py --batch <nama_batch> --mode inbox
  ```
- **Mode Direct Post**:
  Membutuhkan izin Direct Post pada TikTok Developer App:
  ```bash
  python3 scripts/upload_tiktok.py --batch <nama_batch> --mode direct --privacy PUBLIC_TO_EVERYONE
  ```

### 5. Cek Log & Laporan
Buka file log di `logs/upload_<batch>_<timestamp>.json` untuk melihat `publish_id` dan ringkasan status tiap video.
