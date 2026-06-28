# 018 — Seed Data: Users & Assignments

## Overview

Seed files provide a complete set of test accounts covering all roles and statuses. Run seeds in order after migrations.

```
database/seeds/
├── 001_seed_exercises.sql      # Exercise library
├── 002_seed_templates.sql      # Workout/program templates
├── 003_seed_admin.sql          # Staff accounts + payment plans
├── 004_seed_customers.sql      # Client accounts
└── 005_seed_trainer_clients.sql # Trainer ↔ Client assignments
```

---

## Staff Accounts

**Password:** `FitCoach@2024`

| Role | Email | Name | Status |
|------|-------|------|--------|
| owner | admin@fitcoach.app | FitCoach Admin | active |
| admin | denny@fitcoach.app | Denny Septiady | active |
| finance | finance@fitcoach.app | Rina Kartika | active |
| trainer | coach.arif@fitcoach.app | Arif Setiawan | active |
| trainer | coach.lisa@fitcoach.app | Lisa Andriani | active |
| trainer | coach.fajar@fitcoach.app | Fajar Nugroho | active |

### Staff Profiles

| Email | Gender | DOB | Height | Weight | Goal | Level |
|-------|--------|-----|--------|--------|------|-------|
| admin@fitcoach.app | male | — | — | — | — | advanced |
| denny@fitcoach.app | male | — | — | — | — | advanced |
| finance@fitcoach.app | female | — | — | — | — | intermediate |
| coach.arif@fitcoach.app | male | 1988-04-10 | 178 cm | 82 kg | gain_muscle | advanced |
| coach.lisa@fitcoach.app | female | 1991-09-25 | 165 cm | 58 kg | maintain | advanced |
| coach.fajar@fitcoach.app | male | 1993-12-05 | 182 cm | 88 kg | gain_muscle | advanced |

---

## Client Accounts

**Password:** `Customer@2024`

| # | Email | Name | Status | Gender | DOB | Height | Weight | Goal | Level |
|---|-------|------|--------|--------|-----|--------|--------|------|-------|
| 1 | budi@example.com | Budi Santoso | active | male | 1995-03-15 | 175 cm | 78 kg | gain_muscle | intermediate |
| 2 | sari@example.com | Sari Dewi | active | female | 1998-07-22 | 160 cm | 55 kg | lose_weight | beginner |
| 3 | andi@example.com | Andi Pratama | active | male | 1992-11-08 | 170 cm | 85 kg | lose_weight | beginner |
| 4 | maya@example.com | Maya Putri | active | female | 2000-01-30 | 165 cm | 60 kg | improve_endurance | intermediate |
| 5 | rizki@example.com | Rizki Ramadhan | active | male | 1997-06-12 | 180 cm | 90 kg | maintain | advanced |
| 6 | diana@example.com | Diana Kusuma | active | female | 1999-05-18 | 158 cm | 52 kg | flexibility | beginner |
| 7 | hendra@example.com | Hendra Wijaya | active | male | 1994-08-20 | 173 cm | 75 kg | gain_muscle | intermediate |
| 8 | wati@example.com | Wati Susilowati | **inactive** | female | 1996-02-14 | 162 cm | 65 kg | lose_weight | beginner |
| 9 | tommy@example.com | Tommy Hidayat | **pending** | male | 2001-10-05 | 168 cm | 70 kg | gain_muscle | beginner |
| 10 | fika@example.com | Fika Ramadhani | **suspended** | female | 1993-04-28 | 170 cm | 68 kg | maintain | intermediate |

---

## Trainer ↔ Client Assignments

```
Coach Arif (strength/muscle focus)
├── Budi Santoso    [active]   — gain_muscle, intermediate
├── Andi Pratama    [active]   — lose_weight, beginner
└── Hendra Wijaya   [active]   — gain_muscle, intermediate

Coach Lisa (cardio/flexibility focus)
├── Sari Dewi       [active]   — lose_weight, beginner
├── Maya Putri      [active]   — improve_endurance, intermediate
└── Diana Kusuma    [active]   — flexibility, beginner

Coach Fajar (mixed)
├── Rizki Ramadhan  [active]   — maintain, advanced
└── Wati Susilowati [paused]   — lose_weight, beginner (inactive client)
```

**Unassigned clients:**
- Tommy Hidayat — pending status, belum di-assign
- Fika Ramadhani — suspended status, belum di-assign

---

## Payment Plans

| Name | Price (IDR) | Duration | Features |
|------|-------------|----------|----------|
| Basic | 299,000 | 1 month | Workout library, 1 program, progress tracking, chat |
| Pro | 499,000 | 1 month | + Unlimited programs, nutrition, body metrics, priority support |
| Premium | 999,000 | 1 month | + Video call, custom meal plan, dedicated trainer, automation |
| Annual Pro | 4,790,000 | 12 months | Pro features, save 20% |

---

## Role Access Summary

| Action | owner | admin | finance | trainer | client |
|--------|:-----:|:-----:|:-------:|:-------:|:------:|
| Manage all users | ✅ | ✅ | — | — | — |
| View payment reports | ✅ | ✅ | ✅ | — | — |
| Manage exercises/programs | ✅ | ✅ | — | ✅ | — |
| View assigned clients | ✅ | ✅ | — | ✅ (own) | — |
| Create workouts | ✅ | ✅ | — | ✅ | — |
| Log progress | ✅ | — | — | — | ✅ (own) |
| Send broadcast | ✅ | ✅ | — | — | — |
| View own profile | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Quick Login Reference

For development/testing, use these credentials:

```bash
# Owner
curl -X POST /api/auth/login -d '{"email":"admin@fitcoach.app","password":"FitCoach@2024"}'

# Admin
curl -X POST /api/auth/login -d '{"email":"denny@fitcoach.app","password":"FitCoach@2024"}'

# Finance
curl -X POST /api/auth/login -d '{"email":"finance@fitcoach.app","password":"FitCoach@2024"}'

# Trainer
curl -X POST /api/auth/login -d '{"email":"coach.arif@fitcoach.app","password":"FitCoach@2024"}'

# Client
curl -X POST /api/auth/login -d '{"email":"budi@example.com","password":"Customer@2024"}'
```
