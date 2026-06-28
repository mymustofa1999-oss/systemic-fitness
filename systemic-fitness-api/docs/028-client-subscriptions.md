# 028 — Client Subscription Plans

API untuk client berlangganan layanan fitness coaching. Terdapat 3 tier (Basic, Pro, Elite) dengan opsi billing bulanan dan tahunan.

## Pricing Summary

| Tier      | Monthly     | Annual        | Diskon |
|-----------|-------------|---------------|--------|
| Basic     | Rp 99.000   | Rp 999.000    | 16%    |
| Pro       | Rp 299.000  | Rp 2.499.000  | 30%    |
| Elite     | Rp 799.000  | Rp 6.999.000  | 27%    |

## Endpoints

| Method | Path                              | Auth     | Role   | Description                        |
|--------|-----------------------------------|----------|--------|------------------------------------|
| GET    | /api/subscription/plans           | Required | any    | List semua plan (grouped by tier)  |
| GET    | /api/subscription/plans/{id}      | Required | any    | Detail plan                        |
| POST   | /api/subscription/subscribe       | Required | any    | Subscribe ke plan                  |
| GET    | /api/subscription/me              | Required | any    | Langganan aktif saat ini           |
| POST   | /api/subscription/{id}/cancel     | Required | any    | Batalkan langganan                 |
| GET    | /api/subscription/history         | Required | any    | Riwayat langganan (paginated)      |
| GET    | /api/subscription/payments        | Required | any    | Riwayat pembayaran (paginated)     |

---

### GET /api/subscription/plans

List semua subscription plan yang aktif, di-group berdasarkan tier.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "tier": "basic",
      "monthly": {
        "id": "plan-uuid-1",
        "name": "Basic",
        "description": "Cocok untuk pemula yang ingin mulai latihan mandiri.",
        "tier": "basic",
        "billing_period": "monthly",
        "price": 99000,
        "original_price": null,
        "currency": "IDR",
        "duration_months": 1,
        "discount_pct": 0,
        "features": [
          "Akses video workout library",
          "1 program latihan dasar",
          "Progress tracking",
          "Panduan latihan pemula"
        ],
        "is_popular": false,
        "sort_order": 1
      },
      "annual": {
        "id": "plan-uuid-2",
        "name": "Basic Annual",
        "description": "Basic plan — hemat 16% dengan pembayaran tahunan.",
        "tier": "basic",
        "billing_period": "annual",
        "price": 999000,
        "original_price": 1188000,
        "currency": "IDR",
        "duration_months": 12,
        "discount_pct": 16,
        "features": [
          "Semua fitur Basic",
          "Hemat 16%",
          "Akses penuh 12 bulan"
        ],
        "is_popular": false,
        "sort_order": 2
      }
    },
    {
      "tier": "pro",
      "monthly": {
        "id": "plan-uuid-3",
        "name": "Pro",
        "description": "Paling populer — untuk kamu yang serius ingin transformasi.",
        "tier": "pro",
        "billing_period": "monthly",
        "price": 299000,
        "original_price": null,
        "currency": "IDR",
        "duration_months": 1,
        "discount_pct": 0,
        "features": [
          "Semua fitur Basic",
          "Program terstruktur (bulking, cutting, dll)",
          "Nutrition tracking",
          "Body metrics & progress foto",
          "Chat terbatas dengan coach",
          "Akses komunitas"
        ],
        "is_popular": true,
        "sort_order": 3
      },
      "annual": {
        "id": "plan-uuid-4",
        "name": "Pro Annual",
        "description": "Pro plan — hemat 30% dengan pembayaran tahunan.",
        "tier": "pro",
        "billing_period": "annual",
        "price": 2499000,
        "original_price": 3588000,
        "currency": "IDR",
        "duration_months": 12,
        "discount_pct": 30,
        "features": [
          "Semua fitur Pro",
          "Hemat 30%",
          "Bonus: 2 sesi konsultasi gratis",
          "Akses penuh 12 bulan"
        ],
        "is_popular": false,
        "sort_order": 4
      }
    },
    {
      "tier": "elite",
      "monthly": {
        "id": "plan-uuid-5",
        "name": "Elite",
        "description": "Mendekati personal trainer — custom plan + review mingguan.",
        "tier": "elite",
        "billing_period": "monthly",
        "price": 799000,
        "original_price": null,
        "currency": "IDR",
        "duration_months": 1,
        "discount_pct": 0,
        "features": [
          "Semua fitur Pro",
          "Custom workout plan",
          "Custom meal plan",
          "Review progress mingguan",
          "Chat langsung dengan coach",
          "Prioritas support"
        ],
        "is_popular": false,
        "sort_order": 5
      },
      "annual": {
        "id": "plan-uuid-6",
        "name": "Elite Annual",
        "description": "Elite plan — hemat 27% dengan pembayaran tahunan.",
        "tier": "elite",
        "billing_period": "annual",
        "price": 6999000,
        "original_price": 9588000,
        "currency": "IDR",
        "duration_months": 12,
        "discount_pct": 27,
        "features": [
          "Semua fitur Elite",
          "Hemat 27%",
          "Bonus: 1-on-1 video call per bulan",
          "Akses penuh 12 bulan"
        ],
        "is_popular": false,
        "sort_order": 6
      }
    }
  ]
}
```

---

### GET /api/subscription/plans/{id}

Detail satu plan.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "plan-uuid-3",
    "name": "Pro",
    "tier": "pro",
    "billing_period": "monthly",
    "price": 299000,
    "original_price": null,
    "currency": "IDR",
    "duration_months": 1,
    "discount_pct": 0,
    "features": ["..."],
    "is_popular": true,
    "sort_order": 3
  }
}
```

**Error (404):**
```json
{ "success": false, "message": "Subscription plan not found" }
```

---

### POST /api/subscription/subscribe

Subscribe ke plan. Membuat subscription + payment record (status pending).

**Request:**
```json
{
  "plan_id": "plan-uuid-3",
  "payment_method": "bank_transfer"
}
```

| Field          | Type   | Required | Description                              |
|---------------|--------|----------|------------------------------------------|
| plan_id       | string | yes      | UUID plan yang dipilih                   |
| payment_method| string | yes      | Metode bayar (bank_transfer, ewallet, dll)|

**Response (201):**
```json
{
  "success": true,
  "data": {
    "subscription": {
      "id": "sub-uuid",
      "plan_id": "plan-uuid-3",
      "plan_name": "Pro",
      "tier": "pro",
      "billing_period": "monthly",
      "status": "active",
      "started_at": "2026-04-05T10:00:00Z",
      "expires_at": "2026-05-05T10:00:00Z",
      "cancelled_at": null,
      "payment_method": "bank_transfer",
      "created_at": "2026-04-05T10:00:00Z"
    },
    "payment": {
      "id": "payment-uuid",
      "subscription_id": "sub-uuid",
      "amount": 299000,
      "currency": "IDR",
      "status": "pending",
      "payment_method": "bank_transfer",
      "external_id": null,
      "paid_at": null,
      "metadata": {},
      "created_at": "2026-04-05T10:00:00Z"
    }
  },
  "message": "Berhasil berlangganan! Silakan selesaikan pembayaran."
}
```

**Error (409) — Already Subscribed:**
```json
{ "success": false, "message": "Kamu sudah memiliki langganan aktif. Batalkan terlebih dahulu untuk beralih plan." }
```

**Error (404) — Plan Not Found:**
```json
{ "success": false, "message": "Plan langganan tidak ditemukan" }
```

---

### GET /api/subscription/me

Langganan aktif user saat ini.

**Response (200) — Has Active Subscription:**
```json
{
  "success": true,
  "data": {
    "has_subscription": true,
    "subscription": {
      "id": "sub-uuid",
      "plan_id": "plan-uuid-3",
      "plan_name": "Pro",
      "tier": "pro",
      "billing_period": "monthly",
      "status": "active",
      "started_at": "2026-04-05T10:00:00Z",
      "expires_at": "2026-05-05T10:00:00Z",
      "cancelled_at": null,
      "payment_method": "bank_transfer",
      "created_at": "2026-04-05T10:00:00Z"
    },
    "days_remaining": 28
  }
}
```

**Response (200) — No Active Subscription:**
```json
{
  "success": true,
  "data": {
    "has_subscription": false
  }
}
```

---

### POST /api/subscription/{id}/cancel

Batalkan langganan aktif. `{id}` = subscription UUID.

**Response (200):**
```json
{
  "success": true,
  "message": "Langganan berhasil dibatalkan"
}
```

**Error (404):**
```json
{ "success": false, "message": "Tidak ada langganan aktif yang bisa dibatalkan" }
```

---

### GET /api/subscription/history

Riwayat semua langganan user (paginated).

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page  | int  | 1       |             |
| limit | int  | 20      | max 100     |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "sub-uuid-1",
      "plan_id": "plan-uuid-3",
      "plan_name": "Pro",
      "tier": "pro",
      "billing_period": "monthly",
      "status": "cancelled",
      "started_at": "2026-03-01T00:00:00Z",
      "expires_at": "2026-04-01T00:00:00Z",
      "cancelled_at": "2026-03-15T08:00:00Z",
      "payment_method": "bank_transfer",
      "created_at": "2026-03-01T00:00:00Z"
    },
    {
      "id": "sub-uuid-2",
      "plan_id": "plan-uuid-1",
      "plan_name": "Basic",
      "tier": "basic",
      "billing_period": "monthly",
      "status": "expired",
      "started_at": "2026-02-01T00:00:00Z",
      "expires_at": "2026-03-01T00:00:00Z",
      "cancelled_at": null,
      "payment_method": "ewallet",
      "created_at": "2026-02-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 5, "total_pages": 1 }
}
```

---

### GET /api/subscription/payments

Riwayat pembayaran user (paginated).

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page  | int  | 1       |             |
| limit | int  | 20      | max 100     |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "payment-uuid",
      "subscription_id": "sub-uuid",
      "amount": 299000,
      "currency": "IDR",
      "status": "completed",
      "payment_method": "bank_transfer",
      "external_id": "INV-2026-001",
      "paid_at": "2026-04-05T10:30:00Z",
      "metadata": {},
      "created_at": "2026-04-05T10:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 3, "total_pages": 1 }
}
```

---

## Subscription Lifecycle

```
  ┌────────────────────────────────────────────────┐
  │              CLIENT SUBSCRIPTION FLOW           │
  └────────────────────────────────────────────────┘

  1. Client → GET /subscription/plans
     ↓ (pilih plan)
  2. Client → POST /subscription/subscribe
     ↓ (subscription: active, payment: pending)
  3. Payment gateway callback → payment: completed
     ↓
  4. Client → GET /subscription/me
     ↓ (cek status & sisa hari)
  5. Client → POST /subscription/{id}/cancel  (optional)
     ↓ (subscription: cancelled)

  Auto-expire:
  - Scheduler cek daily → jika expires_at < NOW() → status = expired
```

## Positioning Psikologis

```
  ┌─────────────────────────────────────────────────────────┐
  │  "Harga 1 sesi PT offline = Rp 800.000                 │
  │   Di sini kamu dapat 1 bulan full program + coaching    │
  │   mulai Rp 299.000"                                    │
  └─────────────────────────────────────────────────────────┘
```
