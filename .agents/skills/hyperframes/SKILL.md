---
name: hyperframes
description: >-
  Use this skill when creating, animating, or rendering videos using HyperFrames (HTML/CSS/GSAP rendered to video),
  including motion graphics, kinetic typography, cards, overlays, vertical clips, and scene-based video generation.
---

# HyperFrames Video Engineering Skill (Uki)

Skill ini memberikan kemampuan kepada **Uki (Video Editor)** untuk memproduksi video menggunakan **HyperFrames** dari HeyGen — framework video berbasis standar terbuka **HTML, CSS, dan timeline animasi GSAP** yang di-render frame-by-frame via headless Chrome dan FFmpeg.

Sumber referensi resmi: [github.com/heygen-com/hyperframes](https://github.com/heygen-com/hyperframes)

---

## 1. Konsep Utama HyperFrames

HyperFrames me-render HTML ke format video secara deterministik:
- Setiap frame dicari (*seekable*) secara presisi sehingga hasil render selalu 100% konsisten.
- Menggunakan standar web murni (HTML5, CSS Flexbox/Grid, GSAP) yang sangat cepat disusun dan dimodifikasi oleh AI.
- Kompatibel dengan FFmpeg dan dapat di-convert langsung dari/ke format Remotion (`/remotion-to-hyperframes`).

---

## 2. Render Contract (Aturan Baku HyperFrames)

1. **Timed Elements:**
   Setiap elemen berdurasi harus memiliki:
   - `class="clip"`
   - `data-start="<detik>"`
   - `data-duration="<detik>"`
2. **Durasi Total:**
   Panjang video ditentukan oleh atribut `data-duration` pada elemen root `#root` atau `index.html`.
3. **Timeline GSAP:**
   Setiap scene/komposisi membangun satu timeline yang di-pause dan didaftarkan ke window:
   ```javascript
   const tl = gsap.timeline({ paused: true });
   // Definisikan tween di sini
   window.__timelines["scene-1"] = tl;
   ```
4. **Deterministik:**
   Dilarang menggunakan `Date.now()`, `Math.random()` tanpa seed, network fetch saat rendering, `setInterval`, atau `repeat: -1`. Semua visual harus berupa fungsi dari timeline time.
5. **Animasi & Transformasi:**
   - Jangan melakukan tween pada `display`, `visibility`, atau `autoAlpha` langsung di `.clip` (animasikan child element).
   - Jangan menambahkan CSS `transform` pada elemen yang ditransformasi oleh GSAP.
6. **Media Audio/Video:**
   - Jangan memanggil `.play()` atau `.pause()` secara manual.
   - Tag `<video>` dengan audio aktif wajib memakai `data-has-audio="true"`, jika tidak gunakan `muted`.
   - Setiap tag `<audio>` wajib memiliki `id` unik agar masuk ke dalam audio mixdown.
7. **Safe Areas (Khusus TikTok & Reels):**
   - Jaga elemen visual utama tetap di dalam **90% action-safe box**.
   - Jaga teks judul, caption, dan hook di dalam **80% title-safe box** agar tidak tertutup ikon like/komentar TikTok.

---

## 3. Template Komposisi Vertikal 9:16 (`index.html`)

```html
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>TikTok HyperFrame Clip</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      width: 1080px;
      height: 1920px;
      overflow: hidden;
      background: #0B0E14;
      font-family: 'Inter', sans-serif;
    }
    #root {
      width: 100%;
      height: 100%;
      position: relative;
    }
    .clip {
      position: absolute;
      width: 100%;
      height: 100%;
    }
    .hook-title {
      position: absolute;
      top: 180px;
      left: 60px;
      right: 60px;
      font-size: 64px;
      font-weight: 900;
      color: #FFFFFF;
      text-align: center;
      line-height: 1.2;
      text-shadow: 0 4px 20px rgba(0,0,0,0.8);
    }
    .badge {
      display: inline-block;
      background: #FE2C55;
      color: #FFFFFF;
      padding: 12px 28px;
      border-radius: 40px;
      font-size: 32px;
      margin-bottom: 20px;
    }
  </style>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
</head>
<body>
  <div id="root" data-duration="15">
    <div class="clip" data-composition-id="scene-hook" data-start="0" data-duration="15">
      <div class="hook-title">
        <div class="badge" id="badge">TIPS VIRAL</div>
        <div id="headline">3 DETIK PERTAMA INI YANG BIKIN FYP!</div>
      </div>
    </div>
  </div>

  <script>
    window.__timelines = window.__timelines || {};
    const tl = gsap.timeline({ paused: true });

    tl.from("#badge", { scale: 0, opacity: 0, duration: 0.6, ease: "back.out(1.7)" })
      .from("#headline", { y: 40, opacity: 0, duration: 0.8, ease: "power3.out" }, "-=0.3");

    window.__timelines["scene-hook"] = tl;
  </script>
</body>
</html>
```

---

## 4. CLI & Workflow HyperFrames

### Inisialisasi Proyek
```bash
npx hyperframes init my-clip-project --skip-skills
```

### Validasi Kode & Linting Aturan
```bash
npx hyperframes check --json
```

### Eksekusi Render ke MP4
```bash
npx hyperframes render index.html --output out/clip_hyperframe.mp4
```

---

## 5. Hubungan Remotion dan HyperFrames untuk Uki

| Aspek | Remotion | HyperFrames |
| :--- | :--- | :--- |
| **Bahasa Utama** | React (TSX/JSX) | Plain HTML5, CSS3, & GSAP JS |
| **Kekuatan Utama** | Video dinamis berbasis data, word captions, ekosistem React | Motion design ringan, cepat dirakit AI, render frame-accurate tanpa bundler besar |
| **Lisensi** | Free (tim kecil), Berbayar (enterprise) | Apache 2.0 (100% Free & Open Source) |
| **Kasus Terbaik Uki** | Subtitle karaoke kata-per-kata, dynamic React clips | Animated intro cards, promo badge, lower-third overlays, and motion transitions |
