# 014 — Payments & Subscriptions

## Endpoints

| Method | Path                            | Auth     | Role    |
|--------|---------------------------------|----------|---------|
| GET    | /api/payments/plans             | Required | any     |
| GET    | /api/payments/plans/{id}        | Required | any     |
| POST   | /api/payments/plans             | Required | finance |
| PUT    | /api/payments/plans/{id}        | Required | finance |
| GET    | /api/payments/subscriptions     | Required | finance |
| GET    | /api/payments                   | Required | finance |
| GET    | /api/payments/reports           | Required | finance |

---

### GET /api/payments/plans

List payment plans.

**Query Parameters:**
| Param       | Type | Default | Description               |
|-------------|------|---------|---------------------------|
| active_only | bool | false   | Only show active plans    |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "plan-uuid-1",
      "name": "Basic Plan",
      "description": "For individual trainers",
      "price": 299000,
      "currency": "IDR",
      "duration_months": 1,
      "features": [
        "Up to 10 clients",
        "Basic workout builder",
        "Progress tracking",
        "Direct messaging"
      ],
      "max_clients": 10,
      "is_active": true,
      "created_at": "2024-01-01T00:00:00Z"
    },
    {
      "id": "plan-uuid-2",
      "name": "Pro Plan",
      "description": "For growing fitness businesses",
      "price": 599000,
      "currency": "IDR",
      "duration_months": 1,
      "features": [
        "Up to 50 clients",
        "Advanced workout builder",
        "Program templates",
        "Nutrition planning",
        "Automations",
        "Analytics dashboard"
      ],
      "max_clients": 50,
      "is_active": true,
      "created_at": "2024-01-01T00:00:00Z"
    },
    {
      "id": "plan-uuid-3",
      "name": "Enterprise Plan",
      "description": "For gyms and studios",
      "price": 1499000,
      "currency": "IDR",
      "duration_months": 1,
      "features": [
        "Unlimited clients",
        "Multiple trainers",
        "All features included",
        "Priority support",
        "Custom branding"
      ],
      "max_clients": null,
      "is_active": true,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

---

### POST /api/payments/plans

Create a payment plan (finance role only).

**Request:**
```json
{
  "name": "Annual Pro Plan",
  "description": "Pro plan with annual discount",
  "price": 5990000,
  "currency": "IDR",
  "duration_months": 12,
  "features": [
    "Up to 50 clients",
    "All Pro features",
    "2 months free"
  ],
  "max_clients": 50
}
```

**Response (201):**
```json
{
  "success": true,
  "data": { "...plan object with id..." },
  "message": "Payment plan created successfully"
}
```

---

### PUT /api/payments/plans/{id}

Update a payment plan. Partial update supported.

---

### GET /api/payments/subscriptions

List subscriptions with filters (finance role only).

**Query Parameters:**
| Param      | Type   | Default    | Description                    |
|------------|--------|------------|--------------------------------|
| page       | int    | 1          |                                |
| limit      | int    | 20         | max 100                        |
| status     | string |            | active, cancelled, expired, past_due |
| plan_id    | string |            | Filter by plan UUID            |
| sort_by    | string | created_at |                                |
| sort_order | string | desc       |                                |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "sub-uuid",
      "user_id": "user-uuid",
      "user_name": "John Doe",
      "user_email": "john@example.com",
      "plan_id": "plan-uuid",
      "plan_name": "Pro Plan",
      "status": "active",
      "started_at": "2024-01-01T00:00:00Z",
      "expires_at": "2024-02-01T00:00:00Z",
      "cancelled_at": null,
      "payment_method": "bank_transfer",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 120, "total_pages": 6 }
}
```

---

### GET /api/payments

List payment records (finance role only).

**Query Parameters:**
| Param      | Type   | Default    | Description                    |
|------------|--------|------------|--------------------------------|
| page       | int    | 1          |                                |
| limit      | int    | 20         | max 100                        |
| status     | string |            | pending, completed, failed, refunded |
| date_from  | string |            | ISO date (YYYY-MM-DD)          |
| date_to    | string |            | ISO date (YYYY-MM-DD)          |
| sort_by    | string | created_at |                                |
| sort_order | string | desc       |                                |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "payment-uuid",
      "subscription_id": "sub-uuid",
      "user_id": "user-uuid",
      "user_name": "John Doe",
      "amount": 599000,
      "currency": "IDR",
      "status": "completed",
      "payment_method": "bank_transfer",
      "external_id": "INV-2024-001",
      "paid_at": "2024-01-01T10:00:00Z",
      "failed_at": null,
      "refunded_at": null,
      "metadata": {
        "bank": "BCA",
        "account_name": "John Doe"
      },
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 500, "total_pages": 25 }
}
```

---

### GET /api/payments/reports

Financial report for a period (finance role only).

**Query Parameters:**
| Param        | Type   | Required | Description              |
|-------------|--------|----------|--------------------------|
| period_start | string | yes      | Start date (YYYY-MM-DD)  |
| period_end   | string | yes      | End date (YYYY-MM-DD)    |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "period_start": "2024-01-01",
    "period_end": "2024-12-31",
    "total_revenue": 522000000,
    "total_transactions": 500,
    "completed_payments": 480,
    "failed_payments": 15,
    "refunded_payments": 5,
    "avg_transaction_value": 1087500,
    "currency": "IDR",
    "revenue_by_plan": [
      {
        "plan_id": "plan-uuid-1",
        "plan_name": "Basic Plan",
        "revenue": 120000000,
        "count": 400
      },
      {
        "plan_id": "plan-uuid-2",
        "plan_name": "Pro Plan",
        "revenue": 252000000,
        "count": 420
      },
      {
        "plan_id": "plan-uuid-3",
        "plan_name": "Enterprise Plan",
        "revenue": 150000000,
        "count": 100
      }
    ],
    "revenue_by_month": [
      { "month": "2024-01", "revenue": 42000000, "count": 45 },
      { "month": "2024-02", "revenue": 45000000, "count": 48 }
    ]
  }
}
```

## Subscription Status Flow

```
                    ┌─────────┐
           ┌──────→│  active  │──────┐
           │       └─────────┘      │
           │            │           │
    (payment)      (cancel)    (expires)
           │            │           │
           │       ┌─────────┐      │
           │       │cancelled│      │
           │       └─────────┘      │
           │                        │
     ┌──────────┐             ┌─────────┐
     │ past_due │             │ expired  │
     └──────────┘             └─────────┘
```

## Payment Status Flow

```
  pending → completed
  pending → failed
  completed → refunded
```
