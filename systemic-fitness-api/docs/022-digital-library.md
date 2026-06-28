# 022 — Digital Library (Master Data Gerakan Fitness)

## Overview

Digital Library adalah master data gerakan fitness yang digunakan sebagai **tahapan deteksi kesehatan sebelum melakukan latihan**. Sistem ini mengelompokkan gerakan berdasarkan **3 kategori**, **6 level progresif**, dan **3 fase latihan** (Menu, Isolate, Dynamic).

## Database Schema

### ENUM Types
```sql
training_category: 'fc', 'cc', 'mc'
training_phase:    'menu', 'isolate', 'dynamic'
dl_body_part:      'upper', 'lower', 'core'
dl_position:       'sit', 'stand'
```

### Tables

| Table | Deskripsi |
|-------|-----------|
| `dl_categories` | 3 kategori latihan (FC, CC, MC) |
| `dl_levels` | 6 level progresif (0-5) |
| `dl_movements` | 74 gerakan unik dengan video_url, image_url |
| `dl_menu_items` | Gerakan per kategori + level (245 items) |
| `dl_isolate_items` | Gerakan individual per posisi sit/stand (71 items) |
| `dl_dynamic_items` | Pasangan gerakan upper+lower (73 items) |

### ERD
```
dl_categories ──┐
                 ├── dl_menu_items ──── dl_movements
dl_levels ───────┘                          │
                                            │
dl_categories ────── dl_isolate_items ──────┘
                                            │
dl_categories ────── dl_dynamic_items ──────┘
                     (upper + lower movement)
```

## 3 Kategori Latihan

| Code | Nama | Tujuan |
|------|------|--------|
| **FC** | Functional Conditioning | Pola gerakan fungsional, stabilitas sendi, mobilitas progresif |
| **CC** | Cardio Conditioning | Daya tahan kardiovaskular & aerobik |
| **MC** | Metabolic Conditioning | Pembentukan otot dengan resistance band & bodyweight + core |

## 6 Level Progresif

| Level | Kondisi | Nama ID |
|-------|---------|---------|
| 0 | Berbaring (bed-bound) | Level 0 - Berbaring |
| 1 | Duduk (seated) | Level 1 - Duduk |
| 2 | Berdiri (standing) | Level 2 - Berdiri |
| 3 | Jalan terbatas | Level 3 - Jalan Terbatas |
| 4 | Jalan normal, start dynamic | Level 4 - Jalan Normal |
| 5 | Dynamic full BPM | Level 5 - Dynamic Full BPM |

## API Endpoints

### Reference Data
```
GET /api/digital-library/categories          → List kategori
GET /api/digital-library/levels              → List level
```

### Movements (CRUD)
```
GET    /api/digital-library/movements                  → List movements (paginated + filter)
       ?body_part=upper&category=fc&search=arm&page=1&limit=20
GET    /api/digital-library/movements/{id}             → Detail movement
POST   /api/digital-library/movements                  → Create movement (admin/trainer)
PUT    /api/digital-library/movements/{id}             → Update movement (admin/trainer)
DELETE /api/digital-library/movements/{id}             → Delete movement (admin/trainer)
POST   /api/digital-library/movements/{id}/upload-image → Upload gambar (admin/trainer)
```

### Program Data
```
GET /api/digital-library/categories/{code}/menu     → Menu items per kategori
    ?level=3                                         (optional level filter)
GET /api/digital-library/categories/{code}/isolate  → Isolate items per kategori
    ?position=sit                                    (optional position filter)
GET /api/digital-library/categories/{code}/dynamic  → Dynamic pairs per kategori
GET /api/digital-library/categories/{code}/program  → Full overview (menu+isolate+dynamic)
```

### Movement Body

```json
{
  "name": "Arm Rotation",
  "body_part": "upper",
  "categories": ["fc", "cc"],
  "description": "Rotational movement for shoulder mobility",
  "video_url": "https://youtube.com/watch?v=...",
  "image_url": "https://...",
  "duration": "30s",
  "equipment": null,
  "instructions": ["Stand with arms extended", "Rotate in circles"]
}
```

## Web Admin (systemic-fitness-web)

### Konfigurasi

1. **Sidebar**: Menu "Master Data" → "Digital Library" di `/digital-library`
2. **API Base URL**: Menggunakan `NEXT_PUBLIC_API_URL` dari `.env`
3. **Authentication**: Semua endpoint memerlukan JWT token via NextAuth

### File Structure
```
src/
├── hooks/useDigitalLibrary.ts        → React Query hooks
└── app/(dashboard)/digital-library/
    └── page.tsx                       → Main page with 4 tabs
```

### Fitur CRUD
- **Movements Tab**: DataTable dengan filter (body_part, category, search) + Create/Edit/Delete modal
- **Menu Tab**: View per kategori + level, grouped by upper/lower/core
- **Isolate Tab**: View per kategori + posisi (sit/stand)
- **Dynamic Tab**: View pasangan upper+lower per kategori

### Movement Form Fields
| Field | Type | Required | Keterangan |
|-------|------|----------|------------|
| name | text | Yes | Nama gerakan unik |
| body_part | select | Yes | upper / lower / core |
| categories | multi-select | Yes | fc / cc / mc |
| video_url | url | No | Link YouTube |
| image_url | url | No | URL gambar (atau upload) |
| duration | text | No | e.g. "30s", "1min" |
| equipment | text | No | e.g. TRX, Chair, Band |
| description | textarea | No | Deskripsi singkat |
| instructions | text[] | No | Step-by-step instruksi |

## Seed Data

Migration: `database/migrations/020_create_digital_library.sql`
Seed: `database/seeds/009_seed_digital_library.sql`

```bash
# Jalankan migration (Up only)
sed -n '/^-- +migrate Up/,/^-- +migrate Down/{ /^-- +migrate Down/d; p; }' \
  database/migrations/020_create_digital_library.sql | psql $DATABASE_URL

# Jalankan seed
psql $DATABASE_URL -f database/seeds/009_seed_digital_library.sql
```

## Klasifikasi Gerakan

Total: **74 gerakan unik** (21 upper, 42 lower, 11 core)

### Gerakan yang Muncul di Beberapa Kategori

| Gerakan | Body Part | FC | CC | MC |
|---------|-----------|:--:|:--:|:--:|
| Open V | upper | ✓ | ✓ | ✓ |
| Press Up | upper | ✓ | ✓ | ✓ |
| Press Front | upper | ✓ | ✓ | ✓ |
| Open Arm | upper | ✓ | ✓ | ✓ |
| Cross Up | upper | ✓ | ✓ | ✓ |
| Side Lift | lower | ✓ | ✓ | ✓ |
| Arm Rotation | upper | ✓ | ✓ | — |
| Cross Front | upper | ✓ | ✓ | — |
| Arm Swing | upper | ✓ | ✓ | — |
| Pull Side Down | upper | ✓ | ✓ | — |
| Pull Down | upper | ✓ | ✓ | — |

### Gerakan Khusus per Kategori

- **FC Only**: Curtsy Lunges, Squat Step, Lateral Lunge (tanpa kursi), dan varian tanpa bantuan
- **CC Only**: Open Chest, Front Step, Side Step
- **MC Only**: Tricep Press, Chest Press, Bicep Curls, Overhead Press, dan semua gerakan Band + Core
