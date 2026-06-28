import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workout/data/api_config.dart';
import 'package:workout/data/api_service.dart';
import 'package:workout/data/pref_data.dart';
import 'package:workout/router/app_router.dart';

/// Background message handler — must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages silently
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize FCM + local notifications
  static Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Initialize local notifications for foreground display
    const androidSettings = AndroidInitializationSettings('logo');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'systemic_fitness_channel',
      'Systemic Fitness',
      description: 'Notifications for workouts, reminders, and messages',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Get and save FCM token
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await PrefData.setFcmToken(token);
      }
    } catch (e) {
      print('Error getting FCM token (Firebase may not be available): $e');
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      await PrefData.setFcmToken(newToken);
      // Re-register with server if logged in
      await registerDeviceToken();
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Check if app was opened from a terminated-state notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationOpen(initialMessage);
      });
    }

    // Set foreground notification presentation options (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ─── Device Token Registration (API Integration) ──────────

  /// Register FCM device token with the server
  /// Call this after login and on token refresh
  static Future<void> registerDeviceToken() async {
    final isLoggedIn = await PrefData.isLoggedIn();
    if (!isLoggedIn) return;

    final token = await PrefData.getFcmToken();
    if (token == null || token.isEmpty) return;

    final platform = Platform.isAndroid ? 'android' : 'ios';

    try {
      await ApiService.postWithRetry(ApiConfig.deviceToken, body: {
        'token': token,
        'platform': platform,
        'device_name': await _getDeviceName(),
      });
    } catch (_) {
      // Silently fail — token registration is best-effort
    }
  }

  /// Unregister FCM device token from server (call on logout)
  static Future<void> unregisterDeviceToken() async {
    final token = await PrefData.getFcmToken();
    if (token == null || token.isEmpty) return;

    try {
      await ApiService.delete(ApiConfig.deviceToken);
    } catch (_) {
      // Silently fail
    }
  }

  /// Get device name for registration
  static Future<String> _getDeviceName() async {
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isIOS) return 'iOS Device';
    return 'Unknown Device';
  }

  // ─── Notification Center API Helpers ───────────────────────

  /// Fetch unread notification count from server
  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiService.getWithRetry(ApiConfig.unreadCount);
      return response['data']?['unread_count'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ─── Foreground Message Handling ───────────────────────────

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'systemic_fitness_channel',
          'Systemic Fitness',
          channelDescription: 'Notifications for workouts, reminders, and messages',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'logo',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // ─── Notification Tap Handlers ─────────────────────────────

  static void _handleNotificationOpen(RemoteMessage message) {
    _navigateFromPayload(message.data);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromPayload(data);
    } catch (_) {}
  }

  /// Deep link navigation based on notification payload
  static void _navigateFromPayload(Map<String, dynamic> payload) {
    final type = payload['type'] as String?;
    final targetId = payload['target_id'] as String?;

    switch (type) {
      case 'workout_reminder':
        if (targetId != null) {
          AppRouter.router.go('/workouts/$targetId/session');
        } else {
          AppRouter.router.go(AppRoutes.dashboard);
        }
        break;
      case 'program_reminder':
        AppRouter.router.go(AppRoutes.activeProgram);
        break;
      case 'subscription_expiring':
      case 'payment_due':
        AppRouter.router.go(AppRoutes.subscription);
        break;
      case 'new_message':
        if (targetId != null) {
          AppRouter.router.go('/messages/$targetId');
        } else {
          AppRouter.router.go(AppRoutes.messages);
        }
        break;
      case 'milestone':
      case 'on_program_complete':
        AppRouter.router.go(AppRoutes.progress);
        break;
      case 'body_metric_reminder':
        AppRouter.router.go(AppRoutes.logBodyMetric);
        break;
      case 'nutrition_reminder':
        AppRouter.router.go(AppRoutes.logNutrition);
        break;
      case 'promo':
      case 'announcement':
        AppRouter.router.go(AppRoutes.notifications);
        break;
      case 'maintenance':
        AppRouter.router.go(AppRoutes.notifications);
        break;
      default:
        AppRouter.router.go(AppRoutes.dashboard);
    }
  }

  // ─── Topic Management ──────────────────────────────────────

  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }
}
