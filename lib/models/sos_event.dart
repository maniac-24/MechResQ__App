import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for SOS Event
/// Tracks emergency activations for history and analytics
class SOSEvent {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final DateTime timestamp;
  final String location; // Address string
  final double latitude;
  final double longitude;
  final String status; // 'sent', 'responded', 'cancelled', 'resolved'
  final List<String> contactsNotified; // List of contact IDs
  final int mechanicsAlerted; // Number of mechanics alerted
  final String? respondedBy; // Mechanic ID who responded (if any)
  final String? notes; // Additional notes
  final bool isArchived; // True if user archived this event
  final String emergencyType; // Type: vehicle, medical, accident, safety, other

  SOSEvent({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.timestamp,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.status = 'sent',
    this.contactsNotified = const [],
    this.mechanicsAlerted = 0,
    this.respondedBy,
    this.notes,
    this.isArchived = false,
    this.emergencyType = 'vehicle',
  });

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'contactsNotified': contactsNotified,
      'mechanicsAlerted': mechanicsAlerted,
      'respondedBy': respondedBy,
      'notes': notes,
      'isArchived': isArchived,
      'emergencyType': emergencyType,
    };
  }

  // Create from Firestore Map
  factory SOSEvent.fromMap(Map<String, dynamic> map) {
    return SOSEvent(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'sent',
      contactsNotified: List<String>.from(map['contactsNotified'] ?? []),
      mechanicsAlerted: map['mechanicsAlerted'] ?? 0,
      respondedBy: map['respondedBy'],
      notes: map['notes'],
      isArchived: map['isArchived'] ?? false,
      emergencyType: map['emergencyType'] ?? 'vehicle',
    );
  }

  // Get emergency type display name
  String get emergencyTypeDisplay {
    switch (emergencyType) {
      case 'vehicle':
        return 'Vehicle Breakdown';
      case 'medical':
        return 'Medical Emergency';
      case 'accident':
        return 'Accident';
      case 'safety':
        return 'Personal Safety';
      case 'other':
        return 'Other';
      default:
        return 'Vehicle Breakdown';
    }
  }

  // Get emergency type emoji
  String get emergencyTypeEmoji {
    switch (emergencyType) {
      case 'vehicle':
        return '🚗';
      case 'medical':
        return '🚑';
      case 'accident':
        return '⚠️';
      case 'safety':
        return '🆘';
      case 'other':
        return '📋';
      default:
        return '🚗';
    }
  }

  // Get Google Maps link
  String get mapsLink => 'https://maps.google.com/?q=$latitude,$longitude';

  // Get status color helper
  String get statusEmoji {
    switch (status) {
      case 'sent':
        return '📤';
      case 'responded':
        return '✅';
      case 'cancelled':
        return '❌';
      case 'resolved':
        return '🎉';
      default:
        return '📋';
    }
  }
}
