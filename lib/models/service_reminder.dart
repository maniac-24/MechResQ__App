import 'package:cloud_firestore/cloud_firestore.dart';

/// Service Reminder Model
/// Represents a scheduled reminder for vehicle maintenance/service
class ServiceReminder {
  final String id;
  final String userId;
  final String vehicleId;
  final String vehicleName; // Cached for display
  final String title;
  final String? description;
  final DateTime reminderDate;
  final String reminderType; // Oil Change, Tire Rotation, General Service, etc.
  final int? mileage; // Optional: remind at specific mileage
  final bool isCompleted;
  final bool isNotificationSent;
  final DateTime createdAt;
  final DateTime? completedAt;

  ServiceReminder({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.vehicleName,
    required this.title,
    this.description,
    required this.reminderDate,
    required this.reminderType,
    this.mileage,
    this.isCompleted = false,
    this.isNotificationSent = false,
    required this.createdAt,
    this.completedAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'title': title,
      'description': description,
      'reminderDate': Timestamp.fromDate(reminderDate),
      'reminderType': reminderType,
      'mileage': mileage,
      'isCompleted': isCompleted,
      'isNotificationSent': isNotificationSent,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  // Create from Firestore Map
  factory ServiceReminder.fromMap(Map<String, dynamic> map) {
    return ServiceReminder(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      vehicleName: map['vehicleName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      reminderDate: (map['reminderDate'] as Timestamp).toDate(),
      reminderType: map['reminderType'] ?? 'General Service',
      mileage: map['mileage'],
      isCompleted: map['isCompleted'] ?? false,
      isNotificationSent: map['isNotificationSent'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Helper: Is reminder due (past or today)
  bool get isDue {
    final now = DateTime.now();
    return reminderDate.isBefore(now) || 
           reminderDate.year == now.year && 
           reminderDate.month == now.month && 
           reminderDate.day == now.day;
  }

  // Helper: Days until reminder
  int get daysUntil {
    final now = DateTime.now();
    final difference = reminderDate.difference(now);
    return difference.inDays;
  }

  // Helper: Reminder type icon
  String get typeIcon {
    switch (reminderType.toLowerCase()) {
      case 'oil change':
        return '🛢️';
      case 'tire rotation':
      case 'tire check':
        return '🛞';
      case 'battery check':
        return '🔋';
      case 'brake service':
        return '🛑';
      case 'general service':
        return '🔧';
      case 'insurance renewal':
        return '📄';
      case 'pollution check':
        return '💨';
      default:
        return '🔔';
    }
  }

  // Copy with method
  ServiceReminder copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    String? vehicleName,
    String? title,
    String? description,
    DateTime? reminderDate,
    String? reminderType,
    int? mileage,
    bool? isCompleted,
    bool? isNotificationSent,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ServiceReminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderType: reminderType ?? this.reminderType,
      mileage: mileage ?? this.mileage,
      isCompleted: isCompleted ?? this.isCompleted,
      isNotificationSent: isNotificationSent ?? this.isNotificationSent,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Predefined reminder types
  static const List<String> reminderTypes = [
    'General Service',
    'Oil Change',
    'Tire Rotation',
    'Tire Check',
    'Battery Check',
    'Brake Service',
    'Insurance Renewal',
    'Pollution Check',
    'Engine Check',
    'AC Service',
    'Wheel Alignment',
    'Custom',
  ];
}
