# 027 — Training Schedule Assessment

## Overview

Fitur assessment jadwal pelatihan yang memungkinkan konsultan (owner) mengatur:
1. **Jadwal mingguan** (recurring) — client mana dilatih trainer mana, hari apa, jam berapa
2. **Sesi individual** — instance konkret dengan tanggal pasti
3. **Substitusi trainer** — jika trainer A tidak bisa hadir, digantikan sementara oleh trainer B

Hanya **owner** (konsultan) yang dapat mengakses semua endpoint ini.

## Database Schema

### ENUM Types
```sql
training_session_status: scheduled | completed | cancelled | substituted
```

### Tables

#### `training_schedules` — Recurring weekly template
| Column     | Type        | Description                          |
|------------|-------------|--------------------------------------|
| id         | UUID (PK)   | Primary key                          |
| client_id  | UUID (FK)   | Client yang dilatih                  |
| trainer_id | UUID (FK)   | Trainer default                      |
| day_of_week| INT (0-6)   | 0=Minggu, 1=Senin... 6=Sabtu         |
| start_time | TIME        | Jam mulai                            |
| end_time   | TIME        | Jam selesai                          |
| location   | VARCHAR(200)| Lokasi latihan                       |
| notes      | TEXT        | Catatan                              |
| is_active  | BOOLEAN     | Status aktif                         |
| created_by | UUID (FK)   | Konsultan yang membuat               |

#### `training_sessions` — Individual dated sessions
| Column              | Type                   | Description                              |
|---------------------|------------------------|------------------------------------------|
| id                  | UUID (PK)              | Primary key                              |
| schedule_id         | UUID (FK, nullable)    | Reference ke schedule (null = ad-hoc)    |
| client_id           | UUID (FK)              | Client                                   |
| trainer_id          | UUID (FK)              | Trainer aktual (bisa pengganti)          |
| session_date        | DATE                   | Tanggal sesi                             |
| start_time          | TIME                   | Jam mulai                                |
| end_time            | TIME                   | Jam selesai                              |
| status              | training_session_status| Status sesi                              |
| location            | VARCHAR(200)           | Lokasi                                   |
| notes               | TEXT                   | Catatan                                  |
| is_substitute       | BOOLEAN                | Apakah ini sesi pengganti                |
| original_trainer_id | UUID (FK, nullable)    | Trainer asli (jika substitusi)           |
| substitute_reason   | TEXT                   | Alasan penggantian                       |
| created_by          | UUID (FK)              | Konsultan yang membuat                   |

---

## API Endpoints

**All endpoints require `owner` role.**

### Recurring Schedules

#### `GET /api/training-schedules`
List jadwal mingguan.

**Query Parameters:**
| Param      | Type   | Description               |
|------------|--------|---------------------------|
| page       | int    | Page number               |
| limit      | int    | Items per page            |
| search     | string | Cari nama client/trainer  |
| client_id  | string | Filter by client          |
| trainer_id | string | Filter by trainer         |
| day_of_week| int    | Filter by day (0-6)       |
| active     | string | "true" = active only      |

#### `POST /api/training-schedules`
Buat jadwal mingguan baru.

```json
{
  "client_id": "uuid",
  "trainer_id": "uuid",
  "day_of_week": 1,
  "start_time": "08:00",
  "end_time": "09:00",
  "location": "Studio A",
  "notes": "Fokus upper body",
  "is_active": true
}
```

#### `GET /api/training-schedules/{id}`
#### `PUT /api/training-schedules/{id}`
#### `DELETE /api/training-schedules/{id}`

---

### Individual Sessions

#### `GET /api/training-schedules/sessions`
List sesi individual.

**Query Parameters:**
| Param       | Type   | Description              |
|-------------|--------|--------------------------|
| page        | int    | Page number              |
| limit       | int    | Items per page           |
| search      | string | Cari nama client/trainer |
| client_id   | string | Filter by client         |
| trainer_id  | string | Filter by trainer        |
| date_from   | string | From date (YYYY-MM-DD)   |
| date_to     | string | To date (YYYY-MM-DD)     |
| status      | string | scheduled/completed/cancelled/substituted |
| schedule_id | string | Filter by recurring schedule |

#### `POST /api/training-schedules/sessions`
Buat sesi baru.

```json
{
  "schedule_id": "uuid (optional)",
  "client_id": "uuid",
  "trainer_id": "uuid",
  "session_date": "2026-04-07",
  "start_time": "08:00",
  "end_time": "09:00",
  "location": "Studio A",
  "notes": "Week 1 session"
}
```

#### `PUT /api/training-schedules/sessions/{id}`
#### `DELETE /api/training-schedules/sessions/{id}`

---

### Trainer Substitution

#### `POST /api/training-schedules/sessions/{id}/substitute`
Gantikan trainer untuk sesi tertentu.

```json
{
  "substitute_trainer_id": "uuid",
  "reason": "Trainer Lisa sakit, digantikan oleh Fajar"
}
```

**Response:** Updated session with `is_substitute: true`, `original_trainer_id`, and `substitute_reason` populated.

---

## Day of Week Reference

| Value | Day     |
|-------|---------|
| 0     | Minggu  |
| 1     | Senin   |
| 2     | Selasa  |
| 3     | Rabu    |
| 4     | Kamis   |
| 5     | Jumat   |
| 6     | Sabtu   |
