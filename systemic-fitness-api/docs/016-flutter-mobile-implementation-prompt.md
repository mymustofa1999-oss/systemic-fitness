# 016 — Flutter Mobile Implementation Prompt

> Copy-paste this entire document as a prompt when building the Flutter mobile app.

---

## PROMPT START

Saya ingin kamu membantu membangun aplikasi **Systemic Fitness Mobile** menggunakan Flutter. Aplikasi ini adalah **client mobile app** yang terhubung ke backend Go API yang sudah jadi. Ikuti instruksi di bawah ini secara lengkap.

---

## 1. TECH STACK & ARCHITECTURE

```
Framework    : Flutter 3.x (Dart 3.x)
State Mgmt   : StatefulWidget + setState()
Navigation   : GoRouter (deep linking for push notifications)
HTTP Client  : http package (dart:io)
Storage      : SharedPreferences (PrefData wrapper)
WebSocket    : web_socket_channel
Push Notif   : firebase_messaging + flutter_local_notifications
Models       : Manual fromJson/toJson (NO json_serializable, NO freezed)
UI           : Custom widgets, percentage-based responsive sizing
Font         : SFProText (main), SecularOne (bold)
```

**Flat Architecture** — Tidak menggunakan Clean Architecture, MVVM, BLoC, Riverpod, atau Provider.

---

## 2. FOLDER STRUCTURE

```
lib/
├── main.dart                          # Entry point, theme, notifications
├── constants/
│   ├── app_constants.dart             # Global constants
│   ├── app_colors.dart                # Color palette
│   ├── app_widgets.dart               # Reusable UI helper functions
│   └── size_config.dart               # Responsive sizing
├── data/
│   ├── api_config.dart                # Base URL, endpoints
│   ├── api_service.dart               # HTTP client with auth interceptor
│   ├── pref_data.dart                 # SharedPreferences wrapper
│   ├── websocket_service.dart         # WebSocket connection manager
│   └── push_notification_service.dart # FCM setup, token registration, deep link handler
├── router/
│   └── app_router.dart                # GoRouter config, routes, redirect, deep links
├── models/
│   ├── user_model.dart                # User, UserProfile, UserStats
│   ├── auth_model.dart                # LoginResponse, TokenPair
│   ├── exercise_model.dart            # Exercise
│   ├── workout_model.dart             # Workout, WorkoutDetail, WorkoutExercise
│   ├── program_model.dart             # Program, ProgramDetail, ProgramDay, UserProgram
│   ├── progress_model.dart            # ProgressLog, SetData, BodyMetric, ChartData
│   ├── nutrition_model.dart           # MealPlan, NutritionLog, DailyNutrition
│   ├── message_model.dart             # Conversation, Message, ConversationMember
│   ├── payment_model.dart             # PaymentPlan, Subscription
│   ├── notification_model.dart        # NotificationItem, BroadcastNotification
│   └── pagination_model.dart          # PaginationMeta, ApiResponse wrapper
├── pages/
│   ├── splash_page.dart               # Splash → check auth → route
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── forgot_password_page.dart
│   ├── home/
│   │   ├── home_page.dart             # Bottom nav container
│   │   ├── dashboard_tab.dart         # Stats, active program, quick actions
│   │   ├── workouts_tab.dart          # Browse/search workouts
│   │   ├── messages_tab.dart          # Conversation list
│   │   └── profile_tab.dart           # User profile, settings
│   ├── workout/
│   │   ├── workout_detail_page.dart   # Workout with exercises list
│   │   ├── workout_session_page.dart  # Active workout (timer, logging)
│   │   └── exercise_detail_page.dart  # Exercise info, video, instructions
│   ├── program/
│   │   ├── program_list_page.dart     # Browse programs
│   │   ├── program_detail_page.dart   # Program schedule with days
│   │   └── active_program_page.dart   # Current program progress
│   ├── progress/
│   │   ├── progress_page.dart         # History + charts
│   │   ├── log_progress_page.dart     # Log sets for an exercise
│   │   ├── body_metrics_page.dart     # Body composition history
│   │   └── log_body_metric_page.dart  # Add body measurement
│   ├── nutrition/
│   │   ├── nutrition_page.dart        # Daily nutrition view
│   │   ├── log_nutrition_page.dart    # Log a meal
│   │   └── meal_plans_page.dart       # Browse meal plans
│   ├── messages/
│   │   ├── conversation_list_page.dart
│   │   ├── chat_page.dart             # Real-time chat (WebSocket)
│   │   └── new_conversation_page.dart
│   └── profile/
│       ├── edit_profile_page.dart
│       └── subscription_page.dart     # View plans & current subscription
└── widgets/
    ├── custom_button.dart
    ├── custom_text_field.dart
    ├── loading_widget.dart
    ├── empty_state_widget.dart
    ├── exercise_card.dart
    ├── workout_card.dart
    ├── program_card.dart
    ├── message_bubble.dart
    ├── progress_chart.dart
    ├── nutrition_summary_card.dart
    └── stat_card.dart
```

---

## 3. BASE API CONFIGURATION

**API Base URL:** `http://localhost:8080/api`
**WebSocket URL:** `ws://localhost:8080/ws/messages`

### api_config.dart
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api';
  static const String wsUrl = 'ws://localhost:8080/ws/messages';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String me = '/auth/me';

  // Users
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static String userStats(String id) => '/users/$id/stats';
  static const String usersOnline = '/users/online';
  static const String usersOnlineCheck = '/users/online/check';

  // Exercises
  static const String exercises = '/exercises';
  static String exerciseById(String id) => '/exercises/$id';

  // Workouts
  static const String workouts = '/workouts';
  static String workoutById(String id) => '/workouts/$id';
  static String duplicateWorkout(String id) => '/workouts/$id/duplicate';

  // Programs
  static const String programs = '/programs';
  static const String programTemplates = '/programs/templates';
  static String programById(String id) => '/programs/$id';
  static String assignProgram(String id) => '/programs/$id/assign';

  // Progress
  static const String progressLog = '/progress/log';
  static const String bodyMetric = '/progress/body-metric';
  static String progressHistory(String userId) => '/progress/user/$userId';
  static String progressCharts(String userId) => '/progress/user/$userId/charts';
  static String bodyMetrics(String userId) => '/progress/user/$userId/body-metrics';

  // Nutrition
  static const String mealPlans = '/nutrition/meal-plans';
  static const String nutritionLog = '/nutrition/log';
  static String dailyNutrition(String userId) => '/nutrition/user/$userId/daily';

  // Messages
  static const String messagesDirect = '/messages/direct';
  static const String messagesGroup = '/messages/group';
  static const String messagesSend = '/messages/send';
  static const String conversations = '/messages/conversations';
  static String conversationMessages(String id) => '/messages/conversations/$id';
  static String markAsRead(String id) => '/messages/conversations/$id/read';

  // Payments
  static const String paymentPlans = '/payments/plans';
  static String paymentPlanById(String id) => '/payments/plans/$id';

  // Notifications
  static const String registerDeviceToken = '/notifications/device-token';
  static const String unregisterDeviceToken = '/notifications/device-token';
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';
}
```

### api_service.dart
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final token = await PrefData.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.post(uri, headers: await _headers(), body: jsonEncode(body));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.put(uri, headers: await _headers(), body: jsonEncode(body));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.delete(uri, headers: await _headers());
    if (response.statusCode == 204) return {'success': true};
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: body['message'] ?? 'Unknown error',
      errors: (body['errors'] as List?)?.cast<String>(),
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final List<String>? errors;
  ApiException({required this.statusCode, required this.message, this.errors});
}
```

---

## 4. API RESPONSE FORMAT

Semua response dari server menggunakan envelope format:
```json
{
  "success": true/false,
  "data": { ... },
  "message": "optional",
  "errors": ["..."],
  "meta": { "page": 1, "limit": 20, "total": 100, "total_pages": 5 }
}
```

### pagination_model.dart
```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final List<String>? errors;
  final PaginationMeta? meta;

  ApiResponse({this.success = false, this.data, this.message, this.errors, this.meta});
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta({required this.page, required this.limit, required this.total, required this.totalPages});

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    page: json['page'] ?? 1,
    limit: json['limit'] ?? 20,
    total: json['total'] ?? 0,
    totalPages: json['total_pages'] ?? 0,
  );
}
```

---

## 5. MODEL DEFINITIONS

Semua model menggunakan **manual fromJson/toJson**. Semua field **nullable** kecuali yang pasti ada.

### auth_model.dart
```dart
class LoginResponse {
  final UserModel user;
  final TokenPair tokens;

  LoginResponse({required this.user, required this.tokens});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    user: UserModel.fromJson(json['user']),
    tokens: TokenPair.fromJson(json['tokens']),
  );
}

class TokenPair {
  final String accessToken;
  final String refreshToken;
  final String expiresAt;

  TokenPair({required this.accessToken, required this.refreshToken, required this.expiresAt});

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
    accessToken: json['access_token'],
    refreshToken: json['refresh_token'],
    expiresAt: json['expires_at'],
  );
}
```

### user_model.dart
```dart
class UserModel {
  String? id;
  String? email;
  String? fullName;
  String? phone;
  String? avatarUrl;
  String? role;
  String? status;
  String? timezone;
  String? createdAt;
  UserProfile? profile;
  UserStats? stats;

  UserModel({this.id, this.email, this.fullName, this.phone, this.avatarUrl, this.role, this.status, this.timezone, this.createdAt, this.profile, this.stats});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    fullName: json['full_name'],
    phone: json['phone'],
    avatarUrl: json['avatar_url'],
    role: json['role'],
    status: json['status'],
    timezone: json['timezone'],
    createdAt: json['created_at'],
    profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
    stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'full_name': fullName, 'phone': phone,
    'avatar_url': avatarUrl, 'role': role, 'status': status, 'timezone': timezone,
  };
}

class UserProfile {
  String? dateOfBirth;
  String? gender;
  double? heightCm;
  double? weightKg;
  String? fitnessGoal;
  String? experienceLevel;
  String? medicalNotes;
  String? emergencyContact;

  UserProfile({this.dateOfBirth, this.gender, this.heightCm, this.weightKg, this.fitnessGoal, this.experienceLevel, this.medicalNotes, this.emergencyContact});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    dateOfBirth: json['date_of_birth'],
    gender: json['gender'],
    heightCm: (json['height_cm'] as num?)?.toDouble(),
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    fitnessGoal: json['fitness_goal'],
    experienceLevel: json['experience_level'],
    medicalNotes: json['medical_notes'],
    emergencyContact: json['emergency_contact'],
  );
}

class UserStats {
  int? totalWorkouts;
  int? workoutsThisWeek;
  int? workoutsThisMonth;
  int? currentStreakDays;
  int? longestStreakDays;
  int? totalExerciseMinutes;
  String? activeProgramName;
  String? activeProgramId;
  double? programProgressPct;
  String? lastWorkoutAt;

  UserStats({this.totalWorkouts, this.workoutsThisWeek, this.workoutsThisMonth, this.currentStreakDays, this.longestStreakDays, this.totalExerciseMinutes, this.activeProgramName, this.activeProgramId, this.programProgressPct, this.lastWorkoutAt});

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalWorkouts: json['total_workouts'],
    workoutsThisWeek: json['workouts_this_week'],
    workoutsThisMonth: json['workouts_this_month'],
    currentStreakDays: json['current_streak_days'],
    longestStreakDays: json['longest_streak_days'],
    totalExerciseMinutes: json['total_exercise_minutes'],
    activeProgramName: json['active_program_name'],
    activeProgramId: json['active_program_id'],
    programProgressPct: (json['program_progress_pct'] as num?)?.toDouble(),
    lastWorkoutAt: json['last_workout_at'],
  );
}
```

### exercise_model.dart
```dart
class ExerciseModel {
  String? id;
  String? name;
  String? description;
  List<String>? muscleGroup;
  String? equipment;
  String? difficulty;
  String? videoUrl;
  String? thumbnailUrl;
  List<String>? instructions;
  bool? isSystem;
  String? createdBy;
  String? createdAt;

  ExerciseModel({this.id, this.name, this.description, this.muscleGroup, this.equipment, this.difficulty, this.videoUrl, this.thumbnailUrl, this.instructions, this.isSystem, this.createdBy, this.createdAt});

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    muscleGroup: (json['muscle_group'] as List?)?.cast<String>(),
    equipment: json['equipment'],
    difficulty: json['difficulty'],
    videoUrl: json['video_url'],
    thumbnailUrl: json['thumbnail_url'],
    instructions: (json['instructions'] as List?)?.cast<String>(),
    isSystem: json['is_system'],
    createdBy: json['created_by'],
    createdAt: json['created_at'],
  );
}
```

### workout_model.dart
```dart
class WorkoutModel {
  String? id;
  String? name;
  String? description;
  String? type;
  int? estimatedDurationMin;
  String? createdBy;
  bool? isTemplate;
  String? createdAt;
  List<WorkoutExercise>? exercises;  // Only in detail

  WorkoutModel({this.id, this.name, this.description, this.type, this.estimatedDurationMin, this.createdBy, this.isTemplate, this.createdAt, this.exercises});

  factory WorkoutModel.fromJson(Map<String, dynamic> json) => WorkoutModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    type: json['type'],
    estimatedDurationMin: json['estimated_duration_min'],
    createdBy: json['created_by'],
    isTemplate: json['is_template'],
    createdAt: json['created_at'],
    exercises: (json['exercises'] as List?)?.map((e) => WorkoutExercise.fromJson(e)).toList(),
  );
}

class WorkoutExercise {
  String? id;
  String? exerciseId;
  String? exerciseName;
  List<String>? muscleGroup;
  String? equipment;
  int? orderIndex;
  int? sets;
  int? reps;
  double? weightKg;
  int? restSeconds;
  String? notes;
  int? supersetGroup;

  WorkoutExercise({this.id, this.exerciseId, this.exerciseName, this.muscleGroup, this.equipment, this.orderIndex, this.sets, this.reps, this.weightKg, this.restSeconds, this.notes, this.supersetGroup});

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
    id: json['id'],
    exerciseId: json['exercise_id'],
    exerciseName: json['exercise_name'],
    muscleGroup: (json['muscle_group'] as List?)?.cast<String>(),
    equipment: json['equipment'],
    orderIndex: json['order_index'],
    sets: json['sets'],
    reps: json['reps'],
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    restSeconds: json['rest_seconds'],
    notes: json['notes'],
    supersetGroup: json['superset_group'],
  );
}
```

### program_model.dart
```dart
class ProgramModel {
  String? id;
  String? name;
  String? description;
  int? durationWeeks;
  String? difficulty;
  String? goal;
  String? createdBy;
  bool? isTemplate;
  String? createdAt;
  List<ProgramDay>? days;  // Only in detail

  ProgramModel({this.id, this.name, this.description, this.durationWeeks, this.difficulty, this.goal, this.createdBy, this.isTemplate, this.createdAt, this.days});

  factory ProgramModel.fromJson(Map<String, dynamic> json) => ProgramModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    durationWeeks: json['duration_weeks'],
    difficulty: json['difficulty'],
    goal: json['goal'],
    createdBy: json['created_by'],
    isTemplate: json['is_template'],
    createdAt: json['created_at'],
    days: (json['days'] as List?)?.map((e) => ProgramDay.fromJson(e)).toList(),
  );
}

class ProgramDay {
  String? id;
  int? weekNumber;
  int? dayOfWeek;
  String? workoutId;
  String? workoutName;
  String? workoutType;
  bool? isRestDay;

  ProgramDay({this.id, this.weekNumber, this.dayOfWeek, this.workoutId, this.workoutName, this.workoutType, this.isRestDay});

  factory ProgramDay.fromJson(Map<String, dynamic> json) => ProgramDay(
    id: json['id'],
    weekNumber: json['week_number'],
    dayOfWeek: json['day_of_week'],
    workoutId: json['workout_id'],
    workoutName: json['workout_name'],
    workoutType: json['workout_type'],
    isRestDay: json['is_rest_day'],
  );
}

class UserProgram {
  String? id;
  String? userId;
  String? programId;
  String? assignedBy;
  String? startDate;
  String? endDate;
  String? status;
  int? currentWeek;
  int? currentDay;

  UserProgram({this.id, this.userId, this.programId, this.assignedBy, this.startDate, this.endDate, this.status, this.currentWeek, this.currentDay});

  factory UserProgram.fromJson(Map<String, dynamic> json) => UserProgram(
    id: json['id'],
    userId: json['user_id'],
    programId: json['program_id'],
    assignedBy: json['assigned_by'],
    startDate: json['start_date'],
    endDate: json['end_date'],
    status: json['status'],
    currentWeek: json['current_week'],
    currentDay: json['current_day'],
  );
}
```

### progress_model.dart
```dart
class ProgressLog {
  String? id;
  String? exerciseId;
  String? exerciseName;
  String? workoutId;
  String? loggedAt;
  List<SetData>? sets;
  String? notes;
  String? mood;

  ProgressLog({this.id, this.exerciseId, this.exerciseName, this.workoutId, this.loggedAt, this.sets, this.notes, this.mood});

  factory ProgressLog.fromJson(Map<String, dynamic> json) => ProgressLog(
    id: json['id'],
    exerciseId: json['exercise_id'],
    exerciseName: json['exercise_name'],
    workoutId: json['workout_id'],
    loggedAt: json['logged_at'],
    sets: (json['sets'] as List?)?.map((e) => SetData.fromJson(e)).toList(),
    notes: json['notes'],
    mood: json['mood'],
  );
}

class SetData {
  int? setNumber;
  int? reps;
  double? weightKg;
  int? durationSec;
  int? rpe;
  bool? completed;

  SetData({this.setNumber, this.reps, this.weightKg, this.durationSec, this.rpe, this.completed});

  factory SetData.fromJson(Map<String, dynamic> json) => SetData(
    setNumber: json['set_number'],
    reps: json['reps'],
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    durationSec: json['duration_sec'],
    rpe: json['rpe'],
    completed: json['completed'],
  );

  Map<String, dynamic> toJson() => {
    'set_number': setNumber, 'reps': reps, 'weight_kg': weightKg,
    'duration_sec': durationSec, 'rpe': rpe, 'completed': completed,
  };
}

class BodyMetric {
  String? id;
  String? loggedAt;
  double? weightKg;
  double? bodyFatPct;
  double? muscleMassKg;
  List<String>? photoUrls;
  String? notes;

  BodyMetric({this.id, this.loggedAt, this.weightKg, this.bodyFatPct, this.muscleMassKg, this.photoUrls, this.notes});

  factory BodyMetric.fromJson(Map<String, dynamic> json) => BodyMetric(
    id: json['id'],
    loggedAt: json['logged_at'],
    weightKg: (json['weight_kg'] as num?)?.toDouble(),
    bodyFatPct: (json['body_fat_pct'] as num?)?.toDouble(),
    muscleMassKg: (json['muscle_mass_kg'] as num?)?.toDouble(),
    photoUrls: (json['photo_urls'] as List?)?.cast<String>(),
    notes: json['notes'],
  );
}
```

### nutrition_model.dart
```dart
class MealPlan {
  String? id;
  String? name;
  String? description;
  int? dailyCalories;
  double? proteinG;
  double? carbsG;
  double? fatG;
  String? createdBy;
  String? createdAt;

  MealPlan({this.id, this.name, this.description, this.dailyCalories, this.proteinG, this.carbsG, this.fatG, this.createdBy, this.createdAt});

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    dailyCalories: json['daily_calories'],
    proteinG: (json['protein_g'] as num?)?.toDouble(),
    carbsG: (json['carbs_g'] as num?)?.toDouble(),
    fatG: (json['fat_g'] as num?)?.toDouble(),
    createdBy: json['created_by'],
    createdAt: json['created_at'],
  );
}

class NutritionLog {
  String? id;
  String? mealType;
  String? foodName;
  int? calories;
  double? proteinG;
  double? carbsG;
  double? fatG;
  String? photoUrl;
  String? loggedAt;

  NutritionLog({this.id, this.mealType, this.foodName, this.calories, this.proteinG, this.carbsG, this.fatG, this.photoUrl, this.loggedAt});

  factory NutritionLog.fromJson(Map<String, dynamic> json) => NutritionLog(
    id: json['id'],
    mealType: json['meal_type'],
    foodName: json['food_name'],
    calories: json['calories'],
    proteinG: (json['protein_g'] as num?)?.toDouble(),
    carbsG: (json['carbs_g'] as num?)?.toDouble(),
    fatG: (json['fat_g'] as num?)?.toDouble(),
    photoUrl: json['photo_url'],
    loggedAt: json['logged_at'],
  );
}

class DailyNutrition {
  String? date;
  int? totalCalories;
  double? totalProteinG;
  double? totalCarbsG;
  double? totalFatG;
  List<NutritionLog>? meals;

  DailyNutrition({this.date, this.totalCalories, this.totalProteinG, this.totalCarbsG, this.totalFatG, this.meals});

  factory DailyNutrition.fromJson(Map<String, dynamic> json) => DailyNutrition(
    date: json['date'],
    totalCalories: json['total_calories'],
    totalProteinG: (json['total_protein_g'] as num?)?.toDouble(),
    totalCarbsG: (json['total_carbs_g'] as num?)?.toDouble(),
    totalFatG: (json['total_fat_g'] as num?)?.toDouble(),
    meals: (json['meals'] as List?)?.map((e) => NutritionLog.fromJson(e)).toList(),
  );
}
```

### message_model.dart
```dart
class Conversation {
  String? id;
  String? type;
  String? name;
  LastMessage? lastMessage;
  int? unreadCount;
  List<ConversationMember>? members;
  String? updatedAt;

  Conversation({this.id, this.type, this.name, this.lastMessage, this.unreadCount, this.members, this.updatedAt});

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    type: json['type'],
    name: json['name'],
    lastMessage: json['last_message'] != null ? LastMessage.fromJson(json['last_message']) : null,
    unreadCount: json['unread_count'],
    members: (json['members'] as List?)?.map((e) => ConversationMember.fromJson(e)).toList(),
    updatedAt: json['updated_at'],
  );
}

class LastMessage {
  String? content;
  String? senderName;
  String? createdAt;

  LastMessage({this.content, this.senderName, this.createdAt});

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
    content: json['content'],
    senderName: json['sender_name'],
    createdAt: json['created_at'],
  );
}

class ConversationMember {
  String? userId;
  String? fullName;
  String? avatarUrl;
  String? role;

  ConversationMember({this.userId, this.fullName, this.avatarUrl, this.role});

  factory ConversationMember.fromJson(Map<String, dynamic> json) => ConversationMember(
    userId: json['user_id'],
    fullName: json['full_name'],
    avatarUrl: json['avatar_url'],
    role: json['role'],
  );
}

class MessageModel {
  String? id;
  String? senderId;
  String? senderName;
  String? senderAvatar;
  String? content;
  String? type;
  String? mediaUrl;
  bool? isRead;
  String? createdAt;

  MessageModel({this.id, this.senderId, this.senderName, this.senderAvatar, this.content, this.type, this.mediaUrl, this.isRead, this.createdAt});

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'],
    senderId: json['sender_id'],
    senderName: json['sender_name'],
    senderAvatar: json['sender_avatar'],
    content: json['content'],
    type: json['type'],
    mediaUrl: json['media_url'],
    isRead: json['is_read'],
    createdAt: json['created_at'],
  );
}
```

### payment_model.dart
```dart
class PaymentPlan {
  String? id;
  String? name;
  String? description;
  double? price;
  String? currency;
  int? durationMonths;
  List<String>? features;
  int? maxClients;
  bool? isActive;

  PaymentPlan({this.id, this.name, this.description, this.price, this.currency, this.durationMonths, this.features, this.maxClients, this.isActive});

  factory PaymentPlan.fromJson(Map<String, dynamic> json) => PaymentPlan(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: (json['price'] as num?)?.toDouble(),
    currency: json['currency'],
    durationMonths: json['duration_months'],
    features: (json['features'] as List?)?.cast<String>(),
    maxClients: json['max_clients'],
    isActive: json['is_active'],
  );
}

class Subscription {
  String? id;
  String? userId;
  String? planId;
  String? planName;
  String? status;
  String? startedAt;
  String? expiresAt;
  String? paymentMethod;

  Subscription({this.id, this.userId, this.planId, this.planName, this.status, this.startedAt, this.expiresAt, this.paymentMethod});

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'],
    userId: json['user_id'],
    planId: json['plan_id'],
    planName: json['plan_name'],
    status: json['status'],
    startedAt: json['started_at'],
    expiresAt: json['expires_at'],
    paymentMethod: json['payment_method'],
  );
}
```

### notification_model.dart
```dart
class NotificationItem {
  String? id;
  String? userId;
  String? title;
  String? body;
  String? type;        // workout_reminder, payment_due, subscription_expiring, new_message, milestone, promo, general
  Map<String, dynamic>? data;   // Deep link payload: {"type": "...", "target_id": "..."}
  String? status;      // unread, read, dismissed
  bool? sentViaPush;
  String? pushSentAt;
  String? readAt;
  String? createdAt;

  NotificationItem({this.id, this.userId, this.title, this.body, this.type, this.data, this.status, this.sentViaPush, this.pushSentAt, this.readAt, this.createdAt});

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
    id: json['id'],
    userId: json['user_id'],
    title: json['title'],
    body: json['body'],
    type: json['type'],
    data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    status: json['status'],
    sentViaPush: json['sent_via_push'],
    pushSentAt: json['push_sent_at'],
    readAt: json['read_at'],
    createdAt: json['created_at'],
  );

  /// Apakah notifikasi ini belum dibaca
  bool get isUnread => status == 'unread';

  /// Deep link type dari data payload
  String? get deepLinkType => data?['type'];

  /// Deep link target_id dari data payload
  String? get deepLinkTargetId => data?['target_id'];
}
```

---

## 6. AUTH FLOW & TOKEN MANAGEMENT

### pref_data.dart
```dart
class PrefData {
  static Future<void> setTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<void> setUser(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userJson));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```

### Auth Flow:
```
SplashPage
  └── Check PrefData.isLoggedIn()
        ├── true  → GET /auth/me → HomePage
        │            └── 401? → POST /auth/refresh
        │                         ├── success → retry /auth/me → HomePage
        │                         └── fail → clear tokens → LoginPage
        └── false → LoginPage
                     └── POST /auth/login
                           ├── success → save tokens + user → HomePage
                           └── fail → show error
```

---

## 7. WEBSOCKET SERVICE

### websocket_service.dart
```dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onMessage;
  Function(int)? onUnreadCount;
  Function(String)? onUserOnline;
  Function(String)? onUserOffline;

  Future<void> connect(String token) async {
    final uri = Uri.parse('${ApiConfig.wsUrl}?token=$token');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (data) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final type = json['type'];

        switch (type) {
          case 'unread_count':
            onUnreadCount?.call(json['data']['count']);
            break;
          case 'new_message':
            onMessage?.call(json['data']);
            break;
          case 'user_online':
            onUserOnline?.call(json['data']['user_id']);
            break;
          case 'user_offline':
            onUserOffline?.call(json['data']['user_id']);
            break;
        }
      },
      onError: (error) => print('WebSocket error: $error'),
      onDone: () => print('WebSocket closed'),
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
```

---

## 7.5. PUSH NOTIFICATION SERVICE (FCM)

### Setup Firebase di Flutter

1. Buat project di [Firebase Console](https://console.firebase.google.com)
2. Tambahkan Android app (package name) dan iOS app (bundle ID)
3. Download `google-services.json` → taruh di `android/app/`
4. Download `GoogleService-Info.plist` → taruh di `ios/Runner/`
5. Ikuti setup di [firebase_messaging](https://pub.dev/packages/firebase_messaging)

### push_notification_service.dart
```dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  /// Inisialisasi FCM — panggil di main.dart setelah login
  static Future<void> initialize() async {
    // 1. Request permission (iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Setup local notifications (untuk foreground)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 3. Get FCM token & register ke server
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerTokenToServer(token);
    }

    // 4. Listen token refresh
    _messaging.onTokenRefresh.listen(_registerTokenToServer);

    // 5. Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. Handle background/terminated tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 7. Handle app opened from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Register FCM token ke backend API
  static Future<void> _registerTokenToServer(String token) async {
    try {
      await ApiService.post(ApiConfig.registerDeviceToken, body: {
        'token': token,
        'platform': _getPlatform(),
        'device_name': '', // opsional
      });
    } catch (e) {
      print('Failed to register FCM token: $e');
    }
  }

  /// Unregister token saat logout
  static Future<void> unregisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await ApiService.delete(ApiConfig.unregisterDeviceToken);
      }
    } catch (e) {
      print('Failed to unregister FCM token: $e');
    }
  }

  /// Handle pesan saat app di foreground — tampilkan local notification
  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'fitcoach_channel',
          'FitCoach Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle tap pada notification (background/terminated)
  static void _handleNotificationTap(RemoteMessage message) {
    _navigateFromPayload(message.data);
  }

  /// Handle tap pada local notification (foreground)
  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    final data = jsonDecode(response.payload!) as Map<String, dynamic>;
    _navigateFromPayload(data.cast<String, String>());
  }

  /// Deep link navigation berdasarkan notification payload
  static void _navigateFromPayload(Map<String, dynamic> data) {
    final type = data['type'];
    final targetId = data['target_id'];

    switch (type) {
      case 'workout_reminder':
        AppRouter.router.go('/workouts/$targetId/session');
        break;
      case 'program_reminder':
        AppRouter.router.go('/programs/active');
        break;
      case 'subscription_expiring':
      case 'payment_due':
        AppRouter.router.go('/profile/subscription');
        break;
      case 'new_message':
        AppRouter.router.go('/messages/$targetId');
        break;
      case 'body_metric_reminder':
        AppRouter.router.go('/progress/body-metrics/log');
        break;
      case 'nutrition_reminder':
        AppRouter.router.go('/nutrition/log');
        break;
      case 'milestone':
        AppRouter.router.go('/progress');
        break;
      case 'promo':
        AppRouter.router.go('/profile/subscription');
        break;
      default:
        AppRouter.router.go('/dashboard');
    }
  }

  static String _getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'web';
  }
}
```

### main.dart — Integrasi FCM
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler (harus top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background processing jika diperlukan
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Firebase
  await Firebase.initializeApp();

  // 2. Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

// Panggil setelah login berhasil:
// await PushNotificationService.initialize();

// Panggil saat logout:
// await PushNotificationService.unregisterToken();
```

### Flow Registrasi Token
```
App Launch
  └── Login berhasil
        └── PushNotificationService.initialize()
              ├── requestPermission() (iOS)
              ├── getToken() → POST /api/notifications/device-token
              ├── onTokenRefresh → POST /api/notifications/device-token (upsert)
              ├── onMessage → tampilkan local notification
              ├── onMessageOpenedApp → deep link via GoRouter
              └── getInitialMessage → deep link (app terminated)

Logout
  └── PushNotificationService.unregisterToken()
        └── DELETE /api/notifications/device-token
```

### Notification Center (In-App)
```dart
// Di notification page atau badge di AppBar:
// GET /api/notifications → list notifikasi
// GET /api/notifications/unread-count → badge count
// POST /api/notifications/{id}/read → mark as read saat tap
// POST /api/notifications/read-all → mark all read
```

---

## 8. GOROUTER CONFIGURATION

### app_router.dart

GoRouter digunakan untuk:
- **Deep linking dari push notification** (reminder latihan, pembayaran langganan)
- **Auth redirect guard** (otomatis redirect ke login jika belum auth)
- **Shell route** untuk bottom navigation (preserve tab state)

```dart
import 'package:go_router/go_router.dart';

// Route paths — gunakan constant agar tidak typo
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Home tabs (shell route)
  static const dashboard = '/dashboard';
  static const workouts = '/workouts';
  static const messages = '/messages';
  static const profile = '/profile';

  // Workout routes
  static const workoutDetail = '/workouts/:id';
  static const workoutSession = '/workouts/:id/session';
  static const exerciseDetail = '/exercises/:id';

  // Program routes
  static const programs = '/programs';
  static const programDetail = '/programs/:id';
  static const activeProgram = '/programs/active';

  // Progress routes
  static const progress = '/progress';
  static const logProgress = '/progress/log';           // ?exercise_id=&workout_id=
  static const bodyMetrics = '/progress/body-metrics';
  static const logBodyMetric = '/progress/body-metrics/log';

  // Nutrition routes
  static const nutrition = '/nutrition';
  static const logNutrition = '/nutrition/log';
  static const mealPlans = '/nutrition/meal-plans';

  // Message routes
  static const chat = '/messages/:id';
  static const newConversation = '/messages/new';

  // Profile routes
  static const editProfile = '/profile/edit';
  static const subscription = '/profile/subscription';
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Auth redirect — cek token sebelum setiap navigasi
    redirect: (context, state) async {
      final isLoggedIn = await PrefData.isLoggedIn();
      final isAuthRoute = state.matchedLocation == AppRoutes.login
          || state.matchedLocation == AppRoutes.register
          || state.matchedLocation == AppRoutes.forgotPassword
          || state.matchedLocation == AppRoutes.splash;

      // Belum login & bukan di auth page → redirect ke login
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;

      // Sudah login & masih di login/register → redirect ke dashboard
      if (isLoggedIn && (state.matchedLocation == AppRoutes.login
          || state.matchedLocation == AppRoutes.register)) {
        return AppRoutes.dashboard;
      }

      return null; // no redirect
    },

    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Auth routes (no shell/bottom nav)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Shell route — Bottom Navigation (preserves tab state)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomePage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardTab(),
            ),
          ),
          GoRoute(
            path: AppRoutes.workouts,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WorkoutsTab(),
            ),
          ),
          GoRoute(
            path: AppRoutes.messages,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MessagesTab(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileTab(),
            ),
          ),
        ],
      ),

      // Detail routes (full screen, di atas bottom nav)
      GoRoute(
        path: AppRoutes.workoutDetail,
        builder: (context, state) => WorkoutDetailPage(
          workoutId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.workoutSession,
        builder: (context, state) => WorkoutSessionPage(
          workoutId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail,
        builder: (context, state) => ExerciseDetailPage(
          exerciseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.programs,
        builder: (context, state) => const ProgramListPage(),
      ),
      GoRoute(
        path: AppRoutes.programDetail,
        builder: (context, state) => ProgramDetailPage(
          programId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.activeProgram,
        builder: (context, state) => const ActiveProgramPage(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (context, state) => const ProgressPage(),
      ),
      GoRoute(
        path: AppRoutes.logProgress,
        builder: (context, state) => LogProgressPage(
          exerciseId: state.uri.queryParameters['exercise_id'],
          workoutId: state.uri.queryParameters['workout_id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.bodyMetrics,
        builder: (context, state) => const BodyMetricsPage(),
      ),
      GoRoute(
        path: AppRoutes.logBodyMetric,
        builder: (context, state) => const LogBodyMetricPage(),
      ),
      GoRoute(
        path: AppRoutes.nutrition,
        builder: (context, state) => const NutritionPage(),
      ),
      GoRoute(
        path: AppRoutes.logNutrition,
        builder: (context, state) => const LogNutritionPage(),
      ),
      GoRoute(
        path: AppRoutes.mealPlans,
        builder: (context, state) => const MealPlansPage(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => ChatPage(
          conversationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.newConversation,
        builder: (context, state) => const NewConversationPage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionPage(),
      ),
    ],
  );
}
```

### main.dart (menggunakan GoRouter)
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Systemic Fitness',
      routerConfig: AppRouter.router,
      theme: ThemeData(
        fontFamily: 'SFProText',
        // ... theme config
      ),
    );
  }
}
```

### Navigasi Pattern

```dart
// Navigate ke route
context.go('/dashboard');                              // replace current
context.push('/workouts/abc-123');                      // push on stack
context.push('/workouts/abc-123/session');              // push workout session
context.push('/messages/conv-uuid');                    // deep link ke chat

// Navigate dengan query params
context.push('/progress/log?exercise_id=xxx&workout_id=yyy');

// Pop (back)
context.pop();

// Navigate dari notification handler (tanpa context)
AppRouter.router.go('/workouts/abc-123/session');       // reminder latihan
AppRouter.router.go('/profile/subscription');           // reminder pembayaran
AppRouter.router.go('/messages/conv-uuid');              // new message notif
```

### Push Notification Deep Link Handler

```dart
// Di main.dart atau notification setup
void handleNotificationTap(Map<String, dynamic> payload) {
  final type = payload['type'];
  final targetId = payload['target_id'];

  switch (type) {
    case 'workout_reminder':
      // Reminder: kamu belum latihan hari ini
      AppRouter.router.go('/workouts/$targetId/session');
      break;
    case 'program_reminder':
      // Reminder: jadwal program hari ini
      AppRouter.router.go('/programs/active');
      break;
    case 'subscription_expiring':
      // Reminder: langganan mau habis
      AppRouter.router.go('/profile/subscription');
      break;
    case 'payment_due':
      // Reminder: pembayaran jatuh tempo
      AppRouter.router.go('/profile/subscription');
      break;
    case 'new_message':
      // Notif: ada pesan baru
      AppRouter.router.go('/messages/$targetId');
      break;
    case 'body_metric_reminder':
      // Reminder: waktunya ukur badan
      AppRouter.router.go('/progress/body-metrics/log');
      break;
    case 'nutrition_reminder':
      // Reminder: jangan lupa log makan
      AppRouter.router.go('/nutrition/log');
      break;
    default:
      AppRouter.router.go('/dashboard');
  }
}
```

### Notification Payload Format (dari server automation)

```json
{
  "title": "Waktunya Latihan!",
  "body": "Push Day A menunggu kamu hari ini",
  "data": {
    "type": "workout_reminder",
    "target_id": "workout-uuid"
  }
}
```

```json
{
  "title": "Langganan Hampir Habis",
  "body": "Pro Plan kamu berakhir dalam 3 hari",
  "data": {
    "type": "subscription_expiring",
    "target_id": "subscription-uuid"
  }
}
```

---

## 9. SCREENS TO BUILD (Prioritized)

### Phase 1 — Core (MVP)
1. **SplashPage** — Auth check, routing
2. **LoginPage** — Email + password login
3. **RegisterPage** — Registration form
4. **HomePage** — Bottom navigation (4 tabs: Dashboard, Workouts, Messages, Profile)
5. **DashboardTab** — User stats, active program progress, quick actions
6. **ProfileTab** — User info, edit profile, logout

### Phase 2 — Workouts & Programs
7. **WorkoutsTab** — Browse/search workouts with filters
8. **WorkoutDetailPage** — Exercises list in workout
9. **WorkoutSessionPage** — Active workout: timer, set logging per exercise
10. **ExerciseDetailPage** — Exercise info, video, instructions
11. **ProgramListPage** — Browse programs
12. **ProgramDetailPage** — Weekly schedule view
13. **ActiveProgramPage** — Current progress, today's workout

### Phase 3 — Progress & Nutrition
14. **ProgressPage** — History list + charts (weight progression, volume)
15. **LogProgressPage** — Log sets for an exercise (set_number, reps, weight, RPE)
16. **BodyMetricsPage** — Body composition history with chart
17. **LogBodyMetricPage** — Add weight, body fat, photos
18. **NutritionPage** — Daily view with macro rings/bars
19. **LogNutritionPage** — Log meal (type, name, calories, macros)
20. **MealPlansPage** — Browse available meal plans

### Phase 4 — Messaging
21. **ConversationListPage** — Chat list with last message preview
22. **ChatPage** — Real-time chat with WebSocket
23. **NewConversationPage** — Start new direct or group chat

### Phase 5 — Payments
24. **SubscriptionPage** — View plans, current subscription status

---

## 9. KEY UI PATTERNS

### Dashboard Stats Card
```
┌─────────────────────────────────────┐
│  Total Workouts    │   Streak       │
│      45            │     5 days     │
├────────────────────┼────────────────┤
│  This Week         │   This Month   │
│      3             │     12         │
└─────────────────────────────────────┘
```

### Active Program Card
```
┌─────────────────────────────────────┐
│  PPL Split - 12 Week                │
│  Week 4 / Day 2                     │
│  ████████████░░░░░░░░  65%          │
│  [Continue Workout →]               │
└─────────────────────────────────────┘
```

### Workout Session (Per Exercise)
```
┌─────────────────────────────────────┐
│  Bench Press                    ⓘ   │
│  4 sets × 8 reps @ 80kg            │
│                                     │
│  Set 1: [10] reps [60] kg RPE [7] ✓│
│  Set 2: [8]  reps [60] kg RPE [8] ✓│
│  Set 3: [6]  reps [60] kg RPE [9] ✓│
│  Set 4: [5]  reps [60] kg RPE [10]□│
│                                     │
│  Notes: [________________]          │
│  Mood:  😊 😐 😓                    │
│                                     │
│  Rest Timer: 02:00                  │
└─────────────────────────────────────┘
```

### Nutrition Daily View
```
┌─────────────────────────────────────┐
│  Today: 1850 / 2500 cal            │
│  ██████████████░░░░░░ 74%           │
│                                     │
│  Protein  150/200g  ████████░░      │
│  Carbs    200/300g  ██████░░░░      │
│  Fat       55/80g   ██████░░░░      │
│                                     │
│  🌅 Breakfast: Oatmeal (350 cal)   │
│  ☀️ Lunch: Chicken Rice (550 cal)   │
│  🌙 Dinner: Salmon Veg (650 cal)   │
│  🍎 Snack: Protein Shake (300 cal) │
│                                     │
│  [+ Log Meal]                       │
└─────────────────────────────────────┘
```

---

## 10. DEPENDENCIES (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.0
  web_socket_channel: ^2.4.0
  go_router: ^14.0.0              # Navigation + deep linking
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  fluttertoast: ^8.2.0
  fl_chart: ^0.66.0             # For progress charts
  percent_indicator: ^4.2.0     # Circular/linear progress
  table_calendar: ^3.0.0        # Calendar widget
  intl: ^0.19.0                 # Date formatting
  shimmer: ^3.0.0               # Loading skeleton
  firebase_core: ^3.0.0            # Firebase core
  firebase_messaging: ^15.0.0      # FCM push notifications
  flutter_local_notifications: ^17.0.0
  connectivity_plus: ^5.0.0
```

---

## 11. IMPORTANT RULES

1. **Semua state management pakai `setState()`** — JANGAN gunakan BLoC, Provider, Riverpod, GetX
2. **Semua model manual** — JANGAN gunakan json_serializable atau freezed
3. **Navigasi pakai GoRouter** — gunakan `context.go()` / `context.push()` — JANGAN gunakan `Navigator.push()` langsung atau auto_route
4. **HTTP pakai `http` package** — JANGAN gunakan Dio
5. **Setiap API call harus handle error** — tampilkan toast via Fluttertoast
6. **Token refresh otomatis** — jika 401, coba refresh, jika gagal redirect ke login
7. **Loading state** — tampilkan shimmer/spinner saat loading
8. **Empty state** — tampilkan ilustrasi + teks jika data kosong
9. **Pull to refresh** — pada semua halaman list
10. **Pagination** — infinite scroll untuk halaman list
11. **Offline handling** — check connectivity, tampilkan pesan jika offline
12. **Semua navigasi via GoRouter** — gunakan `AppRoutes` constants, JANGAN hardcode path string
13. **Deep link dari notifikasi** — handle semua notification type di `handleNotificationTap()`
14. **Auth guard via GoRouter redirect** — JANGAN manual check auth di setiap halaman
15. **FCM token register setelah login** — panggil `PushNotificationService.initialize()` setelah login berhasil
16. **FCM token unregister saat logout** — panggil `PushNotificationService.unregisterToken()` sebelum clear tokens
17. **Foreground notification** — tampilkan via `flutter_local_notifications`, JANGAN abaikan
18. **Notification badge** — tampilkan unread count di icon bell/AppBar, update via GET `/notifications/unread-count`

---

## 12. NOTIFICATION DEEP LINK SCENARIOS

| Trigger (dari Automation API) | Notification | Deep Link Target |
|-------------------------------|-------------|------------------|
| `on_inactive_days` (3 hari) | "Kamu belum latihan 3 hari" | `/workouts/{id}/session` atau `/programs/active` |
| `scheduled` (setiap pagi) | "Jadwal latihan hari ini: Push Day A" | `/workouts/{workout_id}/session` |
| `on_milestone` (streak 7) | "Streak 7 hari! Terus semangat!" | `/progress` |
| Subscription expiring | "Langganan habis dalam 3 hari" | `/profile/subscription` |
| Payment due | "Pembayaran jatuh tempo" | `/profile/subscription` |
| New message | "Pesan baru dari Coach Mike" | `/messages/{conversation_id}` |
| `on_program_complete` | "Selamat! Program selesai!" | `/progress` |
| Body metric reminder | "Waktunya ukur badan mingguan" | `/progress/body-metrics/log` |
| Nutrition reminder | "Jangan lupa log makan siang" | `/nutrition/log` |
| Admin broadcast (promo) | "Diskon 50% paket Pro!" | `/profile/subscription` |
| Admin broadcast (announcement) | "Fitur baru: Nutrition Tracker" | `/dashboard` |

---

## 13. NOTIFICATION API ENDPOINTS (Flutter harus implement)

| Method | Endpoint | Kapan dipanggil |
|--------|----------|-----------------|
| POST | `/notifications/device-token` | Setelah login + token refresh |
| DELETE | `/notifications/device-token` | Saat logout |
| GET | `/notifications` | Notification center page |
| GET | `/notifications/unread-count` | Badge count di AppBar |
| POST | `/notifications/{id}/read` | Tap notification item |
| POST | `/notifications/read-all` | Tap "Mark all as read" |

---

## PROMPT END
