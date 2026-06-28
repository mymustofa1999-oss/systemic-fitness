# 008 — SF Phase 7b: Consultant Endpoints (queue, clients, clinical notes, lab assign)

## Why

Phase 7a sudah menambah role `consultant`. Phase 7b memberi role itu **alat kerja**: backend endpoints yang men-power Consultant Dashboard di web admin (Phase 7c–7d). Tanpa Phase 7b, role consultant cuma bisa login tanpa bisa melihat antrian asesmen / menulis catatan klinis / di-assign ke Lab Consultation.

Empat capability inti yang di-deliver:

1. **Antrian Review** — list Asesmen v2 status `submitted` yang **belum** punya catatan klinis aktif (queue FIFO untuk consultant).
2. **Klien Saya** — distinct klien yang pernah disentuh consultant via clinical_notes ATAU lab_consultations.
3. **Catatan Klinis CRUD** — table baru `clinical_notes` (per-asesmen atau stand-alone per-klien) dengan workflow draft → publish.
4. **Lab Consultation Assignment** — endpoint dedicated `PATCH /lab-consultations/{id}/assign` (admin/owner only) yang men-set `consultant_id` tanpa harus mengirim payload Update lengkap.

Reference: `SF_Master_Platform_Spec.docx` §03 (Consultant workflow) + plan breakdown Fase 7.

## What changed

### Migration baru

| File | Isi |
|---|---|
| [`database/migrations/049_create_clinical_notes.sql`](../database/migrations/049_create_clinical_notes.sql) | Table `clinical_notes` (assessment_id NULLABLE, client_id, consultant_id, title, content, attachments JSONB, is_visible_to_client, soft delete, 3 partial indexes) + CHECK `client_id ≠ consultant_id` |

### Layer baru

- [`internal/repository/clinical_note_repo.go`](../internal/repository/clinical_note_repo.go)
  - `Create / GetByID / List(filter consultant/client/assessment/only_published) / Update / SoftDelete`
  - `ListClientsForConsultant(consultantID)` — CTE union dari clinical_notes + lab_consultations.

- [`internal/service/clinical_note_service.go`](../internal/service/clinical_note_service.go)
  - `Create / Get / List / Update / Delete / CanRead / ListClients / ListPendingReview`
  - Authorship rules: author di-derive dari JWT, update/delete hanya author atau admin/owner.
  - `CanRead`: client (subject) hanya boleh baca kalau `is_visible_to_client=true`. Trainer di-deny (clinical notes bukan scope trainer).

- [`internal/handler/consultant.go`](../internal/handler/consultant.go) — semua endpoint Phase 7b dalam 1 file.

### Layer existing yang di-extend

- [`internal/repository/assessment_v2_repo.go`](../internal/repository/assessment_v2_repo.go)
  - Tambah struct `PendingReviewItem` (lean projection — tidak ikut payload JSONB).
  - Method `ListPendingClinicalReview(limit)` — query NOT EXISTS clinical_notes WHERE assessment_id=a.id AND deleted_at IS NULL.

- [`internal/repository/lab_consultation_repo.go`](../internal/repository/lab_consultation_repo.go)
  - Method `AssignConsultant(id, consultantID)` — atomic assign + auto-bump status `pending` → `scheduled`.

- [`internal/service/lab_consultation_service.go`](../internal/service/lab_consultation_service.go)
  - Method `AssignConsultant` (thin wrapper + slog).

### DI & route mounting di [`cmd/server/main.go`](../cmd/server/main.go)

```go
clinicalNoteRepo    := repository.NewClinicalNoteRepository(db)
clinicalNoteService := service.NewClinicalNoteService(clinicalNoteRepo, assessmentV2Repo, logger)
consultantHandler   := handler.NewConsultantHandler(clinicalNoteService, labConsultationService)
```

## Endpoint table

| Method | Path | Auth | Body / Query | Response |
|---|---|---|---|---|
| GET | `/api/v2/consultant/queue` | consultant + admin/owner | `?limit=200` | `[PendingReviewItem]` (oldest first) |
| GET | `/api/v2/consultant/clients` | consultant only | — | `[ConsultantClient]` |
| POST | `/api/v2/clinical-notes` | consultant only | `{ assessment_id?, client_id, title?, content, attachments?, is_visible_to_client? }` | `ClinicalNote` 201 |
| GET | `/api/v2/clinical-notes` | consultant + admin/owner | `?consultant_id=&client_id=&assessment_id=&only_published=true` | `[ClinicalNote]` |
| GET | `/api/v2/clinical-notes/{id}` | any auth (ACL via service.CanRead) | — | `ClinicalNote` |
| PATCH | `/api/v2/clinical-notes/{id}` | author or admin/owner | `{ title?, content, attachments?, is_visible_to_client }` | `ClinicalNote` (joined) |
| DELETE | `/api/v2/clinical-notes/{id}` | author or admin/owner | — | `{ message }` (soft delete) |
| PATCH | `/api/v2/lab-consultations/{id}/assign` | admin/owner only | `{ consultant_id }` | `LabConsultation` (joined) |

### `PendingReviewItem` shape

```ts
{
  assessment_id: string,
  user_id: string | null,
  user_name: string | null,
  user_email: string | null,
  classification_id: string | null,
  specific_condition_id: string | null,
  physical_status_level: 'level_0_1' | 'level_2_3' | 'level_4_5_perf' | null,
  program_type: 'condition_specific' | 'preventive' | 'performance_*' | 'waitlist' | null,
  system_score: number | null,
  created_at: ISO8601
}
```

### `ConsultantClient` shape

```ts
{
  client_id: string,
  client_name: string | null,
  client_email: string | null,
  note_count: number,        // # clinical_notes oleh consultant ini
  lab_count: number,         // # lab_consultations assigned ke consultant ini
  last_interaction: ISO8601  // MAX(note.created_at, lab.created_at)
}
```

## RBAC matrix

| Endpoint | owner | admin | finance | consultant | trainer | client |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| GET `/consultant/queue` | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| GET `/consultant/clients` | ✅¹ | ❌ | ❌ | ✅ | ❌ | ❌ |
| POST `/clinical-notes` | ✅¹ | ❌ | ❌ | ✅ | ❌ | ❌ |
| GET `/clinical-notes` (list) | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| GET `/clinical-notes/{id}` | ✅ | ✅ | ✅ | ✅ | ❌² | client only if `is_visible_to_client` |
| PATCH `/clinical-notes/{id}` | ✅ | ✅ | ❌ | author only | ❌ | ❌ |
| DELETE `/clinical-notes/{id}` | ✅ | ✅ | ❌ | author only | ❌ | ❌ |
| PATCH `/lab-consultations/{id}/assign` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |

¹ Owner bypasses semua `RequireRole` checks.
² Trainer secara prinsip tidak masuk scope clinical notes. Kalau nanti perlu, ubah `service.CanRead`.

## How to verify

### Build

```bash
go build ./...           # ✓ pass
go vet ./...             # ✓ pass
go test ./internal/...   # ✓ pass (handler + service)
```

### Local smoke test

```bash
# 1. Apply migration (extract Up section only — psql -f akan run Down juga!)
awk '/^-- \+migrate Up/{p=1;next} /^-- \+migrate Down/{p=0} p' \
  database/migrations/049_create_clinical_notes.sql \
  | PGPASSWORD=fitcoach psql -h localhost -U fitcoach -d fitcoach -v ON_ERROR_STOP=1 -1

# 2. Login & smoke test (gunakan akun consultant dari Phase 7a)
CONSULTANT_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"consultant.maya@fitcoach.app","password":"Consultant@2024"}' \
  | jq -r '.data.tokens.access_token')

# 3. Antrian review
curl -s -H "Authorization: Bearer $CONSULTANT_TOKEN" \
  http://localhost:8080/api/v2/consultant/queue | jq

# 4. Tulis catatan klinis
curl -s -X POST http://localhost:8080/api/v2/clinical-notes \
  -H "Authorization: Bearer $CONSULTANT_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"client_id":"<UUID-budi>","assessment_id":"<UUID-asesmen-budi>","title":"Review Phase A","content":"Catatan...","is_visible_to_client":false}'

# 5. Klien saya
curl -s -H "Authorization: Bearer $CONSULTANT_TOKEN" \
  http://localhost:8080/api/v2/consultant/clients | jq
```

### Verifikasi yang sudah dilakukan

| Skenario | Hasil |
|---|---|
| Queue: assessment yang sudah punya note tidak muncul lagi | ✅ |
| Clients: aggregate note_count + lab_count + last_interaction | ✅ |
| `client_id ≠ consultant_id` enforced (DB CHECK) | ✅ |
| Assessment ≠ client validation (service-side) | ✅ 400 dengan pesan jelas |
| `is_visible_to_client=false` → client GET → 403 | ✅ |
| `is_visible_to_client=true` (publish) → client GET → 200 | ✅ |
| Lab assign oleh consultant → 403 | ✅ |
| Lab assign oleh owner → status auto-bump pending → scheduled | ✅ |

## CI/CD

`.github/workflows/deploy.yml` akan auto-apply migration 049 lewat `ci/run-sql-dir.sh database/migrations _schema_migrations`. Tracker mencegah re-apply.

⚠ **Penting**: Lokal jangan pakai `psql -f migrations/049_create_clinical_notes.sql` langsung — tanpa extract Up section, psql akan jalanin Down section juga (DROP TABLE!). Pakai `awk` extractor seperti contoh di atas, atau jalankan via `ci/run-sql-dir.sh` lokal.

## Rollback

Soft rollback (paling aman, tanpa kehilangan data):

```bash
git revert <commit-hash>   # rollback application code (handler + service + repo)
```

Endpoint akan hilang dari router. Tabel `clinical_notes` tetap ada di DB tanpa traffic. Aman untuk re-apply nanti.

Hard rollback (drop tabel — kehilangan semua catatan klinis):

```sql
DROP TABLE clinical_notes;
DELETE FROM _schema_migrations WHERE filename='049_create_clinical_notes.sql';
```

## Next (Phase 7c–7e)

- **7c**: Web admin sidebar layout untuk role consultant + halaman "Antrian Review" + "Klien Saya". Akan consume `/api/v2/consultant/queue` & `/api/v2/consultant/clients`.
- **7d**: Halaman "Catatan Klinis" per-klien + UI Lab Consultation assignment (drop-down consultant + tombol Assign).
- **7e** (opsional): Mobile badge "Direview oleh Consultant" di hasil Asesmen v2 — consume `/api/v2/clinical-notes?assessment_id=...&only_published=true`.
