import 'package:flutter/material.dart';

/// Helper class for handling notification navigation
class NotificationNavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate based on notification payload
  static void handleNotificationNavigation(String? payload) {
    if (payload == null || payload.isEmpty) return;

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('❌ Navigation context not available');
      return;
    }

    try {
      // Parse payload as key-value pairs
      final data = _parsePayload(payload);
      final type = data['type'];
      
      print('🧭 Navigating based on notification type: $type');

      switch (type) {
        case 'request_update':
          _navigateToRequestTracking(context, data);
          break;
        
        case 'request_assigned':
          _navigateToRequestTracking(context, data);
          break;
        
        case 'mechanic_arrived':
          _navigateToRequestTracking(context, data);
          break;
        
        case 'request_completed':
          _navigateToRequestDetail(context, data);
          break;
        
        case 'new_message':
          _navigateToChatScreen(context, data);
          break;
        
        case 'sos_alert':
          _navigateToSOSHistory(context);
          break;
        
        case 'service_reminder':
          _navigateToServiceReminders(context);
          break;
        
        case 'review_request':
          _navigateToSubmitReview(context, data);
          break;
        
        default:
          print('⚠️ Unknown notification type: $type');
          _navigateToHome(context);
      }
    } catch (e) {
      print('❌ Error handling notification navigation: $e');
      _navigateToHome(context);
    }
  }

  /// Parse payload string into key-value map
  static Map<String, String> _parsePayload(String payload) {
    final result = <String, String>{};
    
    // Remove curly braces if present
    payload = payload.replaceAll('{', '').replaceAll('}', '');
    
    // Split by comma and parse key-value pairs
    final pairs = payload.split(',');
    for (final pair in pairs) {
      final keyValue = pair.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim();
        final value = keyValue[1].trim();
        result[key] = value;
      }
    }
    
    return result;
  }

  // ═══════════════════════════════════════════
  // NAVIGATION METHODS
  // ═══════════════════════════════════════════

  static void _navigateToRequestTracking(BuildContext context, Map<String, String> data) {
    final requestId = data['requestId'];
    if (requestId == null || requestId.isEmpty) {
      _navigateToMyRequests(context);
      return;
    }

    // Import the screen dynamically to avoid circular dependencies
    Navigator.pushNamed(
      context,
      '/track_mechanic',
      arguments: requestId,
    );
  }

  static void _navigateToRequestDetail(BuildContext context, Map<String, String> data) {
    final requestId = data['requestId'];
    if (requestId == null || requestId.isEmpty) {
      _navigateToMyRequests(context);
      return;
    }

    Navigator.pushNamed(
      context,
      '/request_detail',
      arguments: requestId,
    );
  }

  static void _navigateToChatScreen(BuildContext context, Map<String, String> data) {
    final mechanicName = data['mechanicName'] ?? 'Mechanic';

    Navigator.pushNamed(
      context,
      '/chat_mechanic',
      arguments: {
        'mechanicName': mechanicName,
      },
    );
  }

  static void _navigateToSOSHistory(BuildContext context) {
    Navigator.pushNamed(context, '/sos_history');
  }

  static void _navigateToServiceReminders(BuildContext context) {
    Navigator.pushNamed(context, '/service_reminders');
  }

  static void _navigateToSubmitReview(BuildContext context, Map<String, String> data) {
    final requestId = data['requestId'];
    final mechanicId = data['mechanicId'];
    final mechanicName = data['mechanicName'] ?? 'Mechanic';

    if (requestId == null || mechanicId == null) {
      _navigateToMyRequests(context);
      return;
    }

    Navigator.pushNamed(
      context,
      '/submit_review',
      arguments: {
        'requestId': requestId,
        'mechanicId': mechanicId,
        'mechanicName': mechanicName,
      },
    );
  }

  static void _navigateToMyRequests(BuildContext context) {
    Navigator.pushNamed(context, '/my_requests');
  }

  static void _navigateToHome(BuildContext context) {
    // Navigate to home and clear stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }
}
