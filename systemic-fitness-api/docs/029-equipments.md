# 029 — Equipments (Master Data)

## Overview

Master data equipment yang digunakan dalam Trainer Card. Equipment dikategorikan berdasarkan **upper** (peralatan upper body seperti Wrist, Stick) dan **lower** (peralatan lower body seperti Ankle).

Equipment digunakan di Trainer Card pada kolom `equipment_upper` dan `equipment_lower` di setiap set.

## Database Schema

### Table: `equipments`

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `name` | VARCHAR(100) | NOT NULL | Nama equipment (e.g. "Wrist 0.5 kg") |
| `category` | VARCHAR(10) | NOT NULL, CHECK | Kategori: `upper` atau `lower` |
| `description` | TEXT | nullable | Deskripsi equipment |
| `is_active` | BOOLEAN | default true | Status aktif |
| `sort_order` | INT | default 0 | Urutan tampilan |
| `created_by` | UUID | FK → users | Pembuat |
| `created_at` | TIMESTAMPTZ | auto | Waktu dibuat |
| `updated_at` | TIMESTAMPTZ | auto | Waktu terakhir diupdate |

**Seed Data:**

| Name | Category |
|------|----------|
| Wrist 0.25 kg | upper |
| Wrist 0.5 kg | upper |
| Wrist 1 kg | upper |
| Wrist 1.5 kg | upper |
| Wrist 2 kg | upper |
| Wrist 2.5 kg | upper |
| Stick 0.5 kg | upper |
| Stick 1 kg | upper |
| Stick 1.5 kg | upper |
| Stick 2 kg | upper |
| Ankle 0.5 kg | lower |
| Ankle 1 kg | lower |
| Ankle 1.5 kg | lower |
| Ankle 2 kg | lower |
| Ankle 2.5 kg | lower |
| Ankle 3 kg | lower |
| Ankle 3.5 kg | lower |
| Ankle 4 kg | lower |

## API Endpoints

### 1. List Equipments

```
GET /api/equipments?page=1&limit=50&search=wrist&category=upper
```

**Query Parameters:**

| Param | Type | Deskripsi |
|-------|------|-----------|
| `page` | int | Halaman (default 1) |
| `limit` | int | Jumlah per halaman (default 20) |
| `search` | string | Pencarian nama/deskripsi |
| `category` | string | Filter: `upper` atau `lower` |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Wrist 0.5 kg",
      "category": "upper",
      "description": null,
      "is_active": true,
      "sort_order": 2,
      "created_by": "uuid",
      "created_at": "2026-04-05T10:00:00Z",
      "updated_at": "2026-04-05T10:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 50,
    "total": 18,
    "total_pages": 1
  }
}
```

### 2. Get Equipment by ID

```
GET /api/equipments/{id}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Wrist 0.5 kg",
    "category": "upper",
    "description": null,
    "is_active": true,
    "sort_order": 2,
    "created_by": null,
    "created_at": "2026-04-05T10:00:00Z",
    "updated_at": "2026-04-05T10:00:00Z"
  }
}
```

### 3. Create Equipment

```
POST /api/equipments
```

**Roles:** Admin, Trainer

**Request Body:**

```json
{
  "name": "Dumbbell 2 kg",
  "category": "upper",
  "description": "Dumbbell untuk latihan upper body",
  "sort_order": 11,
  "is_active": true
}
```

**Validation:**

| Field | Rule |
|-------|------|
| `name` | required, 1-100 chars |
| `category` | required, oneof: `upper`, `lower` |
| `description` | optional |
| `sort_order` | optional (default 0) |
| `is_active` | optional (default true) |

**Response:** `201 Created`

```json
{
  "success": true,
  "data": {
    "id": "generated-uuid",
    "name": "Dumbbell 2 kg",
    "category": "upper",
    "description": "Dumbbell untuk latihan upper body",
    "is_active": true,
    "sort_order": 11,
    "created_by": "user-uuid",
    "created_at": "2026-04-05T10:00:00Z",
    "updated_at": "2026-04-05T10:00:00Z"
  }
}
```

### 4. Update Equipment

```
PUT /api/equipments/{id}
```

**Roles:** Admin, Trainer

**Request Body:** Same as Create.

**Response:** `200 OK` with updated equipment object.

### 5. Delete Equipment

```
DELETE /api/equipments/{id}
```

**Roles:** Admin, Trainer

**Response:**

```json
{
  "success": true,
  "message": "Equipment deleted"
}
```

## Integrasi dengan Trainer Card

Equipment digunakan di Trainer Card page (`/clients/{id}/trainer-card`). Pada kolom **Equipment Upper** dan **Equipment Lower** di setiap set, user memilih equipment menggunakan `SearchableSelect` dropdown yang mengambil data dari endpoint `GET /api/equipments?category=upper` dan `GET /api/equipments?category=lower`.
