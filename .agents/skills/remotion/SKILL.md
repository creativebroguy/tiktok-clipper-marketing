---
name: remotion
description: >-
  Use this skill when creating, editing, animating, and rendering programmatic videos using Remotion (React and TypeScript),
  especially for TikTok vertical 9:16 compositions, dynamic kinetic captions, animated overlays, and automated video templates.
---

# Remotion Video Engineering Skill (Uki)

Skill ini memberikan kemampuan kepada **Uki (Video Editor)** untuk membuat, mengedit, dan me-render video secara terprogram menggunakan ekosistem **Remotion** (React, TypeScript, CSS, dan Web APIs).

Sumber referensi resmi: [github.com/remotion-dev/skills](https://github.com/remotion-dev/skills)

---

## 1. Setup & Inisialisasi Proyek Remotion

### Scaffold Proyek Baru (Khusus Video Pendek / TikTok)
```bash
npx create-video@latest --yes --blank --no-tailwind remotion-studio
cd remotion-studio
```

### Konfigurasi Komposisi TikTok 9:16 Vertikal
Selalu gunakan dimensi dan frame rate standar:
- **Width:** `1080`
- **Height:** `1920` (Aspek Rasio `9:16`)
- **FPS:** `30` (atau `60` untuk gerakan ultra-smooth)
- **DurationInFrames:** `fps * durasi_detik` (misal 30 detik = 900 frame)

Contoh `Root.tsx`:
```tsx
import { Composition } from "remotion";
import { TikTokClip } from "./TikTokClip";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="TikTokClip"
      component={TikTokClip}
      durationInFrames={900}
      fps={30}
      width={1080}
      height={1920}
      defaultProps={{
        title: "Hook Menarik di Sini!",
        videoSrc: "assets/input_clip.mp4",
      }}
    />
  );
};
```

---

## 2. Dynamic Animated Captions (Subtitles Ala TikTok)

Remotion mendukung subtitle dinamis kata-per-kata (karaoke style) dengan package `@remotion/captions`.

```bash
npm install @remotion/captions
```

Struktur data caption yang digunakan:
```ts
import type { Caption } from "@remotion/captions";

// Tipe data caption
type Caption = {
  text: string;
  startMs: number;
  endMs: number;
  timestampMs: number | null;
  confidence: number | null;
  pageBreakAfter?: boolean;
};
```

### Highlight Kata Aktif Sesuai Frame
Gunakan hook `useCurrentFrame()` dan `useVideoConfig()` untuk menghitung milidetik berjalan:
```tsx
import { useCurrentFrame, useVideoConfig } from "remotion";

export const SubtitleOverlay = ({ captions }: { captions: Caption[] }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const currentTimeMs = (frame / fps) * 1000;

  const activeCaption = captions.find(
    (c) => currentTimeMs >= c.startMs && currentTimeMs <= c.endMs
  );

  if (!activeCaption) return null;

  return (
    <div style={{
      position: "absolute",
      bottom: 250,
      width: "100%",
      textAlign: "center",
      fontSize: 54,
      fontWeight: "900",
      color: "#FFDE59",
      textShadow: "0 4px 12px rgba(0,0,0,0.8)",
      textTransform: "uppercase",
      padding: "0 40px",
    }}>
      {activeCaption.text}
    </div>
  );
};
```

---

## 3. Animasi Hook & Motion Graphics

Gunakan fungsi matematis `interpolate()` dan `spring()` bawaan Remotion:
- **`spring()`**: Untuk animasi pop-up stiker, headline, badge promo, atau tombol CTA agar terasa luwes dan organik.
- **`interpolate()`**: Untuk transisi zoom, fade, dan perpindahan posisi.

```tsx
import { spring, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { fps } = useVideoConfig();

const scale = spring({
  frame,
  fps,
  config: { damping: 12, mass: 0.5, stiffness: 100 },
});

return (
  <div style={{ transform: `scale(${scale})` }}>
    <h1>PROMO KHUSUS HARI INI!</h1>
  </div>
);
```

---

## 4. Preview & Rendering CLI

### Buka Remotion Studio (Preview)
```bash
npx remotion studio --no-open
# atau
npx remotion studio
```

### Render Video MP4
```bash
npx remotion render src/index.ts TikTokClip out/clip_final.mp4 --gl=angle
```

---

## 5. Kapan Uki Menggunakan Remotion?
1. Saat video membutuhkan **teks dinamis & subtitle animasi modern** (word highlight / bounce effect).
2. Saat membuat template video massal (data-driven video) di mana judul, harga promo, atau foto produk berganti otomatis per clip.
3. Saat membutuhkan overlay stiker, progress bar video, atau animasi CTA interaktif di atas footage mentah.
