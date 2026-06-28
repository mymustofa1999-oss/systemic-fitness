# 024 — Daily Journal & Customer Health Tracking

## Overview

Fitur jurnal harian untuk mencatat sesi latihan customer secara bulanan. Mencakup pencatatan obat, last meal, tekanan darah (pre/post workout), HR zone, dan assignment program conditioning.

## Database Schema

### Table: `program_categories`

Master tipe program conditioning.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `name` | VARCHAR(200) | NOT NULL | Nama kategori (e.g. "Functional Conditioning") |
| `code` | VARCHAR(50) | UNIQUE, NOT NULL | Kode unik (e.g. "functional") |
| `description` | TEXT | nullable | Deskripsi program |
| `parameter_template` | JSONB | default '{}' | Template parameter per kategori |
| `display_order` | INT | default 0 | Urutan tampilan |
| `is_active` | BOOLEAN | default true | Status aktif |
| `is_system` | BOOLEAN | default false | Data bawaan sistem |
| `created_by` | UUID | FK → users | User yang membuat |
| `created_at` | TIMESTAMPTZ | auto | Waktu dibuat |
| `updated_at` | TIMESTAMPTZ | auto | Waktu terakhir diupdate |

**Parameter Template Examples:**
```json
// Functional Conditioning
{"bpm_range": true}

// Cardiorespiratory Conditioning
{"beban_upper": true, "beban_lower": true, "bpm_range": true}

// Metabolic Conditioning
{"beban_upper": true, "beban_lower": true, "resistance": true}
```

### ALTER: `trainer_clients` — tambah `role_type`

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `role_type` | VARCHAR(20) | NOT NULL, default 'trainer' | Tipe assignment: 'trainer' atau 'consultant' |

### Table: `customer_hr_zones`

HR Zone settings per customer (1 per customer).

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `customer_id` | UUID | FK → users, UNIQUE | Customer ID (1:1) |
| `max_hr_upper` | INT | nullable | Max HR upper bound |
| `max_hr_lower` | INT | nullable | Max HR lower bound |
| `zone5_upper/lower` | INT | nullable | Zona 5 bounds |
| `zone4_upper/lower` | INT | nullable | Zona 4 bounds |
| `zone3_upper/lower` | INT | nullable | Zona 3 bounds |
| `zone2_upper/lower` | INT | nullable | Zona 2 bounds |
| `zone1_upper/lower` | INT | nullable | Zona 1 bounds |
| `notes` | TEXT | nullable | Catatan |

### Table: `customer_medicines`

Pivot table: obat tetap yang di-assign ke customer.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `customer_id` | UUID | FK → users | Customer ID |
| `medicine_id` | UUID | FK → medicines | Medicine ID |
| `notes` | TEXT | nullable | Catatan |
| `is_active` | BOOLEAN | default true | Status aktif |
| `created_at` | TIMESTAMPTZ | auto | Waktu dibuat |

UNIQUE: (customer_id, medicine_id)

### Table: `customer_program_assignments`

Program conditioning aktif per customer dengan parameter spesifik.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `customer_id` | UUID | FK → users | Customer ID |
| `program_category_id` | UUID | FK → program_categories | Kategori program |
| `is_active` | BOOLEAN | default true | Status aktif |
| `bpm_upper` | INT | nullable | BPM upper bound |
| `bpm_lower` | INT | nullable | BPM lower bound |
| `has_beban_upper` | BOOLEAN | default false | Ada beban upper |
| `has_beban_lower` | BOOLEAN | default false | Ada beban lower |
| `has_resistance` | BOOLEAN | default false | Ada resistance |
| `parameter_notes` | TEXT | nullable | Catatan parameter |

UNIQUE: (customer_id, program_category_id)

### Table: `daily_journal_sessions`

Container utama sesi harian per customer.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `customer_id` | UUID | FK → users | Customer ID |
| `session_number` | INT | NOT NULL | Nomor sesi (1-8 per bulan) |
| `session_date` | DATE | NOT NULL | Tanggal sesi |
| `month_year` | VARCHAR(7) | nullable | Grouping "YYYY-MM" |
| `notes` | TEXT | nullable | Catatan |
| `created_by` | UUID | FK → users | Trainer yang input |

UNIQUE: (customer_id, session_date)

### Table: `session_medicines`

Obat yang diminum pada sesi itu.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `session_id` | UUID | FK → daily_journal_sessions, CASCADE | Session ID |
| `medicine_id` | UUID | FK → medicines | Medicine ID |
| `notes` | TEXT | nullable | Catatan |

UNIQUE: (session_id, medicine_id)

### Table: `session_meals`

Last Meal sebelum workout.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `session_id` | UUID | FK → daily_journal_sessions, CASCADE | Session ID |
| `meal_time` | TIME | nullable | Jam makan |
| `food_description` | TEXT | nullable | Jenis makanan (free text) |
| `food_id` | UUID | FK → foods | Referensi master food (opsional) |
| `notes` | TEXT | nullable | Catatan |

### Table: `session_vitals`

Tekanan darah & heartrate pre/post workout.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `session_id` | UUID | FK → daily_journal_sessions, CASCADE | Session ID |
| `measurement_type` | VARCHAR(20) | NOT NULL, CHECK | 'pre_workout' atau 'post_workout' |
| `systolic` | INT | nullable | Sistolik (mmHg) |
| `diastolic` | INT | nullable | Diastolik (mmHg) |
| `heartrate` | INT | nullable | Detak jantung (bpm) |
| `notes` | TEXT | nullable | Catatan |

UNIQUE: (session_id, measurement_type)

## API Endpoints — Program Categories

### List Program Categories
```
GET /api/program-categories?search=&page=1&limit=20
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Functional Conditioning",
      "code": "functional",
      "description": "...",
      "parameter_template": {"bpm_range": true},
      "display_order": 1,
      "is_active": true,
      "is_system": false,
      "created_at": "2026-04-01T00:00:00Z",
      "updated_at": "2026-04-01T00:00:00Z"
    }
  ],
  "meta": {"page": 1, "limit": 20, "total": 3, "total_pages": 1}
}
```

### Get Program Category
```
GET /api/program-categories/{id}
```

### Create Program Category
```
POST /api/program-categories
```
**Roles:** Admin, Trainer

**Body:**
```json
{
  "name": "Functional Conditioning",
  "code": "functional",
  "description": "...",
  "parameter_template": {"bpm_range": true},
  "display_order": 1,
  "is_active": true
}
```

### Update Program Category
```
PUT /api/program-categories/{id}
```
**Roles:** Admin, Trainer

### Delete Program Category
```
DELETE /api/program-categories/{id}
```
**Roles:** Admin, Trainer

## Seed Data

3 program categories bawaan (is_system = true):

| Name | Code | Parameter Template |
|------|------|--------------------|
| Functional Conditioning | functional | `{"bpm_range": true}` |
| Cardiorespiratory Conditioning | cardiorespiratory | `{"beban_upper": true, "beban_lower": true, "bpm_range": true}` |
| Metabolic Conditioning | metabolic | `{"beban_upper": true, "beban_lower": true, "resistance": true}` |

## Web Implementation

- **Menu:** Master Libraries → Program Categories
- **URL:** `/program-categories`
- **Hooks:** `useProgramCategories`, `useCreateProgramCategory`, `useUpdateProgramCategory`, `useDeleteProgramCategory`
- **Page:** Table view with search, create/edit modal, delete confirmation, pagination
