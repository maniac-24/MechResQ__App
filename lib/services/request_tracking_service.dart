import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/request_tracking.dart';
import 'location_service.dart';
import 'notification_service.dart';

/// Request Tracking Service
/// Manages real-time tracking of mechanic requests with location updates
class RequestTrackingService {
  static final RequestTrackingService _instance = RequestTrackingService._internal();
  factory RequestTrackingService() => _instance;
  RequestTrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  StreamSubscription<DocumentSnapshot>? _trackingSubscription;
  StreamSubscription<Position>? _locationSubscription;
  
  String? _activeRequestId;
  RequestTracking? _currentTracking;

  // ═══════════════════════════════════════════
  // CREATE & UPDATE TRACKING
  // ═══════════════════════════════════════════

  /// Create initial tracking document for a new request
  Future<void> createTracking({
    required String requestId,
    required String userId,
    required double userLatitude,
    required double userLongitude,
    String? userAddress,
  }) async {
    try {
      final tracking = RequestTracking(
        requestId: requestId,
        userId: userId,
        status: RequestStatus.pending,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        userAddress: userAddress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('requestTracking')
          .doc(requestId)
          .set(tracking.toMap());

      print('✅ Tracking created for request: $requestId');
    } catch (e) {
      print('❌ Error creating tracking: $e');
      rethrow;
    }
  }

  /// Update tracking when mechanic accepts request
  Future<void> acceptRequest({
    required String requestId,
    required String mechanicId,
    required String mechanicName,
    required String mechanicPhone,
    required double mechanicLatitude,
    required double mechanicLongitude,
    String? mechanicVehicleNumber,
  }) async {
    try {
      final doc = await _firestore
          .collection('requestTracking')
          .doc(requestId)
          .get();

      if (!doc.exists) {
        print('❌ Tracking document not found');
        return;
      }

      final tracking = RequestTracking.fromFirestore(doc);
      
      // Calculate distance and ETA
      final distance = _locationService.calculateDistance(
        startLat: mechanicLatitude,
        startLng: mechanicLongitude,
        endLat: tracking.userLatitude,
        endLng: tracking.userLongitude,
      );

      final eta = _locationService.calculateETA(distanceInMeters: distance);
      final estimatedArrival = DateTime.now().add(Duration(minutes: eta));

      await _firestore
          .collection('requestTracking')
          .doc(requestId)
          .update({
        'mechanicId': mechanicId,
        'mechanicName': mechanicName,
        'mechanicPhone': mechanicPhone,
        'mechanicVehicleNumber': mechanicVehicleNumber,
        'mechanicLatitude': mechanicLatitude,
        'mechanicLongitude': mechanicLongitude,
        'status': 'accepted',
        'distanceInMeters': distance,
        'etaInMinutes': eta,
        'estimatedArrivalTime': Timestamp.fromDate(estimatedArrival),
        'acceptedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Send notification
      await _notificationService.showInstantNotification(
        title: 'Request Accepted! 🎉',
        body: '$mechanicName is on the way. ETA: $eta min',
        payload: 'tracking:$requestId',
      );

      print('✅ Request accepted: $requestId');
    } catch (e) {
      print('❌ Error accepting request: $e');
      rethrow;
    }
  }

  /// Update mechanic's location (called by mechanic app)
  Future<void> updateMechanicLocation({
    required String requestId,
    required double mechanicLatitude,
    required double mechanicLongitude,
  }) async {
    try {
      final doc = await _firestore
          .collection('requestTracking')
          .doc(requestId)
          .get();

      if (!doc.exists) return;

      final tracking = RequestTracking.fromFirestore(doc);
      
      // Calculate new distance and ETA
      final distance = _locationService.calculateDistance(
        startLat: mechanicLatitude,
        startLng: mechanicLongitude,
        endLat: tracking.userLatitude,
        endLng: tracking.userLongitude,
      );

      final eta = _locationService.calculateETA(distanceInMeters: distance);
      final estimatedArrival = DateTime.now().add(Duration(minutes: eta));

      // Determine new status based on distance
      RequestStatus newStatus = tracking.status;
      
      if (distance < 100 && tracking.status == RequestStatus.mechanicEnRoute) {
        // Mechanic has arrived
        newStatus = RequestStatus.mechanicArrived;
        await _notificationService.showInstantNotification(
          title: 'Mechanic Arrived! 🎯',
          body: '${tracking.mechanicName} has reached your location',
          payload: 'tracking:$requestId',
        );
      } else if (distance < 500 && tracking.status == RequestStatus.mechanicEnRoute) {
        // Mechanic is nearby
        newStatus = RequestStatus.mechanicNearby;
        await _notificationService.showInstantNotification(
          title: 'Mechanic Nearby! 📍',
          body: '${tracking.mechanicName} is less than 500m away',
          payload: 'tracking:$requestId',
        );
      }

      final updateData = {
        'mechanicLatitude': mechanicLatitude,
        'mechanicLongitude': mechanicLongitude,
        'distanceInMeters': distance,
        'etaInMinutes': eta,
        'estimatedArrivalTime': Timestamp.fromDate(estimatedArrival),
        'updatedAt': Timestamp.now(),
      };

      if (newStatus != tracking.status) {
        updateData['status'] = _statusToString(newStatus);
        if (newStatus == RequestStatus.mechanicArrived) {
          updateData['arrivedAt'] = Timestamp.now();
        }
      }

      await _firestore
          .collection('requestTracking')
          .doc(requestId)
          .update(updateData);

    } catch (e) {
      print('❌ Error updating mechanic location: $e');
    }
  }

  /// Update request status
  Future<void> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    try {
      final updateData = {
        'status': _statusToString(status),
        'updatedAt': Timestamp.now(),
      };

      if (status == RequestStatus.mechanicEnRoute) {
        // Mechanic started journey
        await _notificationService.showInstantNotification(
          title: 'Mechanic En Route! 🚗',
          body: 'Your mechanic is on the way to your location',
          payload: 'tracking:$requestId',
        );
      } else if (status == RequestStatus.workInProgress) {
        // Work started
        await _notificationService.showInstantNotification(
          title: 'Work Started! 🔧',
          body: 'Your mechanic has started working on your vehicle',
          payload: 'tracking:$requestId',
        );
      } else if (status == RequestStatus.completed) {
        updateData['completedAt'] = Timestamp.now();
        await _notificationService.showInstantNotification(
          title: 'Work Completed! ✅',
          body: 'Your vehicle service has been completed',
          payload: 'tracking:$requestId',
        );
      }

      await _firestore
          .collection('requestTracking')
          .doc(requestId)
          .update(updateData);

      print('✅ Status updated to: $status');
    } catch (e) {
      print('❌ Error updating status: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════
  // REAL-TIME TRACKING
  // ═══════════════════════════════════════════

  /// Stream tracking for a request.
  /// Falls back to `requests` collection if no tracking doc exists yet.
  Stream<RequestTracking> trackRequest(String requestId) {
    return _firestore
        .collection('requestTracking')
        .doc(requestId)
        .snapshots()
        .asyncMap((doc) async {
      if (doc.exists) {
        return RequestTracking.fromFirestore(doc);
      }

      // Fallback: build a minimal tracking object from the requests collection
      try {
        final requestDoc = await _firestore
            .collection('requests')
            .doc(requestId)
            .get();

        if (!requestDoc.exists) {
          throw Exception('Tracking not found');
        }

        final d = requestDoc.data() as Map<String, dynamic>;
        final statusStr = (d['status'] ?? 'pending').toString();

        // Auto-create the tracking document so future loads work
        final tracking = RequestTracking(
          requestId: requestId,
          userId: d['userId'] ?? '',
          status: _statusFromString(statusStr),
          userLatitude: (d['userLat'] ?? 0.0).toDouble(),
          userLongitude: (d['userLng'] ?? 0.0).toDouble(),
          userAddress: d['locationAddress'] ?? d['location'],
          mechanicId: d['mechanicId'],
          mechanicName: d['mechanicName'],
          mechanicPhone: d['mechanicPhone'],
          mechanicVehicleNumber: d['mechanicVehicleNumber'],
          createdAt: d['createdAt'] != null
              ? (d['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Persist so the stream works live from now on
        await _firestore
            .collection('requestTracking')
            .doc(requestId)
            .set(tracking.toMap());

        return tracking;
      } catch (e) {
        throw Exception('Tracking not found');
      }
    });
  }

  RequestStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':        return RequestStatus.pending;
      case 'accepted':       return RequestStatus.accepted;
      case 'mechanicenroute':
      case 'mechanic_enroute': return RequestStatus.mechanicEnRoute;
      case 'mechanicnearby':
      case 'mechanic_nearby':  return RequestStatus.mechanicNearby;
      case 'mechanicarrived':
      case 'mechanic_arrived': return RequestStatus.mechanicArrived;
      case 'workinprogress':
      case 'work_in_progress': return RequestStatus.workInProgress;
      case 'completed':      return RequestStatus.completed;
      case 'cancelled':      return RequestStatus.cancelled;
      default:               return RequestStatus.pending;
    }
  }

  /// Start active tracking with notifications
  Future<void> startActiveTracking(String requestId) async {
    try {
      _activeRequestId = requestId;

      // Listen to tracking updates
      _trackingSubscription?.cancel();
      _trackingSubscription = _firestore
          .collection('requestTracking')
          .doc(requestId)
          .snapshots()
          .listen(_handleTrackingUpdate);

      print('✅ Active tracking started for: $requestId');
    } catch (e) {
      print('❌ Error starting active tracking: $e');
    }
  }

  /// Handle tracking updates and send notifications
  void _handleTrackingUpdate(DocumentSnapshot doc) {
    if (!doc.exists) return;

    final newTracking = RequestTracking.fromFirestore(doc);
    final oldTracking = _currentTracking;
    _currentTracking = newTracking;

    // Check for status changes
    if (oldTracking != null && oldTracking.status != newTracking.status) {
      print('📍 Status changed: ${oldTracking.status} -> ${newTracking.status}');
    }

    // Check for distance-based alerts
    if (newTracking.distanceInMeters != null) {
      final distance = newTracking.distanceInMeters!;
      
      // Alert when mechanic is very close (< 200m)
      if (distance < 200 && 
          newTracking.status == RequestStatus.mechanicEnRoute) {
        _notificationService.showInstantNotification(
          title: 'Almost There! 🎯',
          body: 'Mechanic is just ${distance.toInt()}m away',
          payload: 'tracking:${newTracking.requestId}',
        );
      }
    }
  }

  /// Stop active tracking
  void stopActiveTracking() {
    _trackingSubscription?.cancel();
    _trackingSubscription = null;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _activeRequestId = null;
    _currentTracking = null;
    print('🛑 Active tracking stopped');
  }

  // ═══════════════════════════════════════════
  // QUERIES
  // ═══════════════════════════════════════════

  /// Get tracking for a specific request
  Future<RequestTracking?> getTracking(String requestId) async {
    try {
      final doc = await _firestore
          .collection('requestTracking')
          .doc(requestId)
          .get();

      if (!doc.exists) return null;

      return RequestTracking.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting tracking: $e');
      return null;
    }
  }

  /// Get all active trackings for a user
  Stream<List<RequestTracking>> getUserActiveTrackings(String userId) {
    return _firestore
        .collection('requestTracking')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: [
          'pending',
          'accepted',
          'mechanicEnRoute',
          'mechanicNearby',
          'mechanicArrived',
          'workInProgress',
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RequestTracking.fromFirestore(doc))
          .toList();
    });
  }

  /// Get tracking history for a user
  Future<List<RequestTracking>> getTrackingHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('requestTracking')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => RequestTracking.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting tracking history: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════

  void dispose() {
    stopActiveTracking();
  }

  // Helper to convert status to string
  String _statusToString(RequestStatus status) {
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
}
