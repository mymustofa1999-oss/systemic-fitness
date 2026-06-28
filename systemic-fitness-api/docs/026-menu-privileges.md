# 026 — Menu Management & Role Privileges

## Overview

Dynamic menu system yang menyimpan konfigurasi sidebar navigation di database. Setiap menu dapat di-assign hak akses berdasarkan role (owner, admin, finance, trainer, client). Hanya **owner** (konsultan/pembuat sistem) yang dapat mengelola menu dan privilege.

## Database Schema

### Tables

#### `menus`
| Column     | Type         | Description                              |
|------------|--------------|------------------------------------------|
| id         | UUID (PK)    | Primary key                              |
| parent_id  | UUID (FK)    | Self-reference for hierarchy (NULL=root) |
| code       | VARCHAR(50)  | Unique identifier code                   |
| label      | VARCHAR(100) | Display label                            |
| icon       | VARCHAR(50)  | Lucide icon name                         |
| href       | VARCHAR(255) | Route path (NULL = parent group)         |
| sort_order | INT          | Display order                            |
| is_active  | BOOLEAN      | Active/inactive toggle                   |
| created_at | TIMESTAMPTZ  | Created timestamp                        |
| updated_at | TIMESTAMPTZ  | Updated timestamp (auto-trigger)         |

#### `menu_role_privileges`
| Column     | Type         | Description                 |
|------------|--------------|-----------------------------|
| id         | UUID (PK)    | Primary key                 |
| menu_id    | UUID (FK)    | Reference to menus          |
| role       | user_role    | Role enum                   |
| can_access | BOOLEAN      | Whether role can access menu |
| created_at | TIMESTAMPTZ  | Created timestamp           |

**Unique constraint:** `(menu_id, role)`

### ERD

```
menus                          menu_role_privileges
┌──────────────────┐           ┌──────────────────┐
│ id           PK  │◄──────┐  │ id           PK  │
│ parent_id    FK  │───┐   └──│ menu_id      FK  │
│ code         UQ  │   │      │ role             │
│ label            │   │      │ can_access       │
│ icon             │   └──────│                  │
│ href             │          │ created_at       │
│ sort_order       │          └──────────────────┘
│ is_active        │
│ created_at       │
│ updated_at       │
└──────────────────┘
```

---

## API Endpoints

### User Menu (Authenticated)

#### `GET /api/menus/my`
Returns the menu tree filtered by the current user's role (active menus only).

**Auth:** Any authenticated user  
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "parent_id": null,
      "code": "dashboard",
      "label": "Dashboard",
      "icon": "LayoutDashboard",
      "href": "/",
      "sort_order": 1,
      "is_active": true,
      "children": []
    },
    {
      "id": "uuid",
      "parent_id": null,
      "code": "master-libraries",
      "label": "Master Libraries",
      "icon": "Library",
      "href": null,
      "sort_order": 10,
      "is_active": true,
      "children": [
        {
          "id": "uuid",
          "code": "digital-library",
          "label": "Digital Library",
          "icon": "BookOpen",
          "href": "/digital-library",
          "sort_order": 1,
          "children": []
        }
      ]
    }
  ]
}
```

---

### Menu CRUD (Owner Only)

#### `GET /api/menus`
List all menus (flat, paginated).

**Auth:** Owner only  
**Query Parameters:**
| Param  | Type   | Default | Description          |
|--------|--------|---------|----------------------|
| page   | int    | 1       | Page number          |
| limit  | int    | 20      | Items per page       |
| search | string | —       | Search label or code |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "parent_id": null,
      "code": "dashboard",
      "label": "Dashboard",
      "icon": "LayoutDashboard",
      "href": "/",
      "sort_order": 1,
      "is_active": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 28, "total_pages": 2 }
}
```

#### `GET /api/menus/tree`
Full menu tree including inactive menus (admin view).

**Auth:** Owner only  
**Response:** Same as `/api/menus/my` but includes inactive menus.

#### `GET /api/menus/{id}`
Get single menu by ID.

**Auth:** Owner only

#### `POST /api/menus`
Create a new menu.

**Auth:** Owner only  
**Request Body:**
```json
{
  "parent_id": null,
  "code": "new-feature",
  "label": "New Feature",
  "icon": "Star",
  "href": "/new-feature",
  "sort_order": 50,
  "is_active": true
}
```

| Field      | Type    | Required | Validation       |
|------------|---------|----------|------------------|
| parent_id  | string  | No       | Valid menu UUID   |
| code       | string  | Yes      | 1-50 chars, unique|
| label      | string  | Yes      | 1-100 chars      |
| icon       | string  | No       | Lucide icon name |
| href       | string  | No       | Route path       |
| sort_order | int     | No       | Default 0        |
| is_active  | boolean | No       | Default true     |

#### `PUT /api/menus/{id}`
Update an existing menu.

**Auth:** Owner only  
**Request Body:** Same as POST.

#### `DELETE /api/menus/{id}`
Delete a menu (cascades to children and privileges).

**Auth:** Owner only

---

### Reorder

#### `POST /api/menus/reorder`
Batch update sort order and parent assignments.

**Auth:** Owner only  
**Request Body:**
```json
{
  "items": [
    { "id": "uuid-1", "sort_order": 1, "parent_id": null },
    { "id": "uuid-2", "sort_order": 2, "parent_id": null },
    { "id": "uuid-3", "sort_order": 1, "parent_id": "uuid-parent" }
  ]
}
```

---

### Privileges (Owner Only)

#### `GET /api/menus/privileges`
Get all role privileges for all menus.

**Auth:** Owner only  
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "menu_id": "uuid",
      "role": "admin",
      "can_access": true,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### `GET /api/menus/{id}/privileges`
Get role privileges for a specific menu.

**Auth:** Owner only

#### `PUT /api/menus/{id}/privileges`
Set role privileges for a specific menu (replaces all).

**Auth:** Owner only  
**Request Body:**
```json
{
  "privileges": [
    { "role": "owner",   "can_access": true },
    { "role": "admin",   "can_access": true },
    { "role": "finance", "can_access": false },
    { "role": "trainer", "can_access": true },
    { "role": "client",  "can_access": false }
  ]
}
```

#### `PUT /api/menus/privileges/bulk`
Bulk update privileges for multiple menus at once.

**Auth:** Owner only  
**Request Body:**
```json
{
  "items": [
    {
      "menu_id": "uuid-1",
      "privileges": [
        { "role": "admin", "can_access": true },
        { "role": "trainer", "can_access": false }
      ]
    },
    {
      "menu_id": "uuid-2",
      "privileges": [
        { "role": "admin", "can_access": true },
        { "role": "trainer", "can_access": true }
      ]
    }
  ]
}
```

---

## Roles & Access

| Role    | Menu Access              | Can Manage Menus |
|---------|--------------------------|------------------|
| owner   | All menus (full access)  | Yes              |
| admin   | Based on privileges      | No               |
| finance | Based on privileges      | No               |
| trainer | Based on privileges      | No               |
| client  | Based on privileges      | No               |

---

## Default Seed Data

The seed populates menus matching the existing sidebar:

| Menu Code            | Parent          | Default Roles                    |
|----------------------|-----------------|----------------------------------|
| dashboard            | —               | All roles                        |
| messages             | —               | owner, admin, trainer, client    |
| groups               | —               | owner, admin, trainer            |
| challenges           | —               | owner, admin, trainer            |
| clients              | —               | owner, admin, trainer            |
| team                 | —               | owner, admin                     |
| payments             | —               | owner, admin, finance            |
| master-libraries     | —               | owner, admin, trainer            |
| ├ digital-library    | master-libraries| owner, admin, trainer            |
| ├ programs           | master-libraries| owner, admin, trainer            |
| ├ workouts           | master-libraries| owner, admin, trainer            |
| ├ exercises          | master-libraries| owner, admin, trainer            |
| ├ meals              | master-libraries| owner, admin, trainer            |
| ├ foods              | master-libraries| owner, admin, trainer            |
| ├ habits             | master-libraries| owner, admin, trainer            |
| ├ medicines          | master-libraries| owner, admin, trainer            |
| ├ program-categories | master-libraries| owner, admin, trainer            |
| ├ trainer-card-types | master-libraries| owner, admin, trainer            |
| └ forms              | master-libraries| owner, admin, trainer            |
| scheduling           | —               | owner, admin, trainer            |
| ├ calendar           | scheduling      | owner, admin, trainer            |
| ├ availability       | scheduling      | owner, admin, trainer            |
| └ event-types        | scheduling      | owner, admin, trainer            |
| announcements        | —               | owner, admin                     |
| progress             | —               | owner, admin, trainer            |
| automations          | —               | owner, admin, trainer            |
| settings             | —               | All roles                        |
| menu-management      | —               | owner only                       |

---

## Implementation Notes

### Frontend (Next.js Web)

1. **Sidebar** fetches menus from `GET /api/menus/my` on login and caches in React Query
2. **Menu Management page** (`/menu-management`) accessible by owner only
3. Management page shows all menus in a table with:
   - Toggle active/inactive
   - Edit label, icon, href
   - Drag-and-drop reorder (or sort_order input)
   - Role privilege matrix (checkbox grid)
4. Icon names stored as strings, mapped to Lucide components on frontend
