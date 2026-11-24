# Agent Team & Roster: TikTok Clipper Marketing

Project ini dikelola oleh sebuah tim agent terkoordinasi:

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
- **Skill Terpasang**: `.agents/skills/content-planning/`
- **File Output**: Segment timestamp, catatan hook, dan brief konten.

### 2. Uki — Video Editor
- **Identitas Subagent**: `uki`
- **Fokus Utama**: Rendering video 9:16 (`1080x1920`), cropping & dynamic blur background, normalisasi audio `-14 LUFS`, burn-in subtitle `.srt`.
- **Skill Terpasang**: `.agents/skills/video-clipping/`
- **File Output**: Klip video di `clips/` dan paket video di `ready_to_upload/`.

### 3. Flo — Admin Social Media
- **Identitas Subagent**: `flo`
- **Fokus Utama**: Pengelolaan multi-channel di `config/channels.json`, copywriting caption & hashtag unik per channel, scheduling, validasi dry-run, dan upload via TikTok Content Posting API.
- **Skill Terpasang**: `.agents/skills/social-media-admin/`
- **File Output**: Manifest siap upload, caption per channel, dan file log riwayat upload di `logs/`.

---

## 2. Cara Menjalankan Tugas Tim

### Delegasi Langsung
Anda cukup memberikan footage mentah atau perintah ke Coordinator (saya), dan saya dapat langsung mendelegasikan tugas ke Ade, Uki, atau Flo melalui subagent:
- *"Ade, tolong inspect footage baru di `footage/podcast_eps1.mp4` dan tentukan 3 hook terbaik."*
- *"Uki, potong segmen dari Ade menjadi 3 klip mode blur."*
- *"Flo, siapkan caption untuk channel 1 dan 2, lalu lakukan dry run upload."*

### Kolaborasi Otomatis (Swarm / Teamwork)
Anda juga bisa memicu koordinasi multi-agent menggunakan fitur `/teamwork` saat ingin seluruh alur dari footage hingga siap upload dikerjakan otomatis dalam satu putaran kerja tim.
