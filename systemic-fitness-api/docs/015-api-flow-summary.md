# 015 — Complete API Flow Summary

## End-to-End User Flows

### Flow 1: New Client Onboarding

```
1. POST /api/auth/register          → Create account (role: client)
2. POST /api/auth/login             → Get access + refresh tokens
3. GET  /api/auth/me                → Load profile + stats
4. PUT  /api/users/{id}             → Update profile (phone, avatar)
   ─── Trainer assigns program ───
5. GET  /api/programs/{id}          → View assigned program details
6. GET  /api/workouts/{id}          → View today's workout with exercises
   ─── Start workout ───
7. POST /api/progress/log           → Log each exercise (sets, reps, weight)
8. POST /api/progress/body-metric   → Log body measurements
9. POST /api/nutrition/log          → Log meals
   ─── Chat with trainer ───
10. POST /api/messages/direct       → Start conversation with trainer
11. POST /api/messages/send         → Send message
12. WS   /ws/messages               → Real-time messaging
```

### Flow 2: Trainer Workflow

```
1. POST /api/auth/login             → Login as trainer
2. GET  /api/users?role=client      → View assigned clients
   ─── Create exercise library ───
3. POST /api/exercises              → Create custom exercises
   ─── Build workouts ───
4. POST /api/workouts               → Create workout templates
   ─── Build programs ───
5. POST /api/programs               → Create training program
6. POST /api/programs/{id}/assign   → Assign to clients
   ─── Monitor clients ───
7. GET  /api/progress/user/{id}     → View client progress
8. GET  /api/progress/user/{id}/charts → View progress charts
9. GET  /api/progress/user/{id}/body-metrics → View body metrics
   ─── Nutrition planning ───
10. POST /api/nutrition/meal-plans  → Create meal plans
11. GET  /api/nutrition/user/{id}/daily → Check client nutrition
   ─── Communication ───
12. POST /api/messages/send         → Send instructions/feedback
13. POST /api/messages/group        → Create group chat for team
   ─── Automation ───
14. POST /api/automations           → Setup automated reminders
```

### Flow 3: Admin Management

```
1. POST /api/auth/login             → Login as admin
   ─── User management ───
2. GET  /api/users                  → View all users
3. POST /api/users/invite           → Invite new trainers/staff
4. PUT  /api/users/{id}             → Manage user status
5. DELETE /api/users/{id}           → Deactivate users
   ─── Content management ───
6. POST /api/exercises              → Add system exercises
7. POST /api/workouts               → Create workout templates
8. POST /api/programs               → Create program templates
   ─── Analytics ───
9. GET  /api/dashboard/overview     → Platform overview
10. GET /api/dashboard/revenue      → Revenue charts
11. GET /api/dashboard/engagement   → User engagement
12. GET /api/dashboard/trainers     → Trainer performance
   ─── Automation ───
13. GET /api/automations            → View all automations
14. POST /api/automations           → Create system automations
```

### Flow 4: Finance Management

```
1. POST /api/auth/login             → Login as finance
   ─── Plan management ───
2. GET  /api/payments/plans         → View all plans
3. POST /api/payments/plans         → Create new plans
4. PUT  /api/payments/plans/{id}    → Update pricing
   ─── Subscription monitoring ───
5. GET  /api/payments/subscriptions → View all subscriptions
   ─── Payment tracking ───
6. GET  /api/payments               → View payment records
7. GET  /api/payments/reports       → Financial reports
   ─── Dashboard ───
8. GET  /api/dashboard/overview     → Revenue overview
9. GET  /api/dashboard/revenue      → Revenue charts
```

### Flow 5: Real-Time Messaging

```
─── Establish connection ───
1. WS   /ws/messages?token=JWT      → Connect WebSocket
   ← Server sends: { type: "unread_count", data: { count: 5 } }

─── Load conversations ───
2. GET  /api/messages/conversations  → List all conversations

─── Open conversation ───
3. GET  /api/messages/conversations/{id} → Load messages
4. POST /api/messages/conversations/{id}/read → Mark as read

─── Send message ───
5. POST /api/messages/send           → Send via REST
   → Server broadcasts to all online members via WebSocket
   ← All members receive: { type: "new_message", data: {...} }

─── Online status ───
6. GET  /api/users/online            → Get online users
   ← Members receive: { type: "user_online" / "user_offline" }
```

### Flow 6: Workout Session (Client)

```
─── Before workout ───
1. GET  /api/auth/me                    → Check active program
2. GET  /api/programs/{id}              → Get today's workout from program
3. GET  /api/workouts/{workout_id}      → Get workout detail + exercises

─── During workout (for each exercise) ───
4. Start exercise → timer begins
5. Complete sets → record in local state
   { set_number: 1, reps: 10, weight_kg: 60, rpe: 7, completed: true }

─── After workout (for each exercise done) ───
6. POST /api/progress/log               → Log exercise progress
   {
     exercise_id: "...",
     workout_id: "...",
     sets: [...],
     notes: "...",
     mood: "good"
   }

─── Post workout ───
7. POST /api/nutrition/log              → Log post-workout meal
8. POST /api/progress/body-metric       → Weekly body check-in
```

## Complete Endpoint Reference

| # | Method | Path | Auth | Role | Description |
|---|--------|------|------|------|-------------|
| 1 | POST | /api/auth/register | - | - | Register new user |
| 2 | POST | /api/auth/login | - | - | Login |
| 3 | POST | /api/auth/refresh | - | - | Refresh tokens |
| 4 | POST | /api/auth/forgot-password | - | - | Password reset |
| 5 | GET | /api/auth/me | Yes | any | Current user profile + stats |
| 6 | GET | /api/users | Yes | admin, trainer | List users |
| 7 | POST | /api/users/invite | Yes | admin | Invite user |
| 8 | GET | /api/users/{id} | Yes | self, admin, trainer | User detail |
| 9 | PUT | /api/users/{id} | Yes | self, admin | Update user |
| 10 | DELETE | /api/users/{id} | Yes | admin | Soft delete user |
| 11 | GET | /api/users/{id}/stats | Yes | self, admin, trainer | User stats |
| 12 | GET | /api/users/online | Yes | any | Online user IDs |
| 13 | POST | /api/users/online/check | Yes | any | Check online status |
| 14 | GET | /api/exercises | - | any | List exercises |
| 15 | GET | /api/exercises/{id} | - | any | Exercise detail |
| 16 | POST | /api/exercises | Yes | admin, trainer | Create exercise |
| 17 | PUT | /api/exercises/{id} | Yes | admin, trainer | Update exercise |
| 18 | DELETE | /api/exercises/{id} | Yes | admin, trainer | Delete exercise |
| 19 | GET | /api/workouts | Yes | any | List workouts |
| 20 | GET | /api/workouts/{id} | Yes | any | Workout detail + exercises |
| 21 | POST | /api/workouts | Yes | admin, trainer | Create workout |
| 22 | PUT | /api/workouts/{id} | Yes | admin, trainer | Update workout |
| 23 | POST | /api/workouts/{id}/duplicate | Yes | admin, trainer | Duplicate workout |
| 24 | GET | /api/programs | Yes | any | List programs |
| 25 | GET | /api/programs/templates | Yes | any | List templates only |
| 26 | GET | /api/programs/{id} | Yes | any | Program detail + days |
| 27 | POST | /api/programs | Yes | admin, trainer | Create program |
| 28 | PUT | /api/programs/{id} | Yes | admin, trainer | Update program |
| 29 | POST | /api/programs/{id}/assign | Yes | admin, trainer | Assign program to users |
| 30 | POST | /api/progress/log | Yes | any | Log exercise progress |
| 31 | POST | /api/progress/body-metric | Yes | any | Log body metrics |
| 32 | GET | /api/progress/user/{id} | Yes | self, admin, trainer | Progress history |
| 33 | GET | /api/progress/user/{id}/charts | Yes | self, admin, trainer | Chart data |
| 34 | GET | /api/progress/user/{id}/body-metrics | Yes | self, admin, trainer | Body metrics history |
| 35 | GET | /api/nutrition/meal-plans | Yes | any | List meal plans |
| 36 | POST | /api/nutrition/meal-plans | Yes | admin, trainer | Create meal plan |
| 37 | POST | /api/nutrition/log | Yes | any | Log nutrition |
| 38 | GET | /api/nutrition/user/{id}/daily | Yes | self, admin, trainer | Daily nutrition |
| 39 | POST | /api/messages/direct | Yes | any | Get/create direct chat |
| 40 | POST | /api/messages/group | Yes | any | Create group chat |
| 41 | POST | /api/messages/send | Yes | any | Send message |
| 42 | GET | /api/messages/conversations | Yes | any | List conversations |
| 43 | GET | /api/messages/conversations/{id} | Yes | any | Conversation messages |
| 44 | POST | /api/messages/conversations/{id}/read | Yes | any | Mark as read |
| 45 | GET | /api/automations | Yes | admin, trainer | List automations |
| 46 | GET | /api/automations/{id} | Yes | admin, trainer | Automation detail |
| 47 | POST | /api/automations | Yes | admin, trainer | Create automation |
| 48 | PUT | /api/automations/{id} | Yes | admin, trainer | Update automation |
| 49 | DELETE | /api/automations/{id} | Yes | admin, trainer | Delete automation |
| 50 | GET | /api/automations/{id}/logs | Yes | admin, trainer | Automation logs |
| 51 | GET | /api/dashboard/overview | Yes | admin, finance | Platform overview |
| 52 | GET | /api/dashboard/revenue | Yes | admin, finance | Revenue chart |
| 53 | GET | /api/dashboard/engagement | Yes | admin, finance | Engagement metrics |
| 54 | GET | /api/dashboard/trainers | Yes | admin | Trainer performance |
| 55 | GET | /api/payments/plans | Yes | any | List payment plans |
| 56 | GET | /api/payments/plans/{id} | Yes | any | Plan detail |
| 57 | POST | /api/payments/plans | Yes | finance | Create plan |
| 58 | PUT | /api/payments/plans/{id} | Yes | finance | Update plan |
| 59 | GET | /api/payments/subscriptions | Yes | finance | List subscriptions |
| 60 | GET | /api/payments | Yes | finance | List payments |
| 61 | GET | /api/payments/reports | Yes | finance | Financial report |
| 62 | WS | /ws/messages?token=JWT | Yes | any | Real-time messaging |
| 63 | POST | /api/notifications/device-token | Yes | any | Register FCM token |
| 64 | DELETE | /api/notifications/device-token | Yes | any | Unregister FCM token |
| 65 | GET | /api/notifications | Yes | any | List notifications |
| 66 | GET | /api/notifications/unread-count | Yes | any | Unread count |
| 67 | POST | /api/notifications/{id}/read | Yes | any | Mark as read |
| 68 | POST | /api/notifications/read-all | Yes | any | Mark all as read |
| 69 | POST | /api/notifications/broadcast | Yes | admin | Send broadcast/promo push |
| 70 | GET | /api/notifications/broadcasts | Yes | admin | List broadcast history |
| 71 | GET | /api/challenges | Yes | any | List challenges |
| 72 | POST | /api/challenges | Yes | admin, trainer | Create challenge |
| 73 | GET | /api/challenges/{id} | Yes | any | Challenge detail |
| 74 | PUT | /api/challenges/{id} | Yes | admin, trainer | Update challenge |
| 75 | DELETE | /api/challenges/{id} | Yes | admin, trainer | Delete challenge |
| 76 | POST | /api/challenges/{id}/join | Yes | any | Join challenge |
| 77 | POST | /api/challenges/{id}/leave | Yes | any | Leave challenge |
| 78 | POST | /api/challenges/{id}/progress | Yes | any | Update challenge progress |
| 79 | GET | /api/challenges/{id}/participants | Yes | any | Challenge leaderboard |
| 80 | GET | /api/groups | Yes | any | List groups |
| 81 | POST | /api/groups | Yes | admin, trainer | Create group |
| 82 | GET | /api/groups/{id} | Yes | any | Group detail |
| 83 | PUT | /api/groups/{id} | Yes | admin, trainer | Update group |
| 84 | DELETE | /api/groups/{id} | Yes | admin, trainer | Delete group |
| 85 | POST | /api/groups/{id}/members | Yes | admin, trainer | Add group member |
| 86 | GET | /api/groups/{id}/members | Yes | any | List group members |
| 87 | DELETE | /api/groups/{id}/members/{userId} | Yes | admin, trainer | Remove group member |
| 88 | GET | /api/announcements/feed | Yes | any | Announcement feed (role-filtered) |
| 89 | POST | /api/announcements/{id}/read | Yes | any | Mark announcement as read |
| 90 | GET | /api/announcements/{id} | Yes | any | Announcement detail |
| 91 | GET | /api/announcements | Yes | admin | List all announcements |
| 92 | POST | /api/announcements | Yes | admin | Create announcement |
| 93 | PUT | /api/announcements/{id} | Yes | admin | Update announcement |
| 94 | DELETE | /api/announcements/{id} | Yes | admin | Delete announcement |
| 95 | POST | /api/uploads | Yes | any | Upload image (WebP conversion) |
| 96 | GET | /api/uploads/{id} | Yes | any | Get upload detail |
| 97 | DELETE | /api/uploads/{id} | Yes | owner, admin | Delete upload |
| 98 | GET | /api/uploads/my | Yes | any | List my uploads |
