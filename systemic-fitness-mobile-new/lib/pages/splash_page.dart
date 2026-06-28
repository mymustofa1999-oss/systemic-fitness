import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/ColorCategory.dart';
import 'package:workout/Constants.dart';
import 'package:workout/SizeConfig.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/fcm_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/models/user_model.dart';
import 'package:workout/router/app_router.dart';
import 'package:workout/util/sf_typography.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final isLoggedIn = await PrefData.isLoggedIn();
      final isIntro = await PrefData.getIsIntro();

      // First-time users → SF Onboarding v2 (Phase 4). Legacy /guide kept
      // in router for rollback only — no longer the splash destination.
      if (isIntro) {
        AppRouter.setAuthState(isLoggedIn: false);
        if (mounted) context.go(AppRoutes.onboardingV2);
        return;
      }

      if (isLoggedIn) {
        AppRouter.setAuthState(isLoggedIn: true);
        try {
          final response = await ApiService.getWithRetry(ApiConfig.me);
          final data = response['data'];
          if (data != null && data['user'] != null) {
            final user = UserModel.fromJson(data['user']);
            await PrefData.setUser(user.toJson());
          }
          FcmService.registerDeviceToken();
          if (!mounted) return;
          // Route the user through the Basic Assessment onboarding if
          // they haven't completed it yet (and haven't chosen to skip).
          final hasAssessment = await PrefData.hasCompletedAssessment();
          final skipped = await PrefData.getAssessmentSkipped();
          if (!hasAssessment && !skipped) {
            // SF Phase 5: arahkan ke Assessment v2 untuk user baru/retake.
            if (mounted) context.go(AppRoutes.assessmentV2Intro);
          } else {
            if (mounted) context.go(AppRoutes.dashboard);
          }
        } on ApiException catch (e) {
          if (e.statusCode == 401) {
            await PrefData.clearAll();
            AppRouter.setAuthState(isLoggedIn: false);
            if (mounted) context.go(AppRoutes.login);
          } else {
            if (mounted) context.go(AppRoutes.dashboard);
          }
        } catch (_) {
          if (mounted) context.go(AppRoutes.dashboard);
        }
      } else {
        AppRouter.setAuthState(isLoggedIn: false);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) context.go(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('[SplashPage] _checkAuth FAILED: $e');
      AppRouter.setAuthState(isLoggedIn: false);
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final logoSize = MediaQuery.of(context).size.shortestSide * 0.18;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kSfDeepNavy,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: kSfDeepNavy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kSfDeepNavy,
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  Constants.assetsImagePath + "splash_icon.png",
                  height: logoSize,
                ),
                const SizedBox(height: 18),
                Text(
                  'Systemic Fitness',
                  textAlign: TextAlign.center,
                  style: SfTypography.headline(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Human System Optimization',
                  textAlign: TextAlign.center,
                  style: SfTypography.label(
                    fontSize: 11,
                    color: kSfWarmGold,
                    letterSpacing: 1.6,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        kSfWarmGold.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
