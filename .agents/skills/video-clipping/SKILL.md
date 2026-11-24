---
name: video-clipping
description: >-
  Use this skill when trimming, resizing, or converting raw video footage into 9:16 vertical TikTok clips
  using FFmpeg, scripts/clipper.py, Remotion (React), or HyperFrames (HTML/GSAP), including audio normalization,
  subtitle burn-in, and motion graphics.
---

# Video Clipping & Motion Engineering Skill (Uki)

Skill utama ini digunakan oleh **Uki (Video Editor)** untuk memproduksi klip video TikTok marketing vertikal (9:16, 1080x1920) menggunakan 3 teknologi terintegrasi:

1. **FFmpeg Engine (`scripts/clipper.py`)**: Untuk pemotongan footage berkecepatan tinggi, framing 9:16 (`crop` / `blur`), dan normalisasi audio (`-14 LUFS`).
2. **Remotion (`.agents/skills/remotion/`)**: Untuk dynamic animated captions, karaoke word subtitles, dan template video berbasis React.
3. **HyperFrames (`.agents/skills/hyperframes/`)**: Untuk title cards animasi, lower-thirds, CTA pop-up, dan motion graphics berbasis HTML/CSS/GSAP.

---

## 1. Pemotongan Cepat Footage (FFmpeg Engine)

### Berdasarkan Timestamp Segmen (Rekomendasi dari Ade)
```bash
python3 scripts/clipper.py clip \
  --input footage/<nama_video> \
  --segments "00:00:15-00:00:45,00:01:10-00:01:50" \
  --batch <nama_batch>
```

### Berdasarkan Durasi Tetap (Auto-Chunking)
```bash
python3 scripts/clipper.py clip \
  --input footage/<nama_video> \
  --chunk-seconds 30 \
  --batch <nama_batch>
```

### Pemilihan Mode Framing 9:16:
- `--fit crop`: Memotong sisi kiri & kanan (cocok untuk subjek tunggal di tengah).
- `--fit blur`: Mempertahankan rasio 16:9 utuh di tengah dengan latar belakang blur dinamis di atas dan bawah.

---

## 2. Dynamic Captions & Subtitles (Remotion)
Saat Ade meminta caption animasi yang mengikuti tempo suara (karaoke/bounce style):
- Buka skill [Remotion](file:///Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/.agents/skills/remotion/SKILL.md).
- Gunakan `@remotion/captions` untuk menyorot kata aktif pada milidetik yang tepat.

---

## 3. Animated Cards & Motion Overlays (HyperFrames)
Saat video memerlukan opening title card, promo badge, atau overlay grafis yang estetis:
- Buka skill [HyperFrames](file:///Users/user/.gemini/antigravity/scratch/tiktok-clipper-marketing/.agents/skills/hyperframes/SKILL.md).
- Rancang elemen `.clip` dengan timeline GSAP yang deterministik.

---

## 4. Quality Assurance (Pre-Upload Check)
Sebelum menyerahkan hasil ke **Flo (Admin Social Media)**:
1. Pastikan resolusi tepat `1080x1920` (aspek rasio 9:16).
2. Pastikan file tersimpan rapi di:
   - `clips/<batch>/`: Master clips hasil render.
   - `ready_to_upload/<channel_id>/<batch>/`: Paket siap upload per channel.
3. Cek audio: tidak pecah (clipping) dan terdistribusi stereo seimbang.
