# 023 — Medicines / Daftar Obat (Master Data Obat)

## Overview

Master data obat/suplemen yang digunakan sebagai referensi informasi obat untuk klien. Data mencakup nama obat, golongan/kandungan, fungsi utama, efek samping, dan link referensi detail.

## Database Schema

### Table: `medicines`

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `name` | VARCHAR(200) | NOT NULL | Nama obat (e.g. "Allopurinol") |
| `category` | VARCHAR(200) | nullable | Golongan/kandungan (e.g. "Penghambat xanthine-oxidase") |
| `main_function` | TEXT | nullable | Fungsi utama (e.g. "Asam Urat, Batu Ginjal") |
| `side_effects` | TEXT | nullable | Efek samping obat |
| `detail_url` | VARCHAR(500) | nullable | Link referensi (e.g. alodokter.com) |
| `image_url` | VARCHAR(500) | nullable | URL gambar obat (via upload atau direct link) |
| `is_system` | BOOLEAN | NOT NULL, default false | Apakah data bawaan sistem |
| `created_by` | UUID | FK → users | User yang membuat |
| `created_at` | TIMESTAMPTZ | NOT NULL, auto | Waktu dibuat |
| `updated_at` | TIMESTAMPTZ | NOT NULL, auto | Waktu terakhir diupdate |

### Indexes
- **idx_medicines_name_trgm**: GIN trigram index pada `name` untuk fuzzy search
- **idx_medicines_category**: B-tree index pada `category` untuk filter

### Migration
```sql
-- File: database/migrations/021_create_medicines.sql
```

## API Endpoints

### List Medicines
```
GET /api/medicines?search=&category=&page=1&limit=20
```

**Query Params:**
| Param | Type | Deskripsi |
|-------|------|-----------|
| `search` | string | Search by name, category, atau main_function (ILIKE) |
| `category` | string | Filter by golongan/kandungan (ILIKE) |
| `page` | int | Halaman (default: 1) |
| `limit` | int | Items per page (default: 20, max: 100) |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Allopurinol",
      "category": "Penghambat xanthine-oxidase",
      "main_function": "Asam Urat, Batu Ginjal",
      "side_effects": "Sakit perut, Mual, Muntah, ...",
      "detail_url": "https://www.alodokter.com/allopurinol",
      "image_url": "http://localhost:8080/uploads/medicine-abc123.jpg",
      "is_system": false,
      "created_by": "uuid",
      "created_at": "2026-04-01T00:00:00Z",
      "updated_at": "2026-04-01T00:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

**Auth:** Required (any role)

---

### Get Medicine by ID
```
GET /api/medicines/{id}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Allopurinol",
    "category": "Penghambat xanthine-oxidase",
    "main_function": "Asam Urat, Batu Ginjal",
    "side_effects": "Sakit perut, Mual, Muntah, ...",
    "detail_url": "https://www.alodokter.com/allopurinol",
    "image_url": "http://localhost:8080/uploads/medicine-abc123.jpg",
    "is_system": false,
    "created_by": "uuid",
    "created_at": "2026-04-01T00:00:00Z",
    "updated_at": "2026-04-01T00:00:00Z"
  }
}
```

**Auth:** Required (any role)

---

### Create Medicine
```
POST /api/medicines
```

**Body:**
```json
{
  "name": "Allopurinol",
  "category": "Penghambat xanthine-oxidase",
  "main_function": "Asam Urat, Batu Ginjal",
  "side_effects": "Sakit perut, Mual, Muntah, ...",
  "detail_url": "https://www.alodokter.com/allopurinol",
  "image_id": "upload-uuid-from-upload-api",
  "image_url": "https://example.com/image.jpg"
}
```

| Field | Type | Required | Validasi |
|-------|------|----------|----------|
| `name` | string | YES | min=1, max=200 |
| `category` | string | no | Golongan/kandungan |
| `main_function` | string | no | Fungsi utama obat |
| `side_effects` | string | no | Efek samping |
| `detail_url` | string | no | URL referensi |
| `image_id` | string | no | Upload ID dari `/api/uploads` (prioritas utama) |
| `image_url` | string | no | URL gambar langsung (fallback jika image_id kosong) |

**Response:** `201 Created`
```json
{
  "success": true,
  "data": { ... }
}
```

**Auth:** Required (admin, trainer only)

---

### Update Medicine
```
PUT /api/medicines/{id}
```

**Body:** Same as Create.

**Response:** `200 OK`

**Auth:** Required (admin, trainer only)

---

### Delete Medicine
```
DELETE /api/medicines/{id}
```

**Response:**
```json
{
  "success": true,
  "message": "Medicine deleted"
}
```

**Auth:** Required (admin, trainer only)

---

## Role Access Summary

| Endpoint | Owner | Admin | Trainer | Finance | Client |
|----------|-------|-------|---------|---------|--------|
| GET /api/medicines | yes | yes | yes | yes | yes |
| GET /api/medicines/{id} | yes | yes | yes | yes | yes |
| POST /api/medicines | - | yes | yes | - | - |
| PUT /api/medicines/{id} | - | yes | yes | - | - |
| DELETE /api/medicines/{id} | - | yes | yes | - | - |

## Web Implementation

### Menu Location
**Sidebar → Master Libraries → Daftar Obat** (`/medicines`)

### Hooks (`src/hooks/useNewFeatures.ts`)
```typescript
useMedicines(params)      // GET list with search, category, pagination
useCreateMedicine()       // POST create
useUpdateMedicine()       // PUT update
useDeleteMedicine()       // DELETE
```

### Page: `src/app/(dashboard)/medicines/page.tsx`
- Table view with image thumbnail, nama, golongan, fungsi, link
- Expandable row untuk efek samping
- Search by nama obat, golongan, fungsi
- Filter by golongan/kategori
- Create/Edit modal with: image upload, name, category, main_function, side_effects, detail_url
- Delete with confirmation dialog
- Pagination (Sebelumnya / Selanjutnya)

## Seed Data

Seeder: `database/seeds/004_seed_medicines.sql`
- 58 obat dari sheet "Daftar Obat" di MASTER CLIENT DATA.xlsx
- Semua di-seed dengan `is_system = TRUE`
- Data meliputi: Allopurinol, Amlodipine, Atorvastatin, Candesartan, Clopidogrel, Concor, Glucophage, Simvastatin, dll.
