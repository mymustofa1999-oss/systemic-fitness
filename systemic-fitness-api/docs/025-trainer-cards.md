# 025 — Trainer Cards

## Overview

Trainer Card adalah kartu acuan yang digunakan trainer saat melakukan sesi latihan dengan customer/client. Card ini di-set oleh **Konsultan**, trainer hanya membaca dan mempraktekkan terhadap client.

Struktur card mengikuti format Excel (Dummy Level 5 & Dummy Level 2):
- **1 Card per customer** dengan level tertentu
- **3 Sequence** sesuai program customer: Functional (FC), Cardiorespiratory (CC), Metabolic (MC)
- **Sets per sequence** dengan tipe gerakan (Isolate/Dynamic), BPM zone, equipment, durasi
- **Items per set** berupa gerakan dari Digital Library (`dl_movements`)

## Database Schema

### Table: `trainer_card_types`

Master tipe gerakan. Default: Isolate & Dynamic. Bisa ditambah sendiri oleh admin/trainer.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `name` | VARCHAR(50) | UNIQUE, NOT NULL | Nama tipe (e.g. "Isolate", "Dynamic") |
| `description` | TEXT | nullable | Deskripsi tipe |
| `is_active` | BOOLEAN | default true | Status aktif |
| `sort_order` | INT | default 0 | Urutan tampilan |
| `created_at` | TIMESTAMPTZ | auto | Waktu dibuat |
| `updated_at` | TIMESTAMPTZ | auto | Waktu terakhir diupdate |

**Seed Data:**

| Name | Description |
|------|-------------|
| Isolate | Gerakan isolasi — satu bagian tubuh per gerakan |
| Dynamic | Gerakan dinamis — kombinasi upper dan lower body |

### Table: `trainer_cards`

Satu card per customer. Level diisi manual (bisa "1", "2", "3-4", "3-5", "4", "4-5", "5").

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `customer_id` | UUID | FK → users, UNIQUE | Customer ID (1 card per customer) |
| `level` | VARCHAR(10) | NOT NULL | Level client: "1", "2", "3-4", "3-5", "4", "4-5", "5" |
| `notes` | TEXT | nullable | Catatan umum |
| `created_by` | UUID | FK → users | Konsultan yang membuat |
| `created_at` | TIMESTAMPTZ | auto | Waktu dibuat |
| `updated_at` | TIMESTAMPTZ | auto | Waktu terakhir diupdate |

### Table: `trainer_card_sequences`

Sequence per card, link ke `program_categories` (FC/CC/MC) sesuai program yang dijalankan customer.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `trainer_card_id` | UUID | FK → trainer_cards, CASCADE | ID card |
| `program_category_id` | UUID | FK → program_categories | Kategori program (FC/CC/MC) |
| `duration` | VARCHAR(20) | nullable | Durasi sequence (e.g. "10-15 mins", "20-25") |
| `sort_order` | INT | default 0 | Urutan tampilan |
| `created_at` | TIMESTAMPTZ | auto | Waktu dibuat |
| `updated_at` | TIMESTAMPTZ | auto | Waktu terakhir diupdate |

UNIQUE: (trainer_card_id, program_category_id)

### Table: `trainer_card_sets`

Set dalam sequence. Setiap set punya tipe (Dynamic/Isolate), BPM zone, equipment, durasi.

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `sequence_id` | UUID | FK → trainer_card_sequences, CASCADE | ID sequence |
| `set_number` | INT | NOT NULL | Nomor set (1, 2, 3) |
| `duration` | VARCHAR(20) | nullable | Durasi set (e.g. "3-5 mins", "10-12 mins") |
| `equipment_upper` | VARCHAR(200) | nullable | Equipment upper body (e.g. "Wrist 0.5 kg", "Wrist 0.5 kg, Stick") |
| `equipment_lower` | VARCHAR(200) | nullable | Equipment lower body (e.g. "Ankle 1 kg", "Chair", "Hip Band Medium") |
| `type_id` | UUID | FK → trainer_card_types | Tipe gerakan (Dynamic/Isolate) |
| `bpm` | VARCHAR(30) | nullable | Target BPM zone (e.g. "zona 1-2", "zona 3-5") — untuk FC & CC |
| `extra_load` | VARCHAR(100) | nullable | Beban tambahan — untuk Metabolic |
| `notes` | TEXT | nullable | Catatan / Adjustment |
| `sort_order` | INT | default 0 | Urutan tampilan |
| `created_at` | TIMESTAMPTZ | auto | Waktu dibuat |
| `updated_at` | TIMESTAMPTZ | auto | Waktu terakhir diupdate |

### Table: `trainer_card_set_items`

Movement items dalam set. Link ke `dl_movements` (Digital Library).

| Column | Type | Constraint | Deskripsi |
|--------|------|------------|-----------|
| `id` | UUID | PK, auto | ID unik |
| `set_id` | UUID | FK → trainer_card_sets, CASCADE | ID set |
| `movement_id` | UUID | FK → dl_movements, nullable | ID gerakan dari Digital Library |
| `movement_name` | VARCHAR(150) | nullable | Nama gerakan (fallback jika movement_id null) |
| `body_part` | VARCHAR(10) | NOT NULL, CHECK | Bagian tubuh: 'upper', 'lower', 'core' |
| `equipment` | VARCHAR(200) | nullable | Equipment khusus item ini (override dari set) |
| `reps` | INT | nullable | Jumlah repetisi |
| `sets_count` | INT | default 1 | Jumlah set |
| `sort_order` | INT | default 0 | Urutan tampilan |
| `created_at` | TIMESTAMPTZ | auto | Waktu dibuat |
| `updated_at` | TIMESTAMPTZ | auto | Waktu terakhir diupdate |

CHECK: body_part IN ('upper', 'lower', 'core')

## Relasi ke Table Existing

| Data | Sumber |
|------|--------|
| **NAMA** (customer) | `users.full_name` via `trainer_cards.customer_id` |
| **LEVEL** | Input manual di `trainer_cards.level` |
| **SEQUENCE** (FC/CC/MC) | `program_categories` via `customer_program_assignments` — ambil program aktif customer |
| **TIPE** (Isolate/Dynamic) | `trainer_card_types` — master, bisa tambah sendiri |
| **KOMPONEN** (gerakan) | `dl_movements` dari Digital Library |

## API Endpoints — Trainer Card Types (Master)

### List Trainer Card Types
```
GET /api/trainer-card-types
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Isolate",
      "description": "Gerakan isolasi — satu bagian tubuh per gerakan",
      "is_active": true,
      "sort_order": 1,
      "created_at": "2026-04-04T00:00:00Z",
      "updated_at": "2026-04-04T00:00:00Z"
    },
    {
      "id": "uuid",
      "name": "Dynamic",
      "description": "Gerakan dinamis — kombinasi upper dan lower body",
      "is_active": true,
      "sort_order": 2,
      "created_at": "2026-04-04T00:00:00Z",
      "updated_at": "2026-04-04T00:00:00Z"
    }
  ]
}
```

### Create Trainer Card Type
```
POST /api/trainer-card-types
```
**Roles:** Admin, Trainer

**Body:**
```json
{
  "name": "Compound",
  "description": "Gerakan compound multi-joint",
  "is_active": true,
  "sort_order": 3
}
```

### Update Trainer Card Type
```
PUT /api/trainer-card-types/{id}
```
**Roles:** Admin, Trainer

**Body:** Same as create.

### Delete Trainer Card Type
```
DELETE /api/trainer-card-types/{id}
```
**Roles:** Admin, Trainer

## API Endpoints — Trainer Card (per Customer)

### Get Trainer Card
```
GET /api/customers/{customerId}/trainer-card
```
**Roles:** Admin, Trainer

Mengembalikan full card dengan nested data: sequences → sets → items.
Jika belum ada card, response `data: null`.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "customer_id": "uuid",
    "customer_name": "John Doe",
    "level": "4-5",
    "notes": null,
    "created_by": "uuid-konsultan",
    "created_at": "2026-04-04T00:00:00Z",
    "updated_at": "2026-04-04T00:00:00Z",
    "sequences": [
      {
        "id": "uuid",
        "trainer_card_id": "uuid",
        "program_category_id": "uuid-fc",
        "program_category_name": "Functional Conditioning",
        "program_category_code": "functional",
        "duration": "10-15 mins",
        "sort_order": 0,
        "sets": [
          {
            "id": "uuid",
            "sequence_id": "uuid",
            "set_number": 1,
            "duration": "3-5 mins",
            "equipment_upper": null,
            "equipment_lower": null,
            "type_id": "uuid-dynamic",
            "type_name": "Dynamic",
            "bpm": "zona 1-2",
            "extra_load": null,
            "notes": null,
            "sort_order": 0,
            "items": [
              {
                "id": "uuid",
                "set_id": "uuid",
                "movement_id": "uuid-arm-rotation",
                "movement_name": "Arm Rotation-Wide Step Touch",
                "body_part": "upper",
                "equipment": null,
                "reps": 20,
                "sets_count": 1,
                "sort_order": 0
              },
              {
                "id": "uuid",
                "set_id": "uuid",
                "movement_id": null,
                "movement_name": "Open V-Back step",
                "body_part": "upper",
                "equipment": "Stick",
                "reps": 20,
                "sets_count": 1,
                "sort_order": 2
              }
            ]
          },
          {
            "id": "uuid",
            "set_number": 3,
            "duration": "3-5 mins",
            "equipment_upper": "TRX",
            "equipment_lower": null,
            "type_id": "uuid-dynamic",
            "type_name": "Dynamic",
            "bpm": "zona 2-3",
            "items": [
              {
                "movement_name": "Squat",
                "body_part": "lower",
                "reps": 20,
                "sets_count": 1
              }
            ]
          }
        ]
      },
      {
        "program_category_name": "Cardiorespiratory Conditioning",
        "program_category_code": "cardiorespiratory",
        "duration": "20-25",
        "sets": [
          {
            "set_number": 1,
            "duration": "10-12 mins",
            "equipment_upper": "Wrist 0.5 kg",
            "equipment_lower": "Ankle 1 kg",
            "type_name": "Dynamic",
            "bpm": "zona 3-5",
            "items": [
              {
                "movement_name": "Open Arm-Wide Step Touch",
                "body_part": "upper",
                "reps": 20,
                "sets_count": 1
              }
            ]
          }
        ]
      },
      {
        "program_category_name": "Metabolic Conditioning",
        "program_category_code": "metabolic",
        "duration": "20-25",
        "sets": [
          {
            "set_number": 1,
            "duration": "10-12 mins",
            "equipment_upper": "Wrist 1.5 kg",
            "type_name": "Isolate",
            "items": [
              {
                "movement_name": "Open Arm",
                "body_part": "upper",
                "reps": 15,
                "sets_count": 1
              },
              {
                "movement_name": "Push Up",
                "body_part": "core",
                "reps": 15,
                "sets_count": 1
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### Create / Update Trainer Card (Upsert)
```
POST /api/customers/{customerId}/trainer-card
```
**Roles:** Admin, Trainer (biasanya Konsultan)

Upsert: jika card sudah ada untuk customer ini, data lama akan di-replace seluruhnya.

**Body:**
```json
{
  "level": "4-5",
  "notes": "Perhatikan zona BPM di cardio",
  "sequences": [
    {
      "program_category_id": "uuid-fc",
      "duration": "10-15 mins",
      "sort_order": 0,
      "sets": [
        {
          "set_number": 1,
          "duration": "3-5 mins",
          "equipment_upper": null,
          "equipment_lower": null,
          "type_id": "uuid-dynamic",
          "bpm": "zona 1-2",
          "extra_load": null,
          "notes": null,
          "sort_order": 0,
          "items": [
            {
              "movement_id": "uuid-or-null",
              "movement_name": "Arm Rotation-Wide Step Touch",
              "body_part": "upper",
              "equipment": null,
              "reps": 20,
              "sets_count": 1,
              "sort_order": 0
            },
            {
              "movement_id": null,
              "movement_name": "Open V-Back step",
              "body_part": "upper",
              "equipment": "Stick",
              "reps": 20,
              "sets_count": 1,
              "sort_order": 1
            }
          ]
        },
        {
          "set_number": 2,
          "duration": "3-5 mins",
          "equipment_upper": "TRX",
          "type_id": "uuid-dynamic",
          "bpm": "zona 2-3",
          "sort_order": 1,
          "items": [
            {
              "movement_name": "Squat",
              "body_part": "lower",
              "reps": 20,
              "sets_count": 1,
              "sort_order": 0
            },
            {
              "movement_name": "Overhead Squat",
              "body_part": "lower",
              "reps": 20,
              "sets_count": 1,
              "sort_order": 1
            }
          ]
        }
      ]
    },
    {
      "program_category_id": "uuid-cc",
      "duration": "20-25",
      "sort_order": 1,
      "sets": []
    },
    {
      "program_category_id": "uuid-mc",
      "duration": "20-25",
      "sort_order": 2,
      "sets": []
    }
  ]
}
```

**Response:** Full card object (same as GET).

### Delete Trainer Card
```
DELETE /api/customers/{customerId}/trainer-card
```
**Roles:** Admin, Trainer

**Response:**
```json
{
  "success": true,
  "message": "Trainer card deleted"
}
```

## Flow Penggunaan

1. **Konsultan** membuka detail customer
2. Melihat program apa yang aktif di customer (dari `customer_program_assignments` → `program_categories`)
3. Membuat/edit Trainer Card:
   - Set **Level** customer (manual: 1, 2, 3-4, 3-5, 4, 4-5, 5)
   - Per **Sequence** (FC/CC/MC sesuai program aktif):
     - Tambah **Set** dengan tipe (Isolate/Dynamic dari `trainer_card_types`), durasi, equipment, BPM zone
     - Tambah **Items** per set — pilih gerakan dari Digital Library (`dl_movements`) atau input manual
4. **Trainer** membuka detail customer → Trainer Card → read-only view sebagai panduan sesi

## Web Implementation

### Files Created / Modified

| File | Deskripsi |
|------|-----------|
| `src/hooks/useNewFeatures.ts` | Tambah hooks: `useTrainerCardTypes`, `useCreateTrainerCardType`, `useUpdateTrainerCardType`, `useDeleteTrainerCardType`, `useTrainerCard`, `useUpsertTrainerCard`, `useDeleteTrainerCard` |
| `src/components/layout/Sidebar.tsx` | Tambah menu "Trainer Card Types" di Master Libraries |
| `src/app/(dashboard)/trainer-card-types/page.tsx` | **NEW** — Master page CRUD tipe gerakan |
| `src/app/(dashboard)/clients/[id]/trainer-card/page.tsx` | **NEW** — Trainer Card per customer (Excel-like layout) |
| `src/app/(dashboard)/clients/[id]/page.tsx` | Tambah link shortcut ke Trainer Card |

### Trainer Card Types (Master)
- **Menu:** Master Libraries → Trainer Card Types (icon: ClipboardCheck)
- **URL:** `/trainer-card-types`
- **Hooks:** `useTrainerCardTypes`, `useCreateTrainerCardType`, `useUpdateTrainerCardType`, `useDeleteTrainerCardType`
- **Page:** Table view (nama, deskripsi, urutan, status), create/edit modal, delete confirmation
- **Fitur:**
  - Tabel master tipe (default: Isolate, Dynamic)
  - Tambah tipe baru via modal
  - Edit inline (nama, deskripsi, urutan, aktif/nonaktif)
  - Hapus dengan konfirmasi

### Trainer Card (per Customer)
- **Akses:** Client Detail → klik card "Trainer Card" → navigasi ke `/clients/{id}/trainer-card`
- **URL:** `/clients/{id}/trainer-card`
- **Hooks:** `useTrainerCard`, `useUpsertTrainerCard`, `useDeleteTrainerCard`, `useTrainerCardTypes`, `useCustomerPrograms`, `useDLMovements`
- **Layout Excel-like:**

```
┌─────────────────────────────────────────────────────────┐
│  TRAINER CARD                        [Edit] [Hapus]     │
├──────┬──────────────┬───────┬──────────────────────────┤
│ NAMA │ John Doe     │ LEVEL │ 4-5                      │
└──────┴──────────────┴───────┴──────────────────────────┘

┌─ Functional Conditioning ──────────────────── 10-15 mins ┐
│ Set │ Durasi │ Eq.Up │ Eq.Low │ Tipe  │ Movement     │BP│
│  1  │ 3-5m   │       │        │Dynamic│ Arm Rotation │U │
│     │        │       │        │       │ Open Arm     │U │
│     │        │ Stick │        │       │ Open V-Back  │U │
│  2  │ 3-5m   │ TRX   │        │Dynamic│ Squat        │L │
│     │        │       │        │       │ Overhead Sq. │L │
└─────┴────────┴───────┴────────┴───────┴──────────────┴──┘

┌─ Cardiorespiratory Conditioning ──────────── 20-25 mins ─┐
│ ... (same table structure)                                │
└───────────────────────────────────────────────────────────┘

┌─ Metabolic Conditioning ─────────────────── 20-25 mins ──┐
│ ... (Reps + Extra Load instead of BPM)                    │
└───────────────────────────────────────────────────────────┘
```

- **Fitur:**
  - **Read-only view:** Tampilan seperti spreadsheet, warna per sequence (biru=FC, oranye=CC, ungu=MC)
  - **Edit mode:** Klik "Edit" → semua field editable inline
    - Level: dropdown (1, 2, 3-4, 3-5, 4, 4-5, 5)
    - Durasi sequence: text input
    - Per Set: durasi, equipment upper/lower, tipe (dropdown dari master), BPM/extra load
    - Per Item: nama gerakan (autocomplete dari Digital Library via datalist), body part (dropdown), reps, sets
    - Equipment override per item (untuk mid-set equipment changes)
  - **Tambah/Hapus Set:** Button di bawah setiap sequence
  - **Tambah/Hapus Item:** Button di setiap set row
  - **Accordion:** Sequence bisa di-collapse/expand
  - **Auto-init:** Saat buat card baru, sequences otomatis diisi dari program aktif customer
  - **Upsert:** Simpan = replace seluruh card (transactional di backend)
  - **Hapus:** Konfirmasi dialog, hapus seluruh card + nested data
