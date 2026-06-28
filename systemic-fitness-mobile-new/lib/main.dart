
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:workout/Constants.dart';
import 'package:workout/data/fcm_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/router/app_router.dart';

import 'ColorCategory.dart';
import 'generated/l10n.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const MethodChannel platform = MethodChannel('dexterx.dev/workout');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // ── Global error handlers so uncaught exceptions don't blank the screen ──
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[FLUTTER_ERROR] ${details.exceptionAsString()}');
    debugPrint('[FLUTTER_ERROR] ${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[PLATFORM_ERROR] $error');
    debugPrint('[PLATFORM_ERROR] $stack');
    return true;
  };

  // ── Initialize locale ────────────────────────────────────────────────────
  try {
    await PrefData.getLocale();
    debugPrint('[INIT] Locale loaded OK');
  } catch (e) {
    debugPrint('[INIT] Locale load FAILED: $e');
  }

  // ── Initialize Firebase ──────────────────────────────────────────────────
  try {
    await Firebase.initializeApp();
    debugPrint('[INIT] Firebase initialized OK');
  } catch (e, s) {
    debugPrint('[INIT] Firebase init FAILED: $e');
    debugPrint('[INIT] $s');
  }

  // Register background message handler (safe even if Firebase failed)
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('[INIT] Background message handler registration failed: $e');
  }

  // ── Initialize AdMob ─────────────────────────────────────────────────────
  try {
    MobileAds.instance.initialize();
    debugPrint('[INIT] AdMob initialized OK');
  } catch (e) {
    debugPrint('[INIT] AdMob init FAILED: $e');
  }

  // ── Initialize timezone ──────────────────────────────────────────────────
  try {
    await _configureLocalTimeZone();
    debugPrint('[INIT] Timezone configured OK');
  } catch (e) {
    debugPrint('[INIT] Timezone config FAILED: $e');
  }

  // ── Initialize FCM + local notifications ─────────────────────────────────
  try {
    await FcmService.initialize();
    debugPrint('[INIT] FCM initialized OK');
  } catch (e) {
    debugPrint('[INIT] FCM init FAILED: $e');
  }

  // ── Subscribe to general topics for promos ───────────────────────────────
  try {
    await FcmService.subscribeToTopic('all_users');
    await FcmService.subscribeToTopic('promotions');
  } catch (e) {
    debugPrint('[INIT] Topic subscription FAILED: $e');
  }

  debugPrint('[INIT] All init steps completed — launching app');

  runApp(
    BetterFeedback(
      child: const MyApp(),
    ),
  );
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  try {
    final String? timeZoneName =
        await platform.invokeMethod<String>('getTimeZoneName');
    tz.Location getLocal =
        tz.getLocation(timeZoneName!.replaceAll("Calcutta", "Kolkata"));
    tz.setLocalLocation(getLocal);
  } catch (e) {
    debugPrint('[INIT] Timezone MethodChannel/lookup failed: $e');
    tz.Location getLocal = tz.getLocation(Constants.defTimeZoneName);
    tz.setLocalLocation(getLocal);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: PrefData.localeNotifier,
      builder: (context, localeStr, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          locale: Locale(localeStr),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          title: 'Systemic Fitness',
          theme: ThemeData(
            fontFamily: Constants.fontsFamily,
            primaryColor: primaryColor,
            primaryColorDark: primaryColor,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: accentColor,
              surface: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
