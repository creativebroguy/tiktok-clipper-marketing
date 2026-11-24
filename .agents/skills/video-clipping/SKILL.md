---
name: video-clipping
description: >-
  Use this skill when trimming, resizing, or converting raw video footage into 9:16 vertical TikTok clips
  using FFmpeg and scripts/clipper.py, including audio normalization and subtitle burn-in.
---

# Video Clipping Skill (Uki)

Skill ini digunakan untuk memotong footage mentah menjadi video vertikal siap tayang di TikTok beresolusi 1080x1920 (9:16).

## Prosedur Eksekusi

### 1. Pemotongan Berdasarkan Timestamp
Jika Ade atau User sudah memberikan segmen spesifik:
```bash
python3 scripts/clipper.py clip \
  --input footage/<nama_video> \
  --segments "00:00:15-00:00:45,00:01:10-00:01:50" \
  --batch <nama_batch>
```

### 2. Pemotongan Otomatis (Chunking)
Jika ingin memecah video panjang menjadi klip pendek per N detik:
```bash
python3 scripts/clipper.py clip \
  --input footage/<nama_video> \
  --chunk-seconds 30 \
  --batch <nama_batch>
```

### 3. Memilih Mode Framing 9:16
- `--fit crop`: Memperbesar dan memotong sisi kiri-kanan (cocok jika subjek selalu di tengah).
- `--fit blur`: Mempertahankan video asli 16:9 di tengah dengan background blur dinamis di atas dan bawah.

### 4. Burn-in Subtitle (Opsional)
Jika ada file subtitle `.srt`:
```bash
python3 scripts/clipper.py clip \
  --input footage/<nama_video> \
  --segments "00:00:10-00:00:40" \
  --subtitle assets/subtitles.srt \
  --batch <nama_batch>
```

### 5. Verifikasi Output
Pastikan klip tersimpan di:
- `clips/<batch>/`: Master clips hasil render.
- `ready_to_upload/<channel_id>/<batch>/`: Paket video + caption + manifest per channel.
Cek ukuran file dan durasi untuk memastikan tidak ada audio/video yang terkorupsi.
