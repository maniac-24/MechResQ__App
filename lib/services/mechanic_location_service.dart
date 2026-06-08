import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

/// Service for real-time mechanic location tracking
/// Handles streaming mechanic location updates from Firestore
class MechanicLocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream mechanic's live location from Firestore
  /// Returns updates whenever mechanic's location changes
  /// 
  /// Expected Firestore structure:
  /// mechanics/{mechanicId}/
  ///   - liveLat: double
  ///   - liveLng: double
  ///   - lastUpdated: Timestamp
  ///   - isOnline: bool
  ///   - heading: double (optional, direction in degrees)
  Stream<MechanicLocation?> streamMechanicLocation(String mechanicId) {
    return _db
        .collection('mechanics')
        .doc(mechanicId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      final lat = (data['liveLat'] as num?)?.toDouble();
      final lng = (data['liveLng'] as num?)?.toDouble();

      // Return null if location data is not available
      if (lat == null || lng == null) return null;

      return MechanicLocation(
        mechanicId: mechanicId,
        latitude: lat,
        longitude: lng,
        lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isOnline: data['isOnline'] ?? false,
        heading: (data['heading'] as num?)?.toDouble(),
      );
    });
  }

  /// Calculate distance and ETA between two coordinates
  /// Returns a map with distance in km and estimated time in minutes
  Future<TrackingMetrics> calculateMetrics({
    required double userLat,
    required double userLng,
    required double mechanicLat,
    required double mechanicLng,
  }) async {
    // Calculate distance in meters
    final distanceMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      mechanicLat,
      mechanicLng,
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
  bool hasArrived({
    required double userLat,
    required double userLng,
    required double mechanicLat,
    required double mechanicLng,
  }) {
    final distanceMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      mechanicLat,
      mechanicLng,
    );

    // Consider arrived if within 50 meters
    return distanceMeters <= 50;
  }

  /// Update mechanic's live location (for mechanic app)
  /// This should only be called from the mechanic-side app
  Future<void> updateMechanicLocation({
    required String mechanicId,
    required double latitude,
    required double longitude,
    double? heading,
  }) async {
    await _db.collection('mechanics').doc(mechanicId).update({
      'liveLat': latitude,
      'liveLng': longitude,
      'lastUpdated': FieldValue.serverTimestamp(),
      'isOnline': true,
      if (heading != null) 'heading': heading,
    });
  }

  /// Set mechanic offline (stops location updates)
  Future<void> setMechanicOffline(String mechanicId) async {
    await _db.collection('mechanics').doc(mechanicId).update({
      'isOnline': false,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}

/// Model for mechanic location data
class MechanicLocation {
  final String mechanicId;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;
  final bool isOnline;
  final double? heading; // Direction in degrees (0-360)

  MechanicLocation({
    required this.mechanicId,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    required this.isOnline,
    this.heading,
  });

  /// Check if location is stale (older than 2 minutes)
  bool get isStale {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inMinutes > 2;
  }

  /// Get time since last update in human-readable format
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
}

/// Model for tracking metrics (distance and ETA)
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
