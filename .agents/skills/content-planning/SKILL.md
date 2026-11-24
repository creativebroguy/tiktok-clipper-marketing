---
name: content-planning
description: >-
  Use this skill when analyzing raw footage to find viral hooks, determining clipping segment timestamps,
  planning TikTok content angles, and creating briefs for video editing and channel distribution.
---

# Content Planning Skill (Ade)

Skill ini digunakan untuk menganalisis rekaman video (footage), mengekstrak momen bernilai tinggi, dan merancang variasi konten TikTok marketing.

## Prosedur Kerja

### 1. Inspeksi Metadata Footage
Jalankan perintah inspeksi untuk mengetahui durasi, resolusi, dan audio:
```bash
python3 scripts/clipper.py inspect footage/<nama_file_video>
```

### 2. Identifikasi Hook 3 Detik Pertama
Gunakan formula hook viral untuk video TikTok pendek:
- **Pola Penasaran / Tabu**: "Jujur nyesel baru tahu cara ini..."
- **Pola Solusi Cepat**: "3 langkah beresin [masalah] tanpa ribet!"
- **Pola Kontrarian**: "Stop lakukan [kebiasaan umum], ini cara yang benar!"
- **Pola Callout Target**: "Khusus buat kamu yang jualan online tapi sepi pembeli..."

### 3. Tentukan Segment Timestamp
- Pilih durasi per clip antara 15 hingga 45 detik (maksimal 60 detik untuk retensi maksimal).
- Pastikan tidak memotong kalimat di tengah-tengah kata.
- Format penulisan segmen:
  `"HH:MM:SS-HH:MM:SS,HH:MM:SS-HH:MM:SS"` atau `"00:00:10-00:00:35,00:01:05-00:01:40"`

### 4. Buat Rencana Konten & Brief
Simpan catatan brief atau teruskan ke Uki (Editor) dan Flo (Admin) mencakup:
- Nama batch
- List segmen dan alasan pemilihan hook
- Rekomendasi framing (`crop` atau `blur`)
- Draft headline teks & Call To Action (CTA)
