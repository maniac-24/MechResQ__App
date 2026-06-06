import 'package:cloud_firestore/cloud_firestore.dart';

/// Request Tracking Status
enum RequestStatus {
  pending,
  accepted,
  mechanicEnRoute,
  mechanicNearby,
  mechanicArrived,
  workInProgress,
  completed,
  cancelled,
}

/// Request Tracking Model
/// Tracks real-time status and location updates for mechanic requests
class RequestTracking {
  final String requestId;
  final String userId;
  final String? mechanicId;
  final RequestStatus status;
  
  // User location
  final double userLatitude;
  final double userLongitude;
  final String? userAddress;
  
  // Mechanic location (if available)
  final double? mechanicLatitude;
  final double? mechanicLongitude;
  
  // Tracking info
  final double? distanceInMeters;
  final int? etaInMinutes;
  final DateTime? estimatedArrivalTime;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  
  // Additional info
  final String? mechanicName;
  final String? mechanicPhone;
  final String? mechanicVehicleNumber;
  final Map<String, dynamic>? additionalData;

  RequestTracking({
    required this.requestId,
    required this.userId,
    this.mechanicId,
    required this.status,
    required this.userLatitude,
    required this.userLongitude,
    this.userAddress,
    this.mechanicLatitude,
    this.mechanicLongitude,
    this.distanceInMeters,
    this.etaInMinutes,
    this.estimatedArrivalTime,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.completedAt,
    this.mechanicName,
    this.mechanicPhone,
    this.mechanicVehicleNumber,
    this.additionalData,
  });

  // ═══════════════════════════════════════════
  // FACTORIES
  // ═══════════════════════════════════════════

  factory RequestTracking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return RequestTracking(
      requestId: doc.id,
      userId: data['userId'] ?? '',
      mechanicId: data['mechanicId'],
      status: _statusFromString(data['status'] ?? 'pending'),
      userLatitude: (data['userLatitude'] ?? 0.0).toDouble(),
      userLongitude: (data['userLongitude'] ?? 0.0).toDouble(),
      userAddress: data['userAddress'],
      mechanicLatitude: data['mechanicLatitude']?.toDouble(),
      mechanicLongitude: data['mechanicLongitude']?.toDouble(),
      distanceInMeters: data['distanceInMeters']?.toDouble(),
      etaInMinutes: data['etaInMinutes'],
      estimatedArrivalTime: data['estimatedArrivalTime'] != null
          ? (data['estimatedArrivalTime'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      arrivedAt: data['arrivedAt'] != null
          ? (data['arrivedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      mechanicName: data['mechanicName'],
      mechanicPhone: data['mechanicPhone'],
      mechanicVehicleNumber: data['mechanicVehicleNumber'],
      additionalData: data['additionalData'],
    );
  }

  factory RequestTracking.fromMap(Map<String, dynamic> data, String id) {
    return RequestTracking(
      requestId: id,
      userId: data['userId'] ?? '',
      mechanicId: data['mechanicId'],
      status: _statusFromString(data['status'] ?? 'pending'),
      userLatitude: (data['userLatitude'] ?? 0.0).toDouble(),
      userLongitude: (data['userLongitude'] ?? 0.0).toDouble(),
      userAddress: data['userAddress'],
      mechanicLatitude: data['mechanicLatitude']?.toDouble(),
      mechanicLongitude: data['mechanicLongitude']?.toDouble(),
      distanceInMeters: data['distanceInMeters']?.toDouble(),
      etaInMinutes: data['etaInMinutes'],
      estimatedArrivalTime: data['estimatedArrivalTime'] != null
          ? (data['estimatedArrivalTime'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      arrivedAt: data['arrivedAt'] != null
          ? (data['arrivedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      mechanicName: data['mechanicName'],
      mechanicPhone: data['mechanicPhone'],
      mechanicVehicleNumber: data['mechanicVehicleNumber'],
      additionalData: data['additionalData'],
    );
  }

  // ═══════════════════════════════════════════
  // TO MAP
  // ═══════════════════════════════════════════

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mechanicId': mechanicId,
      'status': _statusToString(status),
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'userAddress': userAddress,
      'mechanicLatitude': mechanicLatitude,
      'mechanicLongitude': mechanicLongitude,
      'distanceInMeters': distanceInMeters,
      'etaInMinutes': etaInMinutes,
      'estimatedArrivalTime': estimatedArrivalTime != null
          ? Timestamp.fromDate(estimatedArrivalTime!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'arrivedAt': arrivedAt != null ? Timestamp.fromDate(arrivedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'mechanicName': mechanicName,
      'mechanicPhone': mechanicPhone,
      'mechanicVehicleNumber': mechanicVehicleNumber,
      'additionalData': additionalData,
    };
  }

  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════

  static RequestStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'mechanicenroute':
      case 'mechanic_enroute':
        return RequestStatus.mechanicEnRoute;
      case 'mechanicnearby':
      case 'mechanic_nearby':
        return RequestStatus.mechanicNearby;
      case 'mechanicarrived':
      case 'mechanic_arrived':
        return RequestStatus.mechanicArrived;
      case 'workinprogress':
      case 'work_in_progress':
        return RequestStatus.workInProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }

  static String _statusToString(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.mechanicEnRoute:
        return 'mechanicEnRoute';
      case RequestStatus.mechanicNearby:
        return 'mechanicNearby';
      case RequestStatus.mechanicArrived:
        return 'mechanicArrived';
      case RequestStatus.workInProgress:
        return 'workInProgress';
      case RequestStatus.completed:
        return 'completed';
      case RequestStatus.cancelled:
        return 'cancelled';
    }
  }

  // ═══════════════════════════════════════════
  // DISPLAY HELPERS
  // ═══════════════════════════════════════════

  String get statusDisplay {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.mechanicEnRoute:
        return 'Mechanic En Route';
      case RequestStatus.mechanicNearby:
        return 'Mechanic Nearby';
      case RequestStatus.mechanicArrived:
        return 'Mechanic Arrived';
      case RequestStatus.workInProgress:
        return 'Work In Progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get distanceDisplay {
    if (distanceInMeters == null) return 'N/A';
    
    if (distanceInMeters! < 1000) {
      return '${distanceInMeters!.toInt()} m';
    } else {
      final km = distanceInMeters! / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  String get etaDisplay {
    if (etaInMinutes == null) return 'N/A';
    
    if (etaInMinutes! < 60) {
      return '$etaInMinutes min';
    } else {
      final hours = etaInMinutes! ~/ 60;
      final mins = etaInMinutes! % 60;
      return '${hours}h ${mins}m';
    }
  }

  bool get isMechanicAssigned => mechanicId != null && mechanicId!.isNotEmpty;
  
  bool get isActive => 
      status != RequestStatus.completed && 
      status != RequestStatus.cancelled;

  bool get canTrack => 
      isMechanicAssigned && 
      mechanicLatitude != null && 
      mechanicLongitude != null;

  // ═══════════════════════════════════════════
  // COPY WITH
  // ═══════════════════════════════════════════

  RequestTracking copyWith({
    String? mechanicId,
    RequestStatus? status,
    double? mechanicLatitude,
    double? mechanicLongitude,
    double? distanceInMeters,
    int? etaInMinutes,
    DateTime? estimatedArrivalTime,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? completedAt,
    String? mechanicName,
    String? mechanicPhone,
    String? mechanicVehicleNumber,
  }) {
    return RequestTracking(
      requestId: requestId,
      userId: userId,
      mechanicId: mechanicId ?? this.mechanicId,
      status: status ?? this.status,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      userAddress: userAddress,
      mechanicLatitude: mechanicLatitude ?? this.mechanicLatitude,
      mechanicLongitude: mechanicLongitude ?? this.mechanicLongitude,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      etaInMinutes: etaInMinutes ?? this.etaInMinutes,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      completedAt: completedAt ?? this.completedAt,
      mechanicName: mechanicName ?? this.mechanicName,
      mechanicPhone: mechanicPhone ?? this.mechanicPhone,
      mechanicVehicleNumber: mechanicVehicleNumber ?? this.mechanicVehicleNumber,
      additionalData: additionalData,
    );
  }
}
