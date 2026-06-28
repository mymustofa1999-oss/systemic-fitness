# 013 — Dashboard (Admin Analytics)

## Endpoints

| Method | Path                          | Auth     | Role          |
|--------|-------------------------------|----------|---------------|
| GET    | /api/dashboard/overview       | Required | admin, finance|
| GET    | /api/dashboard/revenue        | Required | admin, finance|
| GET    | /api/dashboard/engagement     | Required | admin, finance|
| GET    | /api/dashboard/trainers       | Required | admin         |

---

### GET /api/dashboard/overview

High-level platform metrics.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_users": 250,
    "active_users": 180,
    "total_clients": 200,
    "total_trainers": 15,
    "active_subscriptions": 120,
    "monthly_revenue": 45000000,
    "currency": "IDR",
    "workouts_this_month": 1500,
    "new_users_this_month": 25
  }
}
```

---

### GET /api/dashboard/revenue

Monthly revenue chart data.

**Query Parameters:**
| Param  | Type | Default | Description               |
|--------|------|---------|---------------------------|
| months | int  | 12      | Number of months to show  |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "chart": [
      {
        "month": "2024-01",
        "revenue": 42000000,
        "subscriptions_count": 110,
        "new_subscriptions": 15,
        "churned_subscriptions": 5
      },
      {
        "month": "2024-02",
        "revenue": 45000000,
        "subscriptions_count": 120,
        "new_subscriptions": 18,
        "churned_subscriptions": 8
      }
    ],
    "total_revenue": 522000000,
    "avg_monthly_revenue": 43500000,
    "currency": "IDR"
  }
}
```

---

### GET /api/dashboard/engagement

User engagement metrics.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "daily_active_users": 85,
    "weekly_active_users": 150,
    "monthly_active_users": 180,
    "avg_workouts_per_user_week": 3.2,
    "avg_workout_duration_min": 52,
    "total_workouts_this_week": 480,
    "total_workouts_this_month": 1500,
    "most_popular_exercises": [
      { "name": "Bench Press", "count": 320 },
      { "name": "Squat", "count": 280 },
      { "name": "Deadlift", "count": 250 }
    ],
    "most_popular_workout_types": [
      { "type": "strength", "count": 900 },
      { "type": "cardio", "count": 350 },
      { "type": "hiit", "count": 250 }
    ]
  }
}
```

---

### GET /api/dashboard/trainers

Trainer performance metrics (admin only).

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "trainer_id": "trainer-uuid-1",
      "trainer_name": "Coach Mike",
      "avatar_url": "https://...",
      "total_clients": 25,
      "active_clients": 20,
      "programs_created": 8,
      "workouts_created": 15,
      "avg_client_retention_days": 120,
      "client_satisfaction_score": null,
      "revenue_generated": 15000000
    },
    {
      "trainer_id": "trainer-uuid-2",
      "trainer_name": "Coach Sarah",
      "avatar_url": null,
      "total_clients": 18,
      "active_clients": 15,
      "programs_created": 5,
      "workouts_created": 12,
      "avg_client_retention_days": 95,
      "client_satisfaction_score": null,
      "revenue_generated": 10800000
    }
  ]
}
```
