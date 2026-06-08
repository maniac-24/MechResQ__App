import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

/// Service for tracking mechanic location via requestTracking collection
/// This is an alternative to MechanicLocationService for cases where
/// location is stored in the requestTracking document itself
class RequestTrackingLocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream mechanic's location from requestTracking collection
  /// This works with your current Firestore structure
  /// 
  /// Expected structure in requestTracking/{requestId}:
  ///   - mechanicLatitude: double
  ///   - mechanicLongitude: double
  ///   - userLatitude: double
  ///   - userLongitude: double
  ///   - mechanicId: string
  ///   - mechanicName: string
  ///   - status: string
  ///   - updatedAt: Timestamp
  Stream<RequestTrackingLocation?> streamRequestTrackingLocation(String requestId) {
    return _db
        .collection('requestTracking')
        .doc(requestId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      final mechanicLat = (data['mechanicLatitude'] as num?)?.toDouble();
      final mechanicLng = (data['mechanicLongitude'] as num?)?.toDouble();
      final userLat = (data['userLatitude'] as num?)?.toDouble();
      final userLng = (data['userLongitude'] as num?)?.toDouble();

      // Return null if location data is not available
      if (mechanicLat == null || mechanicLng == null || 
          userLat == null || userLng == null) {
        return null;
      }

      return RequestTrackingLocation(
        requestId: requestId,
        mechanicId: data['mechanicId'] ?? '',
        mechanicName: data['mechanicName'] ?? '',
        mechanicLatitude: mechanicLat,
        mechanicLongitude: mechanicLng,
        userLatitude: userLat,
        userLongitude: userLng,
        status: data['status'] ?? 'pending',
        lastUpdated: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    });
  }

  /// Calculate distance and ETA between mechanic and user
  Future<TrackingMetrics> calculateMetrics(RequestTrackingLocation location) async {
    // Calculate distance in meters
    final distanceMeters = Geolocator.distanceBetween(
      location.userLatitude,
      location.userLongitude,
      location.mechanicLatitude,
      location.mechanicLongitude,
    );

    final distanceKm = distanceMeters / 1000;

    // Estimate ETA (assuming average speed of 30 km/h in city traffic)
    final avgSpeedKmPerHour = 30.0;
    final etaMinutes = ((distanceKm / avgSpeedKmPerHour) * 60).round();

    return TrackingMetrics(
      distanceKm: distanceKm,
      distanceMeters: distanceMeters,
      etaMinutes: etaMinutes,
    );
  }

  /// Check if mechanic has arrived (within 50 meters)
  bool hasArrived(RequestTrackingLocation location) {
    final distanceMeters = Geolocator.distanceBetween(
      location.userLatitude,
      location.userLongitude,
      location.mechanicLatitude,
      location.mechanicLongitude,
    );

    // Consider arrived if within 50 meters or status is 'arrived'
    return distanceMeters <= 50 || location.status == 'arrived';
  }

  /// Update mechanic location in requestTracking (for mechanic app)
  Future<void> updateMechanicLocationInRequest({
    required String requestId,
    required double latitude,
    required double longitude,
  }) async {
    await _db.collection('requestTracking').doc(requestId).update({
      'mechanicLatitude': latitude,
      'mechanicLongitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update request status
  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    await _db.collection('requestTracking').doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

/// Model for request tracking location data
class RequestTrackingLocation {
  final String requestId;
  final String mechanicId;
  final String mechanicName;
  final double mechanicLatitude;
  final double mechanicLongitude;
  final double userLatitude;
  final double userLongitude;
  final String status;
  final DateTime lastUpdated;

  RequestTrackingLocation({
    required this.requestId,
    required this.mechanicId,
    required this.mechanicName,
    required this.mechanicLatitude,
    required this.mechanicLongitude,
    required this.userLatitude,
    required this.userLongitude,
    required this.status,
    required this.lastUpdated,
  });

  /// Check if location is stale (older than 2 minutes)
  bool get isStale {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inMinutes > 2;
  }

  /// Get time since last update
  String getTimeSinceUpdate() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  /// Calculate distance between mechanic and user
  double get distanceKm {
    final distanceMeters = Geolocator.distanceBetween(
      userLatitude,
      userLongitude,
      mechanicLatitude,
      mechanicLongitude,
    );
    return distanceMeters / 1000;
  }

  /// Check if mechanic is on the way
  bool get isOnTheWay {
    return status == 'on_the_way' || status == 'assigned';
  }

  /// Check if mechanic has arrived
  bool get hasArrived {
    return status == 'arrived' || distanceKm <= 0.05; // 50 meters
  }
}

/// Model for tracking metrics
class TrackingMetrics {
  final double distanceKm;
  final double distanceMeters;
  final int etaMinutes;

  TrackingMetrics({
    required this.distanceKm,
    required this.distanceMeters,
    required this.etaMinutes,
  });
}
