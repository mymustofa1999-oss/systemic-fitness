# 007 — SF Phase 7a: Consultant Role (enum + RBAC + seed)

## Why

Phase 6 sudah membuat **Lab Consultation** + **Tier 4 Waitlist** dengan kolom `consultant_id` yang mereferensi ke `users(id)`. Tapi sampai sebelum migration ini, role `consultant` belum ada di `user_role` enum — semua "Health Consultant" terpaksa pakai role `admin` atau `trainer`, yang scope RBAC-nya tidak match dengan workflow klinis (review Asesmen v2, tulis catatan klinis, assign Lab Consultation).

Phase 7a adalah pondasi data + RBAC: tambahkan role baru, default account, dan pastikan semua oneof validator menerima nilai baru. Halaman Consultant Dashboard di web admin (Antrian Review, Klien Saya, Catatan Klinis, Lab Consultation assignment) akan di-build di **Phase 7c–7d** dan butuh ini sebagai prerequisite.

Reference: `SF_Master_Platform_Spec.docx` §03 (Health Consultant role) + plan breakdown Fase 7.

## What changed

### Migration baru

| File | Isi |
|---|---|
| [`database/migrations/048_add_consultant_role.sql`](../database/migrations/048_add_consultant_role.sql) | `ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'consultant' AFTER 'trainer'`. Down = no-op (PG tidak support DROP enum value). |

### Seed baru

| File | Isi |
|---|---|
| [`database/seeds/022_seed_sf_consultant.sql`](../database/seeds/022_seed_sf_consultant.sql) | 1 default consultant: `consultant.maya@fitcoach.app` / `Consultant@2024` (bcrypt cost 12, verified). Idempoten (`ON CONFLICT DO NOTHING`). |

### Application layer

- [`internal/model/models.go`](../internal/model/models.go)
  - Tambah const `RoleConsultant Role = "consultant"`.
  - Update `Role.IsValid()` switch untuk include consultant.
  - Update `Role.Hierarchy()`: **consultant = 50** (di atas trainer 40, di bawah finance 60). Reasoning: Health Consultant adalah otoritas klinis di atas trainer, tapi di bawah finance/admin yang handle billing & platform.
- [`internal/service/auth_service.go`](../internal/service/auth_service.go) `RegisterInput.Role` — tambah `consultant` ke `oneof`.
- [`internal/service/user_service.go`](../internal/service/user_service.go)
  - `UpdateUserInput.Role` — tambah `consultant` ke `oneof`.
  - `InviteUserInput.Role` — tambah `consultant` ke `oneof`.

### RBAC

Tidak ada wrapper baru di `internal/middleware/rbac.go` — pattern existing tetap berlaku:

```go
// Hanya consultant + owner (owner bypasses):
r.With(middleware.RequireRole(model.RoleConsultant)).Get("/consultant/queue", ...)

// Owner / Admin / Consultant (untuk endpoint Lab Consultation assignment):
r.With(middleware.RequireRole(model.RoleAdmin, model.RoleConsultant)).Patch("/lab-consultations/{id}/assign", ...)

// Atau pakai hierarchy minimum (≥ consultant):
r.With(middleware.RequireMinRole(model.RoleConsultant)).Get("/clinical-notes", ...)
```

`RequireMinRole(RoleConsultant)` akan **lolos**: owner, admin, finance, consultant. **Tolak**: trainer, client. Kalau perlu skip finance, pakai `RequireRole(RoleConsultant, RoleAdmin, RoleOwner)` eksplisit.

## How to verify

### Local

```bash
# 1. Apply migration + seed ke DB lokal
PGPASSWORD=fitcoach psql -h localhost -U fitcoach -d fitcoach \
  -v ON_ERROR_STOP=1 -1 \
  -f database/migrations/048_add_consultant_role.sql

PGPASSWORD=fitcoach psql -h localhost -U fitcoach -d fitcoach \
  -v ON_ERROR_STOP=1 -1 \
  -f database/seeds/022_seed_sf_consultant.sql

# 2. Verifikasi enum
PGPASSWORD=fitcoach psql -h localhost -U fitcoach -d fitcoach \
  -c "SELECT enum_range(NULL::user_role);"
# Expect: {owner,admin,finance,trainer,consultant,client}

# 3. Verifikasi user
PGPASSWORD=fitcoach psql -h localhost -U fitcoach -d fitcoach \
  -c "SELECT email, role, status FROM users WHERE role='consultant';"

# 4. Login via API & cek JWT role claim
curl -s -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"consultant.maya@fitcoach.app","password":"Consultant@2024"}' \
  | jq '.data.user.role'
# Expect: "consultant"
```

### CI/CD (production)

`.github/workflows/deploy.yml` otomatis menjalankan:
1. `ci/run-sql-dir.sh database/migrations _schema_migrations` → migrate 048 baru di-apply (file belum ada di tracker `_schema_migrations`).
2. `ci/run-sql-dir.sh database/seeds _seed_migrations` → seed 022 di-apply (kalau email belum ada).

Tracker memastikan migration & seed hanya jalan sekali. Aman untuk re-deploy.

### Build

```bash
go build ./...    # ✓ pass
go vet ./...      # ✓ pass
go test ./internal/...  # ✓ pass (handler + service)
```

## Rollback

Migration 048 secara teknis tidak bisa di-rollback otomatis (PostgreSQL tidak support `DROP VALUE` dari enum). Kalau perlu revert:

1. **Application-side rollback** (hentikan pemberian role consultant):
   ```bash
   git revert <commit-hash>   # rollback model.go + validate tags
   ```
   Dampak: Endpoint `Register`/`Update`/`Invite` akan menolak role `consultant`. User dengan role `consultant` di DB **tetap valid** dan bisa login (backend masih kenali enum value-nya), tapi tidak ada user baru yang bisa di-assign role itu.

2. **Manual DB rollback** (kalau benar-benar perlu hilangkan enum value):
   ```sql
   -- Pastikan tidak ada user role=consultant
   UPDATE users SET role='admin' WHERE role='consultant';

   -- Recreate enum (recreate semua kolom yang reference user_role!)
   CREATE TYPE user_role_new AS ENUM ('owner','admin','finance','trainer','client');
   ALTER TABLE users ALTER COLUMN role TYPE user_role_new USING role::text::user_role_new;
   ALTER TABLE menus ALTER COLUMN role TYPE user_role_new USING role::text::user_role_new;
   ALTER TABLE announcements ALTER COLUMN target_roles TYPE user_role_new[]
     USING target_roles::text[]::user_role_new[];
   DROP TYPE user_role;
   ALTER TYPE user_role_new RENAME TO user_role;

   -- Hapus tracker entry agar migration tidak ditandai applied
   DELETE FROM _schema_migrations WHERE filename='048_add_consultant_role.sql';
   DELETE FROM _seed_migrations WHERE filename='022_seed_sf_consultant.sql';
   ```

## Next (Phase 7b–7e)

- **7b**: API endpoint khusus consultant — list klien yang di-assign, antrian Asesmen v2 menunggu review, CRUD catatan klinis, Lab Consultation assignment.
- **7c**: Web admin sidebar layout untuk role consultant + halaman "Antrian Review" + "Klien Saya".
- **7d**: Halaman "Catatan Klinis" + UI Lab Consultation assignment.
- **7e** (opsional): Mobile badge "Direview oleh Consultant" di hasil Asesmen v2.
