class ApiConfig {
  // Default: production (VPS). Can be overridden at build/run time via
  //   --dart-define=API_BASE_URL=http://192.168.1.171:8080/api
  //   --dart-define=API_WS_URL=ws://192.168.1.171:8080/ws/messages
  // (see .vscode/launch.json profile "SF Mobile - Local API").
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.systemicfitnesshealth.com/api',
  );
  static const String wsUrl = String.fromEnvironment(
    'API_WS_URL',
    defaultValue: 'wss://api.systemicfitnesshealth.com/ws/messages',
  );

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
  static String progressCharts(String userId) =>
      '/progress/user/$userId/charts';
  static String bodyMetrics(String userId) =>
      '/progress/user/$userId/body-metrics';

  // Workout sessions (Level 5/6 guided session logs) & reminders
  static const String workoutSessions = '/v2/workout-sessions';
  static const String workoutSessionStats = '/v2/workout-sessions/stats';
  static const String workoutReminder = '/v2/workout-reminders/me';

  // Nutrition
  static const String mealPlans = '/nutrition/meal-plans';
  static const String nutritionLog = '/nutrition/log';
  static String dailyNutrition(String userId) =>
      '/nutrition/user/$userId/daily';

  // Messages
  static const String messagesDirect = '/messages/direct';
  static const String messagesGroup = '/messages/group';
  static const String messagesSend = '/messages/send';
  static const String conversations = '/messages/conversations';
  static String conversationMessages(String id) =>
      '/messages/conversations/$id';
  static String markAsRead(String id) => '/messages/conversations/$id/read';

  // Payments (admin)
  static const String paymentPlans = '/payments/plans';
  static String paymentPlanById(String id) => '/payments/plans/$id';

  // Client Subscriptions
  static const String subscriptionPlans = '/subscription/plans';
  static String subscriptionPlanById(String id) => '/subscription/plans/$id';
  static const String subscriptionSubscribe = '/subscription/subscribe';
  static const String subscriptionMe = '/subscription/me';
  static String subscriptionCancel(String id) => '/subscription/$id/cancel';
  static const String subscriptionHistory = '/subscription/history';
  static const String subscriptionPayments = '/subscription/payments';
  static String subscriptionPaymentProof(String id) =>
      '/subscription/payments/$id/proof';
  static const String subscriptionBankAccounts = '/subscription/bank-accounts';

  // Notifications
  static const String deviceToken = '/notifications/device-token';
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationReadAll = '/notifications/read-all';
  static const String notificationBroadcast = '/notifications/broadcast';
  static const String notificationBroadcasts = '/notifications/broadcasts';

  // Challenges
  static const String challenges = '/challenges';
  static String challengeById(String id) => '/challenges/$id';
  static String joinChallenge(String id) => '/challenges/$id/join';
  static String leaveChallenge(String id) => '/challenges/$id/leave';
  static String challengeProgress(String id) => '/challenges/$id/progress';
  static String challengeParticipants(String id) =>
      '/challenges/$id/participants';

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

  // Nutrition Guidance & Monitoring (paid only)
  static const String nutritionGuidanceProfile = '/nutrition-guidance/profile';
  static const String nutritionGuidancePlan = '/nutrition-guidance/plan';
  static const String nutritionGuidanceDailyLog =
      '/nutrition-guidance/daily/log';
  static const String nutritionGuidanceDailyResult =
      '/nutrition-guidance/daily/result';
  static const String nutritionGuidanceDailyLogs =
      '/nutrition-guidance/daily/logs';

  // Assessments — all endpoints require authentication
  static const String assessmentSchema = '/assessments/schema';
  static const String assessmentFree = '/assessments/free';
  static const String assessmentPaid = '/assessments/paid';
  static const String assessmentsMine = '/assessments';
  static const String assessmentLatest = '/assessments/latest';
  static String assessmentById(String id) => '/assessments/$id';
  static String assessmentPrevious(String id) => '/assessments/$id/previous';

  // SF Assessment v2 (Phase 5)
  static const String assessmentV2 = '/v2/assessments';
  static const String assessmentV2Latest = '/v2/assessments/latest';
  static String assessmentV2ById(String id) => '/v2/assessments/$id';
  static const String assessmentV2ScoreWeights = '/v2/assessments/score-weights';

  // SF Master Data (Phase 1) — dipakai Phase A picker.
  static const String masterConditionClassifications = '/master/condition-classifications';
  static const String masterSpecificConditions = '/master/specific-conditions';
  static const String masterPhysicalStatusLevels = '/master/physical-status-levels';

  // SF Phase 6 — Tier 4 Waitlist + Lab Consultation
  static const String tier4Waitlist = '/v2/tier4-waitlist';
  static const String labConsultations = '/v2/lab-consultations';
  static String labConsultationById(String id) => '/v2/lab-consultations/$id';

  // SF Phase 7e — Clinical Notes (read-only utk klien; hanya yang published)
  static const String clinicalNotes = '/v2/clinical-notes';

  // Habits
  static const String habits = '/habits';
  static String habitById(String id) => '/habits/$id';
  static const String habitLog = '/habits/log';
  static const String habitFolders = '/habits/folders';
  static String habitUserLogs(String userId) => '/habits/user/$userId/logs';

  // Foods
  static const String foods = '/foods';
  static String foodById(String id) => '/foods/$id';

  // Forms
  static const String forms = '/forms';
  static String formById(String id) => '/forms/$id';
  static String formResponses(String id) => '/forms/$id/responses';

  // Scheduling
  static const String schedulingEventTypes = '/scheduling/event-types';
  static const String schedulingEvents = '/scheduling/events';
  static String schedulingEventById(String id) => '/scheduling/events/$id';
  static String schedulingEventParticipants(String id) =>
      '/scheduling/events/$id/participants';
  static const String schedulingAvailability = '/scheduling/availability';
  static String trainerAvailability(String trainerId) =>
      '/scheduling/availability/$trainerId';

  // Digital Library
  static const String digitalLibraryCategories = '/digital-library/categories';
  static const String digitalLibraryLevels = '/digital-library/levels';
  static const String digitalLibraryMovements = '/digital-library/movements';
  static String digitalLibraryMovementById(String id) =>
      '/digital-library/movements/$id';
  static String digitalLibraryCategoryMenu(String code) =>
      '/digital-library/categories/$code/menu';
  static String digitalLibraryCategoryIsolate(String code) =>
      '/digital-library/categories/$code/isolate';
  static String digitalLibraryCategoryDynamic(String code) =>
      '/digital-library/categories/$code/dynamic';
  static String digitalLibraryCategoryProgram(String code) =>
      '/digital-library/categories/$code/program';

  // Program Categories
  static const String programCategories = '/program-categories';
  static String programCategoryById(String id) => '/program-categories/$id';

  // Equipments
  static const String equipments = '/equipments';
  static String equipmentById(String id) => '/equipments/$id';

  // Menus
  static const String myMenus = '/menus/my';

  // Promotions
  static const String promotionsActive = '/promotions/active';

  // Clients
  static const String clients = '/clients';

  // Health Content
  static const String healthNews = '/health-news';
  static const String doctorVideos = '/doctor-videos';
}
