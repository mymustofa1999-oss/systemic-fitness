# 021 — Flutter Mobile Update: Challenges, Groups, Announcements & Uploads (Customer Side)

> Copy-paste this document as a prompt when implementing the new features in the Flutter mobile app (systemic-fitness-mobile-new).

---

## PROMPT START

Saya ingin kamu menambahkan fitur-fitur baru di **Systemic Fitness Mobile** (Flutter). Fitur ini untuk **sisi customer/client**. Backend API sudah ready. Ikuti instruksi di bawah ini secara lengkap.

---

## 1. TECH STACK (existing)

```
Framework    : Flutter 3.x (Dart 3.x)
State Mgmt   : StatefulWidget + setState()
Navigation   : GoRouter (deep linking for push notifications)
HTTP Client  : http package (dart:io)
Storage      : SharedPreferences (PrefData wrapper)
Models       : Manual fromJson/toJson (NO json_serializable, NO freezed)
UI           : Custom widgets, percentage-based responsive sizing
Font         : SFProText (main), SecularOne (bold)
```

**Flat Architecture** — Tidak menggunakan Clean Architecture, MVVM, BLoC, Riverpod, atau Provider.

---

## 2. NEW PAGES & FOLDER STRUCTURE

Tambahkan folder dan file berikut di dalam `lib/`:

```
lib/
├── models/
│   ├── challenge_model.dart          # Challenge, ChallengeParticipant
│   ├── group_model.dart              # Group, GroupMember
│   └── announcement_model.dart       # Announcement
├── pages/
│   ├── challenge/
│   │   ├── challenge_list_page.dart  # Browse & filter challenges
│   │   ├── challenge_detail_page.dart # Detail + leaderboard + join/leave
│   │   └── challenge_progress_page.dart # Update my progress
│   ├── group/
│   │   ├── group_list_page.dart      # My groups
│   │   └── group_detail_page.dart    # Group members list
│   └── announcement/
│       └── announcement_feed_page.dart # Announcement feed + mark read
└── widgets/
    ├── challenge_card.dart           # Card for challenge list
    ├── participant_tile.dart         # Leaderboard row
    ├── group_card.dart               # Card for group list
    └── announcement_card.dart        # Card for announcement feed
```

---

## 3. API ENDPOINTS — Tambahkan di `api_config.dart`

```dart
// Challenges
static const String challenges = '/challenges';
static String challengeById(String id) => '/challenges/$id';
static String joinChallenge(String id) => '/challenges/$id/join';
static String leaveChallenge(String id) => '/challenges/$id/leave';
static String challengeProgress(String id) => '/challenges/$id/progress';
static String challengeParticipants(String id) => '/challenges/$id/participants';

// Groups
static const String groups = '/groups';
static String groupById(String id) => '/groups/$id';
static String groupMembers(String id) => '/groups/$id/members';

// Announcements
static const String announcementsFeed = '/announcements/feed';
static String announcementById(String id) => '/announcements/$id';
static String announcementRead(String id) => '/announcements/$id/read';

// Uploads
static const String uploads = '/uploads';
static String uploadById(String id) => '/uploads/$id';
static const String uploadsMyList = '/uploads/my';
```

---

## 4. MODEL DEFINITIONS

### challenge_model.dart

```dart
class ChallengeModel {
  String? id;
  String? name;
  String? description;
  String? imageUrl;
  String? status;           // 'draft', 'active', 'completed', 'cancelled'
  String? startDate;        // 'YYYY-MM-DD'
  String? endDate;
  String? goalType;         // e.g. 'total_reps', 'daily_steps', 'body_fat_pct'
  double? goalValue;
  int? maxParticipants;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? participantCount;

  ChallengeModel({
    this.id, this.name, this.description, this.imageUrl, this.status,
    this.startDate, this.endDate, this.goalType, this.goalValue,
    this.maxParticipants, this.createdBy, this.createdAt, this.updatedAt,
    this.participantCount,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) => ChallengeModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['image_url'],
    status: json['status'],
    startDate: json['start_date'],
    endDate: json['end_date'],
    goalType: json['goal_type'],
    goalValue: (json['goal_value'] as num?)?.toDouble(),
    maxParticipants: json['max_participants'],
    createdBy: json['created_by'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
    participantCount: json['participant_count'],
  );

  /// Whether the challenge is currently running
  bool get isActive => status == 'active';

  /// Days remaining from today until end_date
  int get daysRemaining {
    if (endDate == null) return 0;
    final end = DateTime.tryParse(endDate!);
    if (end == null) return 0;
    return end.difference(DateTime.now()).inDays.clamp(0, 9999);
  }
}

class ChallengeParticipant {
  String? id;
  String? challengeId;
  String? userId;
  double? progressValue;
  String? joinedAt;
  String? completedAt;

  ChallengeParticipant({
    this.id, this.challengeId, this.userId, this.progressValue,
    this.joinedAt, this.completedAt,
  });

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) => ChallengeParticipant(
    id: json['id'],
    challengeId: json['challenge_id'],
    userId: json['user_id'],
    progressValue: (json['progress_value'] as num?)?.toDouble(),
    joinedAt: json['joined_at'],
    completedAt: json['completed_at'],
  );
}
```

### group_model.dart

```dart
class GroupModel {
  String? id;
  String? name;
  String? description;
  String? imageUrl;
  int? maxMembers;
  int? memberCount;
  String? createdBy;
  String? createdAt;
  String? updatedAt;

  GroupModel({
    this.id, this.name, this.description, this.imageUrl,
    this.maxMembers, this.memberCount, this.createdBy,
    this.createdAt, this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['image_url'],
    maxMembers: json['max_members'],
    memberCount: json['member_count'],
    createdBy: json['created_by'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}

class GroupMember {
  String? id;
  String? groupId;
  String? userId;
  String? fullName;
  String? email;
  String? avatarUrl;
  String? role;            // 'admin', 'member'
  String? joinedAt;

  GroupMember({
    this.id, this.groupId, this.userId, this.fullName,
    this.email, this.avatarUrl, this.role, this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) => GroupMember(
    id: json['id'],
    groupId: json['group_id'],
    userId: json['user_id'],
    fullName: json['full_name'],
    email: json['email'],
    avatarUrl: json['avatar_url'],
    role: json['role'],
    joinedAt: json['joined_at'],
  );
}
```

### announcement_model.dart

```dart
class AnnouncementModel {
  String? id;
  String? title;
  String? body;
  String? imageUrl;
  String? status;          // 'draft', 'published', 'archived'
  List<String>? targetRoles;
  String? publishedAt;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  bool? isRead;

  AnnouncementModel({
    this.id, this.title, this.body, this.imageUrl, this.status,
    this.targetRoles, this.publishedAt, this.createdBy,
    this.createdAt, this.updatedAt, this.isRead,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) => AnnouncementModel(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    imageUrl: json['image_url'],
    status: json['status'],
    targetRoles: (json['target_roles'] as List?)?.cast<String>(),
    publishedAt: json['published_at'],
    createdBy: json['created_by'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
    isRead: json['is_read'],
  );
}
```

---

## 5. PAGE IMPLEMENTATIONS

### 5.1 Challenge List Page

**Route:** `/challenges`
**File:** `lib/pages/challenge/challenge_list_page.dart`

```
┌─────────────────────────────┐
│  Challenges           🔍    │
├─────────────────────────────┤
│  [All] [Active] [Completed] │  ← Status filter tabs
├─────────────────────────────┤
│  ┌───────────────────────┐  │
│  │ 🖼 Challenge Image    │  │
│  │ 30 Day Push-Up        │  │
│  │ ● Active  · 27 days   │  │
│  │ 👥 3/50 participants   │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ 🖼 Challenge Image    │  │
│  │ 10K Steps Daily       │  │
│  │ ● Active  · 21 days   │  │
│  │ 👥 2/100 participants  │  │
│  └───────────────────────┘  │
│         Load more ↓         │
└─────────────────────────────┘
```

**Behavior:**
- Load `GET /api/challenges?status=active` on init
- Status filter tabs: All, Active, Completed
- Search field (optional, debounced)
- Pull-to-refresh
- Infinite scroll pagination
- Tap card → navigate to Challenge Detail
- Show skeleton shimmer while loading

**API call:**
```dart
final response = await ApiService.get(ApiConfig.challenges, queryParams: {
  'page': '$page',
  'limit': '20',
  'status': statusFilter,  // omit if 'all'
  'search': searchQuery,   // omit if empty
});
final challenges = (response['data'] as List)
    .map((e) => ChallengeModel.fromJson(e))
    .toList();
final meta = PaginationMeta.fromJson(response['meta']);
```

---

### 5.2 Challenge Detail Page

**Route:** `/challenges/:id`
**File:** `lib/pages/challenge/challenge_detail_page.dart`

```
┌─────────────────────────────┐
│  ← Back                     │
│  ┌───────────────────────┐  │
│  │   Challenge Banner    │  │
│  └───────────────────────┘  │
│  30 Day Push-Up Challenge   │
│  ● Active                   │
│                             │
│  📝 Complete 3000 push-ups  │
│     in 30 days...           │
│                             │
│  📅 Mar 28 — Apr 27, 2026  │
│  🎯 Goal: 3000 total_reps  │
│  👥 3 / 50 participants     │
│  ⏳ 27 days remaining       │
│                             │
│  ┌───────────────────────┐  │
│  │  [Join Challenge]     │  │  ← or [Leave Challenge] if joined
│  └───────────────────────┘  │
│                             │
│  ── Leaderboard ──────────  │
│  1. 🥇 user-uuid  580 reps │
│  2. 🥈 user-uuid  450 reps │
│  3. 🥉 user-uuid  320 reps │
│                             │
│  ┌───────────────────────┐  │
│  │  [Update My Progress] │  │  ← only if joined
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Behavior:**
- Load challenge detail: `GET /api/challenges/{id}`
- Load participants (leaderboard): `GET /api/challenges/{id}/participants`
- Join: `POST /api/challenges/{id}/join` → refresh participants
- Leave: `POST /api/challenges/{id}/leave` → refresh
- "Update My Progress" button → open progress bottom sheet or navigate to progress page
- Determine if user has joined by checking if current user's ID exists in participants list
- Show relative date info (days remaining, days since start)

**API calls:**
```dart
// Load detail
final res = await ApiService.get(ApiConfig.challengeById(id));
final challenge = ChallengeModel.fromJson(res['data']);

// Load leaderboard
final res2 = await ApiService.get(ApiConfig.challengeParticipants(id));
final participants = (res2['data'] as List)
    .map((e) => ChallengeParticipant.fromJson(e))
    .toList();

// Join
await ApiService.post(ApiConfig.joinChallenge(id));

// Leave
await ApiService.post(ApiConfig.leaveChallenge(id));
```

---

### 5.3 Challenge Progress Page

**Route:** `/challenges/:id/progress`
**File:** `lib/pages/challenge/challenge_progress_page.dart`

```
┌─────────────────────────────┐
│  ← Update Progress          │
│                             │
│  30 Day Push-Up Challenge   │
│  🎯 Goal: 3000 total_reps  │
│  📊 My current: 450 reps   │
│                             │
│  ┌───────────────────────┐  │
│  │  Progress Value       │  │
│  │  [_______________]    │  │  ← Number input
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  [Submit Progress]    │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**API call:**
```dart
await ApiService.post(ApiConfig.challengeProgress(challengeId), body: {
  'value': progressValue,
});
```

Note: `value` adalah **total kumulatif**, bukan increment. Jadi jika user sudah punya 450 reps dan hari ini push-up 50 lagi, submit `500`.

---

### 5.4 Group List Page

**Route:** `/groups`
**File:** `lib/pages/group/group_list_page.dart`

```
┌─────────────────────────────┐
│  My Groups            🔍    │
├─────────────────────────────┤
│  ┌───────────────────────┐  │
│  │ 🖼  Morning Warriors  │  │
│  │ Early morning group   │  │
│  │ 👥 3/12 members       │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ 🖼  Weight Loss Squad │  │
│  │ Dedicated group for   │  │
│  │ 👥 3/15 members       │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Behavior:**
- Load `GET /api/groups`
- Search by name
- Pull-to-refresh
- Tap card → Group Detail

**API call:**
```dart
final response = await ApiService.get(ApiConfig.groups, queryParams: {
  'page': '$page',
  'limit': '20',
  'search': searchQuery,
});
final groups = (response['data'] as List)
    .map((e) => GroupModel.fromJson(e))
    .toList();
```

---

### 5.5 Group Detail Page

**Route:** `/groups/:id`
**File:** `lib/pages/group/group_detail_page.dart`

```
┌─────────────────────────────┐
│  ← Morning Warriors         │
│                             │
│  🖼 Group Image             │
│  📝 Early morning training  │
│  👥 3/12 members            │
│                             │
│  ── Members ────────────── │
│  👤 Client Name 1  member   │
│  👤 Client Name 2  member   │
│  👤 Client Name 3  member   │
└─────────────────────────────┘
```

**Behavior:**
- Load group detail: `GET /api/groups/{id}`
- Load members: `GET /api/groups/{id}/members`
- Read-only for clients (no add/remove member actions)

---

### 5.6 Announcement Feed Page

**Route:** `/announcements`
**File:** `lib/pages/announcement/announcement_feed_page.dart`

```
┌─────────────────────────────┐
│  Announcements        🔍    │
├─────────────────────────────┤
│  ┌───────────────────────┐  │
│  │ 🔴 NEW                │  │  ← unread indicator
│  │ Welcome to Systemic!  │  │
│  │ We are excited to...  │  │
│  │ 📅 Mar 21, 2026       │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ ✓ Read                │  │
│  │ New Feature: Habits   │  │
│  │ We have added habit.. │  │
│  │ 📅 Mar 25, 2026       │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Behavior:**
- Load `GET /api/announcements/feed`
- Show unread indicator (dot/badge) for `is_read == false`
- Tap card → expand full body text (or navigate to detail page)
- On open/tap → `POST /api/announcements/{id}/read` to mark as read
- Pull-to-refresh
- Infinite scroll pagination
- Search by title

**API calls:**
```dart
// Load feed
final response = await ApiService.get(ApiConfig.announcementsFeed, queryParams: {
  'page': '$page',
  'limit': '20',
});
final announcements = (response['data'] as List)
    .map((e) => AnnouncementModel.fromJson(e))
    .toList();

// Mark as read
await ApiService.post(ApiConfig.announcementRead(id));
```

---

## 6. ROUTING — Tambahkan di `app_router.dart`

```dart
// Challenges
GoRoute(
  path: '/challenges',
  builder: (context, state) => const ChallengeListPage(),
),
GoRoute(
  path: '/challenges/:id',
  builder: (context, state) => ChallengeDetailPage(
    challengeId: state.pathParameters['id']!,
  ),
),
GoRoute(
  path: '/challenges/:id/progress',
  builder: (context, state) => ChallengeProgressPage(
    challengeId: state.pathParameters['id']!,
  ),
),

// Groups
GoRoute(
  path: '/groups',
  builder: (context, state) => const GroupListPage(),
),
GoRoute(
  path: '/groups/:id',
  builder: (context, state) => GroupDetailPage(
    groupId: state.pathParameters['id']!,
  ),
),

// Announcements
GoRoute(
  path: '/announcements',
  builder: (context, state) => const AnnouncementFeedPage(),
),
```

---

## 7. NAVIGATION ENTRY POINTS

Tambahkan menu di **Dashboard Tab** atau **Profile Tab** untuk akses ke fitur baru:

### Option A: Quick Action Cards di Dashboard

```dart
// Di dashboard_tab.dart, tambahkan section:
_buildQuickActions() → Row of cards:
  - "Challenges" → context.push('/challenges')
  - "My Groups" → context.push('/groups')
  - "Announcements" → context.push('/announcements')   // bisa juga badge unread count
```

### Option B: Bottom Navigation Tab (jika mau prominent)

Tambahkan tab "Community" yang berisi:
- Challenges (tab/section)
- Groups (tab/section)
- Announcements (tab/section)

### Option C: Profile Menu Items

```dart
// Di profile_tab.dart, tambahkan list tiles:
ListTile(title: 'Challenges', icon: Trophy, onTap: → '/challenges')
ListTile(title: 'My Groups', icon: Users, onTap: → '/groups')
ListTile(title: 'Announcements', icon: Bell, onTap: → '/announcements')
```

---

## 8. IMAGE UPLOAD UTILITY

Untuk fitur-fitur yang butuh upload gambar (avatar, dll), tambahkan helper method di `api_service.dart`:

```dart
/// Upload an image file via multipart/form-data
static Future<Map<String, dynamic>> uploadImage(
  File file, {
  String? entityType,
  String? entityId,
}) async {
  final token = await PrefData.getAccessToken();
  final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploads}');

  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..files.add(await http.MultipartFile.fromPath('file', file.path));

  if (entityType != null) request.fields['entity_type'] = entityType;
  if (entityId != null) request.fields['entity_id'] = entityId;

  final streamedResponse = await request.send();
  final responseBody = await streamedResponse.stream.bytesToString();
  final body = jsonDecode(responseBody) as Map<String, dynamic>;

  if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
    return body;
  }
  throw ApiException(
    statusCode: streamedResponse.statusCode,
    message: body['message'] ?? 'Upload failed',
  );
}
```

**Usage contoh — upload profile avatar:**

```dart
final result = await ApiService.uploadImage(
  imageFile,
  entityType: 'user',
  entityId: currentUserId,
);
final imageUrl = result['data']['url'];
```

---

## 9. UI GUIDELINES

### Challenge Card (`challenge_card.dart`)

```dart
Widget build(BuildContext context) {
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner image or placeholder
        challenge.imageUrl != null
            ? Image.network(challenge.imageUrl!, height: 150, fit: BoxFit.cover)
            : Container(height: 150, color: Colors.grey[100], child: Icon(Icons.emoji_events)),

        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(challenge.name ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  _StatusBadge(status: challenge.status),
                ],
              ),
              SizedBox(height: 4),
              if (challenge.description != null)
                Text(challenge.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14),
                  SizedBox(width: 4),
                  Text('${challenge.startDate} — ${challenge.endDate}'),
                  Spacer(),
                  Icon(Icons.people, size: 14),
                  SizedBox(width: 4),
                  Text('${challenge.participantCount ?? 0}'),
                  if (challenge.maxParticipants != null)
                    Text('/${challenge.maxParticipants}'),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

### Status Badge Colors

```dart
Color _statusColor(String? status) {
  switch (status) {
    case 'active':    return Colors.green;
    case 'completed': return Colors.blue;
    case 'draft':     return Colors.grey;
    case 'cancelled': return Colors.red;
    default:          return Colors.grey;
  }
}
```

### Announcement Unread Indicator

```dart
// Di announcement_card.dart, show dot jika belum dibaca:
if (announcement.isRead != true)
  Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
  ),
```

---

## 10. COMPLETE API REFERENCE — CUSTOMER ENDPOINTS

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/challenges` | List challenges (paginated, filterable) |
| GET | `/api/challenges/{id}` | Challenge detail |
| POST | `/api/challenges/{id}/join` | Join challenge |
| POST | `/api/challenges/{id}/leave` | Leave challenge |
| POST | `/api/challenges/{id}/progress` | Update my progress (`{ "value": 500 }`) |
| GET | `/api/challenges/{id}/participants` | Leaderboard (sorted by progress desc) |
| GET | `/api/groups` | List groups (paginated) |
| GET | `/api/groups/{id}` | Group detail |
| GET | `/api/groups/{id}/members` | List group members |
| GET | `/api/announcements/feed` | Announcement feed (role-filtered, published only) |
| GET | `/api/announcements/{id}` | Announcement detail |
| POST | `/api/announcements/{id}/read` | Mark as read |
| POST | `/api/uploads` | Upload image (multipart/form-data) |
| GET | `/api/uploads/{id}` | Get upload detail |
| GET | `/api/uploads/my` | List my uploads |

All endpoints require `Authorization: Bearer <access_token>` header.

---

## PROMPT END
