# 010 — Nutrition

## Endpoints

| Method | Path                              | Auth     | Role           |
|--------|-----------------------------------|----------|----------------|
| GET    | /api/nutrition/meal-plans         | Required | any            |
| POST   | /api/nutrition/meal-plans         | Required | admin, trainer |
| POST   | /api/nutrition/log                | Required | any            |
| GET    | /api/nutrition/user/{id}/daily    | Required | self, admin, trainer |

---

### GET /api/nutrition/meal-plans

List meal plans with pagination.

**Query Parameters:**
| Param | Type | Default | Description     |
|-------|------|---------|-----------------|
| page  | int  | 1       |                 |
| limit | int  | 20      | max 100         |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "meal-plan-uuid",
      "name": "Bulking Plan - 3000 cal",
      "description": "High protein bulking diet",
      "daily_calories": 3000,
      "protein_g": 200.0,
      "carbs_g": 350.0,
      "fat_g": 80.0,
      "created_by": "trainer-uuid",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 5, "total_pages": 1 }
}
```

---

### POST /api/nutrition/meal-plans

Create a meal plan. Admin/trainer only.

**Request:**
```json
{
  "name": "Cutting Plan - 2000 cal",
  "description": "High protein deficit diet for fat loss",
  "daily_calories": 2000,
  "protein_g": 180.0,
  "carbs_g": 150.0,
  "fat_g": 65.0
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "meal-plan-uuid",
    "name": "Cutting Plan - 2000 cal",
    "...rest of meal plan..."
  },
  "message": "Meal plan created successfully"
}
```

---

### POST /api/nutrition/log

Log a nutrition entry (food consumed).

**Request:**
```json
{
  "meal_type": "lunch",
  "food_name": "Grilled Chicken Breast with Rice",
  "calories": 550,
  "protein_g": 45.0,
  "carbs_g": 60.0,
  "fat_g": 12.0,
  "photo_url": "https://example.com/food-photo.jpg"
}
```

**Meal Types:** `breakfast`, `lunch`, `dinner`, `snack`

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "nutrition-log-uuid",
    "user_id": "user-uuid",
    "logged_at": "2024-01-15T12:30:00Z",
    "meal_type": "lunch",
    "food_name": "Grilled Chicken Breast with Rice",
    "calories": 550,
    "protein_g": 45.0,
    "carbs_g": 60.0,
    "fat_g": 12.0,
    "photo_url": "https://example.com/food-photo.jpg"
  },
  "message": "Nutrition logged successfully"
}
```

---

### GET /api/nutrition/user/{id}/daily

Get daily nutrition summary for a specific date.

**Query Parameters:**
| Param | Type   | Default | Description                    |
|-------|--------|---------|--------------------------------|
| date  | string | today   | Date in YYYY-MM-DD format      |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "date": "2024-01-15",
    "total_calories": 1850,
    "total_protein_g": 150.0,
    "total_carbs_g": 200.0,
    "total_fat_g": 55.0,
    "meals": [
      {
        "id": "log-uuid-1",
        "meal_type": "breakfast",
        "food_name": "Oatmeal with Banana",
        "calories": 350,
        "protein_g": 15.0,
        "carbs_g": 55.0,
        "fat_g": 8.0,
        "photo_url": null,
        "logged_at": "2024-01-15T07:00:00Z"
      },
      {
        "id": "log-uuid-2",
        "meal_type": "lunch",
        "food_name": "Grilled Chicken Breast with Rice",
        "calories": 550,
        "protein_g": 45.0,
        "carbs_g": 60.0,
        "fat_g": 12.0,
        "photo_url": "https://example.com/food.jpg",
        "logged_at": "2024-01-15T12:30:00Z"
      },
      {
        "id": "log-uuid-3",
        "meal_type": "dinner",
        "food_name": "Salmon with Vegetables",
        "calories": 650,
        "protein_g": 55.0,
        "carbs_g": 30.0,
        "fat_g": 25.0,
        "photo_url": null,
        "logged_at": "2024-01-15T19:00:00Z"
      },
      {
        "id": "log-uuid-4",
        "meal_type": "snack",
        "food_name": "Protein Shake",
        "calories": 300,
        "protein_g": 35.0,
        "carbs_g": 55.0,
        "fat_g": 10.0,
        "photo_url": null,
        "logged_at": "2024-01-15T16:00:00Z"
      }
    ]
  }
}
```
