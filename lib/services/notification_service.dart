import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

import '../utils/notification_navigation_helper.dart';

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
    
    // Navigate to appropriate screen based on payload
    NotificationNavigationHelper.handleNotificationNavigation(response.payload);
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
    
    // Extract data from Firebase message and create payload string
    final data = message.data;
    if (data.isNotEmpty) {
      // Convert data map to payload string format
      final payload = data.entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      
      print('📲 Navigation payload: $payload');
      NotificationNavigationHelper.handleNotificationNavigation(payload);
    } else {
      print('⚠️ No data in notification message');
    }
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

  // ═══════════════════════════════════════════
  // CONVENIENCE METHODS FOR SPECIFIC NOTIFICATIONS
  // ═══════════════════════════════════════════

  /// Notification when request is updated
  Future<void> showRequestUpdateNotification({
    required String requestId,
    required String title,
    required String body,
  }) async {
    await showInstantNotification(
      title: title,
      body: body,
      payload: 'type:request_update,requestId:$requestId',
    );
  }

  /// Notification when mechanic is assigned
  Future<void> showMechanicAssignedNotification({
    required String requestId,
    required String mechanicName,
  }) async {
    await showInstantNotification(
      title: 'Mechanic Assigned',
      body: '$mechanicName has been assigned to your request',
      payload: 'type:request_assigned,requestId:$requestId',
    );
  }

  /// Notification when mechanic arrives
  Future<void> showMechanicArrivedNotification({
    required String requestId,
    required String mechanicName,
  }) async {
    await showInstantNotification(
      title: 'Mechanic Arrived',
      body: '$mechanicName has arrived at your location',
      payload: 'type:mechanic_arrived,requestId:$requestId',
    );
  }

  /// Notification when request is completed
  Future<void> showRequestCompletedNotification({
    required String requestId,
  }) async {
    await showInstantNotification(
      title: 'Service Completed',
      body: 'Your service request has been completed',
      payload: 'type:request_completed,requestId:$requestId',
    );
  }

  /// Notification for new chat message
  Future<void> showNewMessageNotification({
    required String requestId,
    required String mechanicId,
    required String mechanicName,
    required String message,
  }) async {
    await showInstantNotification(
      title: 'New message from $mechanicName',
      body: message,
      payload: 'type:new_message,requestId:$requestId,mechanicId:$mechanicId,mechanicName:$mechanicName',
    );
  }

  /// Notification for SOS alert
  Future<void> showSOSAlertNotification() async {
    await showInstantNotification(
      title: 'SOS Alert Sent',
      body: 'Your emergency contacts have been notified',
      payload: 'type:sos_alert',
    );
  }

  /// Notification for service reminder
  Future<void> showServiceReminderNotification({
    required String vehicleName,
    required String serviceType,
  }) async {
    await showInstantNotification(
      title: 'Service Reminder',
      body: '$serviceType due for $vehicleName',
      payload: 'type:service_reminder',
    );
  }

  /// Notification to request review
  Future<void> showReviewRequestNotification({
    required String requestId,
    required String mechanicId,
    required String mechanicName,
  }) async {
    await showInstantNotification(
      title: 'Rate Your Experience',
      body: 'How was your service with $mechanicName?',
      payload: 'type:review_request,requestId:$requestId,mechanicId:$mechanicId,mechanicName:$mechanicName',
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
