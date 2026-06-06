import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

/// Notification Service
/// Handles local notifications and Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;

  // ═══════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════

  /// Initialize notification service WITHOUT requesting permissions
  /// Permissions should be requested later with better UX
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Initialize local notifications (without requesting permissions yet)
      await _initializeLocalNotifications();

      // Initialize Firebase Messaging (without requesting permissions yet)
      await _initializeFirebaseMessagingWithoutPermission();

      _isInitialized = true;
      print('✅ NotificationService initialized successfully (permissions not requested yet)');
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
    }
  }

  /// Request notification permissions (call this from home screen with custom dialog)
  Future<bool> requestPermissions() async {
    try {
      final granted = await _requestPermissions();
      
      if (granted) {
        // After permissions granted, get FCM token and setup listeners
        await _setupFirebaseMessagingListeners();
        print('✅ Notification permissions granted');
      }
      
      return granted;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // PERMISSIONS
  // ═══════════════════════════════════════════

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ requires runtime permission
      final plugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      final granted = await plugin?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      // iOS permissions
      final granted = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return granted.authorizationStatus == AuthorizationStatus.authorized;
    }
    return true;
  }

  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final plugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await plugin?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return true;
  }

  // ═══════════════════════════════════════════
  // LOCAL NOTIFICATIONS SETUP
  // ═══════════════════════════════════════════

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('📲 Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
  }

  // ═══════════════════════════════════════════
  // FIREBASE MESSAGING SETUP
  // ═══════════════════════════════════════════

  /// Initialize Firebase Messaging without requesting permissions
  Future<void> _initializeFirebaseMessagingWithoutPermission() async {
    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    
    print('✅ Firebase Messaging initialized (listeners will be setup after permission)');
  }

  /// Setup Firebase Messaging listeners after permissions are granted
  Future<void> _setupFirebaseMessagingListeners() async {
    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('🔑 FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Foreground message: ${message.notification?.title}');
    
    // Show local notification when app is in foreground
    if (message.notification != null) {
      showInstantNotification(
        title: message.notification!.title ?? 'MechResQ',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationOpen(RemoteMessage message) {
    print('📲 Notification opened: ${message.notification?.title}');
    // TODO: Navigate based on message data
  }

  // ═══════════════════════════════════════════
  // SHOW NOTIFICATIONS
  // ═══════════════════════════════════════════

  /// Show instant notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mechresq_instant',
      'Instant Notifications',
      channelDescription: 'Immediate notifications for urgent updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule notification for specific date/time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mechresq_reminders',
      'Service Reminders',
      channelDescription: 'Scheduled reminders for vehicle service',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    print('⏰ Notification scheduled for $scheduledDate');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    print('🚫 Notification $id cancelled');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('🚫 All notifications cancelled');
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // ═══════════════════════════════════════════
  // FCM TOKEN
  // ═══════════════════════════════════════════

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Listen to token refresh
  Stream<String> onTokenRefresh() {
    return _firebaseMessaging.onTokenRefresh;
  }
}

// ═══════════════════════════════════════════
// BACKGROUND MESSAGE HANDLER (Top-level function)
// ═══════════════════════════════════════════

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message: ${message.notification?.title}');
  // Handle background notification
}
