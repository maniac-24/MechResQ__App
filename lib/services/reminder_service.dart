import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_reminder.dart';
import 'notification_service.dart';

/// Reminder Service
/// Manages service reminders in Firestore and schedules notifications
class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // ═══════════════════════════════════════════
  // CREATE REMINDER
  // ═══════════════════════════════════════════

  Future<String?> createReminder({
    required String userId,
    required String vehicleId,
    required String vehicleName,
    required String title,
    String? description,
    required DateTime reminderDate,
    required String reminderType,
    int? mileage,
  }) async {
    try {
      final reminderId = _firestore.collection('reminders').doc().id;

      final reminder = ServiceReminder(
        id: reminderId,
        userId: userId,
        vehicleId: vehicleId,
        vehicleName: vehicleName,
        title: title,
        description: description,
        reminderDate: reminderDate,
        reminderType: reminderType,
        mileage: mileage,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(reminderId)
          .set(reminder.toMap());

      // Schedule notification (1 day before reminder date at 9 AM)
      await _scheduleReminderNotification(reminder);

      print('✅ Reminder created: $reminderId');
      return reminderId;
    } catch (e) {
      print('❌ Error creating reminder: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════
  // UPDATE REMINDER
  // ═══════════════════════════════════════════

  Future<bool> updateReminder({
    required String userId,
    required String reminderId,
    String? title,
    String? description,
    DateTime? reminderDate,
    String? reminderType,
    int? mileage,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (reminderDate != null) {
        updates['reminderDate'] = Timestamp.fromDate(reminderDate);
        // Reschedule notification
        final reminder = await getReminder(userId, reminderId);
        if (reminder != null) {
          final updatedReminder = reminder.copyWith(reminderDate: reminderDate);
          await _cancelReminderNotification(reminder.id);
          await _scheduleReminderNotification(updatedReminder);
        }
      }
      if (reminderType != null) updates['reminderType'] = reminderType;
      if (mileage != null) updates['mileage'] = mileage;

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('reminders')
            .doc(reminderId)
            .update(updates);
      }

      print('✅ Reminder updated: $reminderId');
      return true;
    } catch (e) {
      print('❌ Error updating reminder: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // DELETE REMINDER
  // ═══════════════════════════════════════════

  Future<bool> deleteReminder(String userId, String reminderId) async {
    try {
      // Cancel scheduled notification
      await _cancelReminderNotification(reminderId);

      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(reminderId)
          .delete();

      print('✅ Reminder deleted: $reminderId');
      return true;
    } catch (e) {
      print('❌ Error deleting reminder: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // MARK REMINDER AS COMPLETED
  // ═══════════════════════════════════════════

  Future<bool> markAsCompleted(String userId, String reminderId) async {
    try {
      // Cancel notification
      await _cancelReminderNotification(reminderId);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(reminderId)
          .update({
        'isCompleted': true,
        'completedAt': Timestamp.now(),
      });

      print('✅ Reminder marked as completed: $reminderId');
      return true;
    } catch (e) {
      print('❌ Error marking reminder as completed: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // GET REMINDERS
  // ═══════════════════════════════════════════

  /// Get all reminders for user
  Future<List<ServiceReminder>> getReminders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .where('isCompleted', isEqualTo: false)
          .orderBy('reminderDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => ServiceReminder.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error getting reminders: $e');
      return [];
    }
  }

  /// Get reminders as stream (real-time)
  Stream<List<ServiceReminder>> getRemindersStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .where('isCompleted', isEqualTo: false)
        .orderBy('reminderDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceReminder.fromMap(doc.data()))
            .toList());
  }

  /// Get completed reminders
  Stream<List<ServiceReminder>> getCompletedRemindersStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .where('isCompleted', isEqualTo: true)
        .orderBy('completedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceReminder.fromMap(doc.data()))
            .toList());
  }

  /// Get single reminder
  Future<ServiceReminder?> getReminder(String userId, String reminderId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(reminderId)
          .get();

      if (doc.exists) {
        return ServiceReminder.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting reminder: $e');
      return null;
    }
  }

  /// Get reminders for specific vehicle
  Stream<List<ServiceReminder>> getVehicleRemindersStream(
    String userId,
    String vehicleId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .where('vehicleId', isEqualTo: vehicleId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('reminderDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceReminder.fromMap(doc.data()))
            .toList());
  }

  /// Get due reminders count
  Future<int> getDueRemindersCount(String userId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .where('isCompleted', isEqualTo: false)
          .where('reminderDate', isLessThanOrEqualTo: Timestamp.now())
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting due reminders count: $e');
      return 0;
    }
  }

  // ═══════════════════════════════════════════
  // NOTIFICATION SCHEDULING
  // ═══════════════════════════════════════════

  /// Schedule notification for reminder (1 day before at 9 AM)
  Future<void> _scheduleReminderNotification(ServiceReminder reminder) async {
    try {
      // Schedule 1 day before at 9 AM
      final notificationDate = DateTime(
        reminder.reminderDate.year,
        reminder.reminderDate.month,
        reminder.reminderDate.day - 1,
        9, // 9 AM
        0,
      );

      // Only schedule if notification date is in the future
      if (notificationDate.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: reminder.id.hashCode,
          title: '${reminder.typeIcon} ${reminder.title}',
          body: 'Tomorrow: ${reminder.vehicleName}',
          scheduledDate: notificationDate,
          payload: 'reminder:${reminder.id}',
        );
      }
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Cancel notification for reminder
  Future<void> _cancelReminderNotification(String reminderId) async {
    try {
      await _notificationService.cancelNotification(reminderId.hashCode);
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Sync all reminders (reschedule notifications if needed)
  Future<void> syncReminders(String userId) async {
    try {
      final reminders = await getReminders(userId);
      
      for (var reminder in reminders) {
        await _scheduleReminderNotification(reminder);
      }
      
      print('✅ Reminders synced: ${reminders.length}');
    } catch (e) {
      print('❌ Error syncing reminders: $e');
    }
  }
}
