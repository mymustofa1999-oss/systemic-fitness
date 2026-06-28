# 019 — File Upload (Image to WebP)

## Overview

Image upload endpoint with automatic WebP conversion. All uploaded images are converted to WebP format to minimize file size while maintaining quality.

---

## Features

- **Max file size**: 5 MB (configurable via `MAX_UPLOAD_SIZE_MB`)
- **Accepted formats**: JPEG, PNG, GIF, WebP
- **Output format**: WebP (quality 80%)
- **Storage**: Local filesystem (`UPLOAD_DIR`, default: `./uploads`)
- **Tracking**: All uploads recorded in `uploads` table with metadata
- **Entity linking**: Optional `entity_type` + `entity_id` to associate uploads with other records
- **Static serving**: Files served at `GET /uploads/{filename}`

---

## Environment Variables

```env
MAX_UPLOAD_SIZE_MB=5          # Max upload size in megabytes
UPLOAD_DIR=./uploads          # Local directory for stored files
BASE_URL=http://localhost:8080  # Base URL for generating file URLs
```

---

## Database Table

```sql
uploads (
    id              UUID PRIMARY KEY,
    original_name   TEXT NOT NULL,       -- Original filename from client
    stored_name     TEXT NOT NULL,       -- Generated filename on disk (*.webp)
    mime_type       TEXT NOT NULL,       -- Always "image/webp" after conversion
    size_bytes      BIGINT NOT NULL,    -- File size after WebP conversion
    width           INT,                 -- Image width in pixels
    height          INT,                 -- Image height in pixels
    path            TEXT NOT NULL,       -- Full filesystem path
    url             TEXT NOT NULL,       -- Public URL to access file
    uploaded_by     UUID NOT NULL,       -- User who uploaded
    entity_type     TEXT,                -- Optional: 'user', 'food', 'exercise', etc.
    entity_id       UUID,                -- Optional: FK to related entity
    created_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ          -- Soft delete
)
```

---

## API Endpoints

All endpoints require authentication (JWT Bearer token).

### Upload Image

```
POST /api/uploads
Content-Type: multipart/form-data
```

**Form fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | file | Yes | Image file (JPEG/PNG/GIF/WebP, max 5MB) |
| `entity_type` | string | No | Entity type to link (e.g. `user`, `food`, `exercise`) |
| `entity_id` | string | No | Entity UUID to link |

**Response (201):**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "original_name": "photo.jpg",
    "stored_name": "1711234567_photo.webp",
    "mime_type": "image/webp",
    "size_bytes": 45200,
    "width": 800,
    "height": 600,
    "url": "http://localhost:8080/uploads/1711234567_photo.webp",
    "uploaded_by": "user-uuid",
    "entity_type": "food",
    "entity_id": "food-uuid",
    "created_at": "2024-03-23T10:00:00Z"
  }
}
```

**Error responses:**
- `400` — File too large / unsupported format / missing file
- `500` — Internal error

### Get Upload by ID

```
GET /api/uploads/{id}
```

### Delete Upload

```
DELETE /api/uploads/{id}
```

Only the uploader or Admin+ can delete. Soft-deletes the DB record and removes the file from disk.

### List My Uploads

```
GET /api/uploads/my?page=1&limit=20
```

Returns paginated list of uploads by the authenticated user.

---

## Access the Uploaded File

```
GET /uploads/{stored_name}
```

This is a public static file route (no auth required). Example:

```
GET /uploads/1711234567_photo.webp
```

---

## Usage Examples

### Upload with curl

```bash
# Upload an image
curl -X POST http://localhost:8080/api/uploads \
  -H "Authorization: Bearer <token>" \
  -F "file=@photo.jpg"

# Upload and link to a food item
curl -X POST http://localhost:8080/api/uploads \
  -H "Authorization: Bearer <token>" \
  -F "file=@food-photo.png" \
  -F "entity_type=food" \
  -F "entity_id=<food-uuid>"

# Delete an upload
curl -X DELETE http://localhost:8080/api/uploads/<upload-uuid> \
  -H "Authorization: Bearer <token>"
```

---

## Architecture

Follows the standard layered pattern:

```
Handler (upload.go)
  ├── Parses multipart form
  ├── Validates file type & size
  └── Calls service

Service (upload_service.go)
  ├── Decodes image (JPEG/PNG/GIF/WebP)
  ├── Converts to WebP (quality 80%)
  ├── Writes to disk
  ├── Gets dimensions & final size
  └── Saves record via repository

Repository (upload_repo.go)
  └── CRUD operations on uploads table
```

**Dependency:** `github.com/chai2010/webp` for WebP encoding.
