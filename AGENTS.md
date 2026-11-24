# Agent Team & Roster: TikTok Clipper Marketing

Project ini dikelola oleh tim agent terkoordinasi:

```
                  ┌────────────────────────┐
                  │    User / Coordinator  │
                  └───────────┬────────────┘
                              │
             ┌────────────────┼────────────────┐
             ▼                ▼                ▼
      ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
      │     ADE     │  │     UKI     │  │     FLO     │
      │   Content   │  │    Video    │  │ Admin Social│
      │   Planner   │  │   Editor    │  │    Media    │
      └─────────────┘  └─────────────┘  └─────────────┘
```

## 1. Profil Agent

### 1. Ade — Content Planner
- **Identitas Subagent**: `ade`
- **Fokus Utama**: Analisis footage, riset hook viral 3 detik pertama, kurasi topik, dan penentuan timestamp segmen potongan video.
- **Skill Terpasang**: [`.agents/skills/content-planning/`](.agents/skills/content-planning/SKILL.md)
- **File Output**: Segment timestamp, catatan hook, dan brief konten.

### 2. Uki — Video Editor & Motion Engineer
- **Identitas Subagent**: `uki`
- **Fokus Utama**: Rendering video 9:16 (`1080x1920`), FFmpeg cropping & dynamic blur background, normalisasi audio `-14 LUFS`, subtitle dinamis via **Remotion (React)**, dan motion graphics / title overlays via **HyperFrames (HTML/GSAP)**.
- **Skill Terpasang**:
  - [`.agents/skills/video-clipping/`](.agents/skills/video-clipping/SKILL.md) (FFmpeg & core clipping)
  - [`.agents/skills/remotion/`](.agents/skills/remotion/SKILL.md) (React programmatic video & karaoke captions)
  - [`.agents/skills/hyperframes/`](.agents/skills/hyperframes/SKILL.md) (HTML/CSS/GSAP motion cards & overlays)
- **File Output**: Klip video di `clips/` dan paket video di `ready_to_upload/`.

### 3. Flo — Admin Social Media
- **Identitas Subagent**: `flo`
- **Fokus Utama**: Pengelolaan multi-channel di `config/channels.json`, copywriting caption & hashtag unik per channel, scheduling, validasi dry-run, dan upload via TikTok Content Posting API.
- **Skill Terpasang**: [`.agents/skills/social-media-admin/`](.agents/skills/social-media-admin/SKILL.md)
- **File Output**: Manifest siap upload, caption per channel, dan file log riwayat upload di `logs/`.

---

## 2. Cara Menjalankan Tugas Tim

### Delegasi Langsung
- *"Ade, tolong inspect footage baru di `footage/podcast_eps1.mp4` dan tentukan 3 hook terbaik."*
- *"Uki, buatkan klip dari segmen Ade dengan subtitle dinamis Remotion dan opening card HyperFrames."*
- *"Flo, siapkan caption untuk semua channel aktif dan lakukan dry run upload."*

### Kolaborasi Otomatis (Teamwork)
Gunakan perintah `/teamwork` saat ingin seluruh alur dari footage hingga siap upload dikerjakan otomatis dalam satu putaran kerja tim.
