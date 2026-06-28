import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/pages/splash_page.dart';
import 'package:workout/pages/auth/login_page.dart';
import 'package:workout/pages/auth/register_page.dart';
import 'package:workout/pages/auth/forgot_password_page.dart';
import 'package:workout/pages/home/home_page.dart';
import 'package:workout/pages/home/dashboard_tab.dart';
import 'package:workout/pages/home/workouts_tab.dart';
import 'package:workout/pages/home/messages_tab.dart';
import 'package:workout/pages/home/profile_tab.dart';
import 'package:workout/pages/workout/workout_detail_page.dart';
import 'package:workout/pages/workout/workout_session_page.dart';
import 'package:workout/pages/workout/exercise_detail_page.dart';
import 'package:workout/pages/workout/training_card_screen.dart';
import 'package:workout/pages/program/program_list_page.dart';
import 'package:workout/pages/program/program_detail_page.dart';
import 'package:workout/pages/program/active_program_page.dart';
import 'package:workout/pages/progress/progress_page.dart';
import 'package:workout/pages/progress/log_progress_page.dart';
import 'package:workout/pages/progress/body_metrics_page.dart';
import 'package:workout/pages/progress/log_body_metric_page.dart';
import 'package:workout/pages/nutrition/nutrition_page.dart';
import 'package:workout/pages/nutrition/log_nutrition_page.dart';
import 'package:workout/pages/nutrition/meal_plans_page.dart';
import 'package:workout/pages/messages/chat_page.dart';
import 'package:workout/pages/messages/new_conversation_page.dart';
import 'package:workout/pages/profile/edit_profile_page.dart';
import 'package:workout/pages/profile/subscription_page.dart';
import 'package:workout/pages/notifications/notifications_page.dart';
import 'package:workout/pages/auth/guide_intro_page.dart';
import 'package:workout/pages/onboarding_v2/onboarding_v2_screen.dart';
import 'package:workout/pages/assessment_v2/assessment_v2_intro_screen.dart';
import 'package:workout/pages/assessment_v2/phase_a_screen.dart';
import 'package:workout/pages/assessment_v2/phase_a_waitlist_screen.dart';
import 'package:workout/pages/assessment_v2/phase_a_movement_test_screen.dart';
import 'package:workout/pages/assessment_v2/phase_b_screen.dart';
import 'package:workout/pages/assessment_v2/phase_c_screen.dart';
import 'package:workout/pages/assessment_v2/assessment_v2_result_screen.dart';
import 'package:workout/pages/challenge/challenge_list_page.dart';
import 'package:workout/pages/challenge/challenge_detail_page.dart';
import 'package:workout/pages/challenge/challenge_progress_page.dart';
import 'package:workout/pages/group/group_list_page.dart';
import 'package:workout/pages/group/group_detail_page.dart';
import 'package:workout/pages/announcement/announcement_feed_page.dart';
import 'package:workout/pages/assessment/assessment_intro_page.dart';
import 'package:workout/pages/assessment/free_assessment_page.dart';
import 'package:workout/pages/assessment/paid_assessment_page.dart';
import 'package:workout/pages/assessment/assessment_result_page.dart';
import 'package:workout/pages/assessment/assessment_history_page.dart';
import 'package:workout/pages/nutrition_guidance/nutrition_guidance_intro_page.dart';
import 'package:workout/pages/nutrition_guidance/health_profile_form_page.dart';
import 'package:workout/pages/nutrition_guidance/nutrition_plan_page.dart';
import 'package:workout/pages/nutrition_guidance/daily_log_page.dart';
import 'package:workout/pages/nutrition_guidance/nutrition_log_history_page.dart';
import 'package:workout/pages/nutrition_guidance/upgrade_required_page.dart';
import 'package:workout/pages/payments/payment_instruction_page.dart';
import 'package:workout/pages/payments/upload_proof_page.dart';
import 'package:workout/pages/payments/my_payments_page.dart';
import 'package:workout/pages/payments/midtrans_payment_page.dart';
import 'package:workout/pages/payments/payment_result_page.dart';
import 'package:workout/models/payment_model.dart';
import 'package:workout/pages/habits/habits_page.dart';
import 'package:workout/pages/digital_library/digital_library_page.dart';
import 'package:workout/pages/digital_library/dl_movement_detail_page.dart';
import 'package:workout/pages/scheduling/scheduling_page.dart';
import 'package:workout/pages/foods/foods_page.dart';
import 'package:workout/pages/forms/forms_page.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const guide = '/guide';                 // legacy onboarding (deprecated)
  static const onboardingV2 = '/onboarding-v2';  // SF Phase 4 onboarding

  // Home tabs (shell route)
  static const dashboard = '/dashboard';
  static const workouts = '/workouts';
  static const messages = '/messages';
  static const profile = '/profile';

  // Workout routes
  static const workoutDetail = '/workouts/:id';
  static const workoutSession = '/workouts/:id/session';
  static const exerciseDetail = '/exercises/:id';
  static const trainingCard = '/training-card';

  // Program routes
  static const programs = '/programs';
  static const programDetail = '/programs/:id';
  static const activeProgram = '/programs/active';

  // Progress routes
  static const progress = '/progress';
  static const logProgress = '/progress/log';
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
  static const myPayments = '/profile/payments';
  // Payment flow (after subscribe)
  static const paymentInstruction = '/payments/instruction';
  static const uploadProof = '/payments/upload-proof';
  static const midtransPayment = '/payments/midtrans';
  static const paymentResult = '/payments/result';

  // Notification routes
  static const notifications = '/notifications';

  // Challenge routes
  static const challenges = '/challenges';
  static const challengeDetail = '/challenges/:id';
  static const challengeProgress = '/challenges/:id/progress';

  // Group routes
  static const groups = '/groups';
  static const groupDetail = '/groups/:id';

  // Announcement routes
  static const announcements = '/announcements';

  // Assessment routes (v1 — legacy, kept for backwards compat)
  static const assessmentIntro   = '/assessment/intro';
  static const assessmentFree    = '/assessment/free';
  static const assessmentPaid    = '/assessment/paid';
  static const assessmentResult  = '/assessment/result/:id';
  static const assessmentHistory = '/assessment/history';

  // SF Assessment v2 (Phase 5) — Phase A/B/C, Chronobiology, System Score 35/35/30.
  static const assessmentV2Intro     = '/assessment-v2/intro';
  static const assessmentV2PhaseA    = '/assessment-v2/phase-a';
  static const assessmentV2Waitlist  = '/assessment-v2/waitlist';
  static const assessmentV2Movement  = '/assessment-v2/movement-test';
  static const assessmentV2PhaseB    = '/assessment-v2/phase-b';
  static const assessmentV2PhaseC    = '/assessment-v2/phase-c';
  static const assessmentV2Result    = '/assessment-v2/result/:id';

  // Nutrition Guidance & Monitoring (paid only)
  static const nutritionGuidanceIntro    = '/nutrition-guidance';
  static const nutritionGuidanceProfile  = '/nutrition-guidance/profile';
  static const nutritionGuidancePlan     = '/nutrition-guidance/plan';
  static const nutritionGuidanceDailyLog = '/nutrition-guidance/daily-log';
  static const nutritionGuidanceHistory  = '/nutrition-guidance/history';
  static const nutritionGuidanceUpgrade  = '/nutrition-guidance/upgrade';

  // Habits
  static const habits = '/habits';

  // Digital Library
  static const digitalLibrary = '/digital-library';
  static const dlMovementDetail = '/digital-library/movement/:id';

  // Scheduling
  static const scheduling = '/scheduling';

  // Foods
  static const foods = '/foods';

  // Forms
  static const forms = '/forms';
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  // ── Auth state (set by SplashPage after async checks) ─────────────────
  static bool _authResolved = false;
  static bool _isLoggedIn = false;

  /// Called by SplashPage after determining login status.
  static void setAuthState({required bool isLoggedIn}) {
    _authResolved = true;
    _isLoggedIn = isLoggedIn;
  }

  /// Reset auth state (call on logout).
  static void clearAuthState() {
    _authResolved = false;
    _isLoggedIn = false;
  }

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    redirect: (context, state) {
      // Auth guard is handled by SplashPage._checkAuth() which navigates
      // after async checks. The redirect callback MUST be synchronous
      // (go_router v14+). We only guard against deep-linking into
      // protected routes when no auth session has been resolved yet.
      //
      // If the user is on the splash screen, let it handle everything.
      if (state.matchedLocation == AppRoutes.splash) return null;

      // Auth routes are always accessible
      final isAuthRoute = state.matchedLocation == AppRoutes.login
          || state.matchedLocation == AppRoutes.register
          || state.matchedLocation == AppRoutes.forgotPassword
          || state.matchedLocation == AppRoutes.guide
          || state.matchedLocation == AppRoutes.onboardingV2;

      if (isAuthRoute) return null;

      // For all other routes, the user must have gone through splash first.
      // If they somehow deep-link directly, send them to splash to resolve auth.
      if (!_authResolved) return AppRoutes.splash;

      // If auth resolved but user is not logged in, send to login.
      if (!_isLoggedIn) return AppRoutes.login;

      return null;
    },

    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Guide intro (legacy — kept for rollback safety, not referenced from splash)
      GoRoute(
        path: AppRoutes.guide,
        builder: (context, state) => const GuideIntroPage(),
      ),

      // SF Onboarding v2 (Phase 4)
      GoRoute(
        path: AppRoutes.onboardingV2,
        builder: (context, state) => const OnboardingV2Screen(),
      ),

      // SF Assessment v2 (Phase 5)
      GoRoute(
        path: AppRoutes.assessmentV2Intro,
        builder: (context, state) => const AssessmentV2IntroScreen(),
      ),
      GoRoute(
        path: AppRoutes.assessmentV2PhaseA,
        builder: (context, state) => const PhaseAScreen(),
      ),
      GoRoute(
        path: AppRoutes.assessmentV2Waitlist,
        builder: (context, state) => const PhaseAWaitlistScreen(),
      ),
      GoRoute(
        path: AppRoutes.assessmentV2Movement,
        builder: (context, state) => const PhaseAMovementTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.assessmentV2PhaseB,
        builder: (context, state) => const PhaseBScreen(),
      ),
      GoRoute(
        path: AppRoutes.assessmentV2PhaseC,
        builder: (context, state) => const PhaseCScreen(),
      ),
      GoRoute(
        path: AppRoutes.assessmentV2Result,
        builder: (context, state) => AssessmentV2ResultScreen(
          assessmentId: state.pathParameters['id']!,
        ),
      ),

      // Auth routes
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

      // Shell route — Bottom Navigation
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

      // Detail routes (full screen, above bottom nav)
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
        path: AppRoutes.trainingCard,
        builder: (context, state) => const TrainingCardScreen(),
      ),
      GoRoute(
        path: AppRoutes.programs,
        builder: (context, state) => const ProgramListPage(),
      ),
      GoRoute(
        path: AppRoutes.activeProgram,
        builder: (context, state) => const ActiveProgramPage(),
      ),
      GoRoute(
        path: AppRoutes.programDetail,
        builder: (context, state) => ProgramDetailPage(
          programId: state.pathParameters['id']!,
        ),
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
        path: AppRoutes.newConversation,
        builder: (context, state) => const NewConversationPage(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => ChatPage(
          conversationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionPage(),
      ),
      GoRoute(
        path: AppRoutes.myPayments,
        builder: (context, state) => const MyPaymentsPage(),
      ),
      GoRoute(
        path: AppRoutes.paymentInstruction,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentInstructionPage(
            payment: extra?['payment'] as ClientPaymentRecord?,
            bankAccount: extra?['bank_account'] as BankAccount?,
            planName: extra?['plan_name'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.uploadProof,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return UploadProofPage(
            paymentId: extra?['payment_id'] as String? ?? '',
            amount: extra?['amount'] as double?,
            currency: extra?['currency'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.midtransPayment,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MidtransPaymentPage(
            redirectUrl: extra?['redirect_url'] as String? ?? '',
            orderId: extra?['order_id'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentResult,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentResultPage(
            status: extra?['status'] as String? ?? 'pending',
            orderId: extra?['orderId'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),

      // Challenges
      GoRoute(
        path: AppRoutes.challenges,
        builder: (context, state) => const ChallengeListPage(),
      ),
      GoRoute(
        path: AppRoutes.challengeProgress,
        builder: (context, state) => ChallengeProgressPage(
          challengeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.challengeDetail,
        builder: (context, state) => ChallengeDetailPage(
          challengeId: state.pathParameters['id']!,
        ),
      ),

      // Groups
      GoRoute(
        path: AppRoutes.groups,
        builder: (context, state) => const GroupListPage(),
      ),
      GoRoute(
        path: AppRoutes.groupDetail,
        builder: (context, state) => GroupDetailPage(
          groupId: state.pathParameters['id']!,
        ),
      ),

      // Announcements
      GoRoute(
        path: AppRoutes.announcements,
        builder: (context, state) => const AnnouncementFeedPage(),
      ),

      // Assessment
      GoRoute(
        path: AppRoutes.assessmentIntro,
        builder: (context, state) => const AssessmentIntroPage(),
      ),
      GoRoute(
        path: AppRoutes.assessmentFree,
        builder: (context, state) => const FreeAssessmentPage(),
      ),
      GoRoute(
        path: AppRoutes.assessmentPaid,
        builder: (context, state) => const PaidAssessmentPage(),
      ),
      GoRoute(
        path: AppRoutes.assessmentResult,
        builder: (context, state) => AssessmentResultPage(
          assessmentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.assessmentHistory,
        builder: (context, state) => const AssessmentHistoryPage(),
      ),

      // Nutrition Guidance & Monitoring (paid only)
      GoRoute(
        path: AppRoutes.nutritionGuidanceIntro,
        builder: (context, state) => const NutritionGuidanceIntroPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionGuidanceProfile,
        builder: (context, state) => const HealthProfileFormPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionGuidancePlan,
        builder: (context, state) => const NutritionPlanPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionGuidanceDailyLog,
        builder: (context, state) => const DailyLogPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionGuidanceHistory,
        builder: (context, state) => const NutritionLogHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.nutritionGuidanceUpgrade,
        builder: (context, state) => const NutritionGuidanceUpgradePage(),
      ),

      // Habits
      GoRoute(
        path: AppRoutes.habits,
        builder: (context, state) => const HabitsPage(),
      ),

      // Digital Library
      GoRoute(
        path: AppRoutes.digitalLibrary,
        builder: (context, state) => const DigitalLibraryPage(),
      ),
      GoRoute(
        path: AppRoutes.dlMovementDetail,
        builder: (context, state) => DLMovementDetailPage(
          movementId: state.pathParameters['id']!,
        ),
      ),

      // Scheduling
      GoRoute(
        path: AppRoutes.scheduling,
        builder: (context, state) => const SchedulingPage(),
      ),

      // Foods
      GoRoute(
        path: AppRoutes.foods,
        builder: (context, state) => const FoodsPage(),
      ),

      // Forms
      GoRoute(
        path: AppRoutes.forms,
        builder: (context, state) => const FormsPage(),
      ),
    ],
  );
}
