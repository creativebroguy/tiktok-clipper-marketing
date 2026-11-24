# SOP & Struktur Tim Video Clipper Marketing

Dokumen ini menjadi acuan kerja tim (maupun pembagian tugas sub-agent) dari saat footage masuk hingga terpublikasi ke seluruh channel TikTok.

## 1. Pembagian Role Tim

| Role | Tanggung Jawab Utama | Output |
| :--- | :--- | :--- |
| **1. Footage Intake & Hook Hunter** | Menonton/memeriksa footage mentah, menandai momen hook terbaik (3 detik pertama kuat), menentukan timestamp potongan. | Daftar segment timestamp + catatan topik tiap clip |
| **2. Video Clipper & Editor** | Menjalankan `scripts/clipper.py`, memilih framing (`crop` vs `blur`), menambahkan subtitle/watermark bila perlu, mengecek kualitas audio & visual. | Video `9:16` (`1080x1920`) bersih di `clips/<batch>/` |
| **3. Channel Copywriter** | Menyesuaikan hook teks, caption, CTA, dan hashtag agar tiap channel punya angle unik (menghindari konten duplikat identik). | File `caption.txt` & `manifest.json` per channel |
| **4. Distribution & Uploader** | Menjalankan dry-run validasi lalu mengupload ke setiap channel TikTok (via TikTok Content Posting API atau jadwal upload tim) sesuai jam tayang. | Log status upload di `logs/` |
| **5. QA & Performance Tracker** | Mengecek hasil tayang, melacak retensi 3 detik pertama, dan memberi masukan hook terbaik untuk batch berikutnya. | Catatan evaluasi mingguan |

## 2. Alur Kerja Per Batch Footage

1. **Drop Footage**: Anda menaruh file video mentah di `footage/` dan memberi brief singkat (opsional: target durasi, channel tujuan, atau CTA promo).
2. **Audit & Timestamping**: Cek durasi dan resolusi dengan `python3 scripts/clipper.py inspect <file>`, lalu tentukan titik potong terbaik.
3. **Batch Clipping**: Jalankan `scripts/clipper.py clip ...` untuk menghasilkan clip vertikal `1080x1920` dan membuat folder paket per channel di `ready_to_upload/`.
4. **Kustomisasi Per Channel**: Sesuaikan caption/hashtag jika ada promo spesifik untuk channel tertentu.
5. **Pre-Flight Check**: Jalankan `python3 scripts/upload_tiktok.py --batch <batch> --dry-run`.
6. **Publish / Draft Upload**: Jalankan upload ke semua channel aktif (`--mode inbox` direkomendasikan agar masuk sebagai draft TikTok, atau `--mode direct` jika izin Direct Post aktif).

## 3. Praktik Terbaik Multi-Channel
- Beri jeda jadwal posting antar channel (misalnya selisih 1–3 jam) agar tidak saling berebut trafik di menit yang sama.
- Variasikan `fit_mode` (`crop` vs `blur`), opening hook, caption, dan kombinasi hashtag antar channel di `config/channels.json`.
- Simpan kredensial OAuth hanya di `.env` lokal dan perbarui token secara berkala sesuai masa berlaku TikTok OAuth.
