import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore service for handling service requests (USER-SIDE ONLY)
/// 
/// Mechanic-specific functions have been moved to the mechanic app:
/// - acceptRequest, rejectRequest, completeRequest
/// - getIncomingRequestsStream, getMechanicRequestsByStatusStream
/// - getActiveRequestsCountStream, getCompletedRequestsCountStream
/// - getTotalEarningsStream, getDailyEarningsStream
class RequestFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;
  // Public getter for screens that need the current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // =========================================================
  // CREATE REQUEST
  // =========================================================

  /// Creates a new service request
  /// Used by: CreateRequestScreen
  Future<String> createRequest({
    required String vehicleType,
    required String issue,
    required String location,
    String? mechanicId,
    List<String>? images,
    double? userLat,
    double? userLng,
    String? locationAddress,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final requestRef = _db.collection('requests').doc();

    await requestRef.set({
      'requestId': requestRef.id,
      'userId': userId,
      'vehicleType': vehicleType,
      'issue': issue,
      'location': location,
      'status': 'pending',
      'mechanicId': mechanicId,
      'images': images ?? [],
      'userLat': userLat,
      'userLng': userLng,
      'locationAddress': locationAddress,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return requestRef.id;
  }

  // =========================================================
  // GET USER REQUESTS
  // =========================================================

  /// Get all requests created by the current user
  /// Used by: MyRequestsScreen
  Stream<List<Map<String, dynamic>>> getUserRequestsStream() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _db
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  /// Get a single request by ID
  /// Used by: RequestDetailScreen
  Future<Map<String, dynamic>?> getRequestById(String requestId) async {
    final doc = await _db.collection('requests').doc(requestId).get();
    if (!doc.exists) return null;
    return _mapDoc(doc);
  }

  /// Stream a single request by ID
  /// Used by: TrackMechanicScreen, RequestDetailScreen (real-time updates)
  Stream<Map<String, dynamic>?> getRequestStream(String requestId) {
    return _db
        .collection('requests')
        .doc(requestId)
        .snapshots()
        .map((doc) => doc.exists ? _mapDoc(doc) : null);
  }

  // =========================================================
  // CANCEL REQUEST
  // =========================================================

  /// Cancel a request (only if status is 'pending')
  /// Used by: RequestDetailScreen, MyRequestsScreen
  Future<void> cancelRequest(String requestId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    // Verify the request belongs to the current user
    final doc = await _db.collection('requests').doc(requestId).get();
    if (!doc.exists) throw Exception('Request not found');
    
    final data = doc.data();
    if (data?['userId'] != userId) {
      throw Exception('Unauthorized: This request does not belong to you');
    }

    if (data?['status'] != 'pending') {
      throw Exception('Can only cancel pending requests');
    }

    await _db.collection('requests').doc(requestId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // DELETE REQUEST
  // =========================================================

  /// Delete a request from history
  /// Used by: MyRequestsScreen (bulk delete)
  Future<void> deleteRequest(String requestId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    // Verify the request belongs to the current user
    final doc = await _db.collection('requests').doc(requestId).get();
    if (!doc.exists) throw Exception('Request not found');
    
    final data = doc.data();
    if (data?['userId'] != userId) {
      throw Exception('Unauthorized: This request does not belong to you');
    }

    // Only allow deletion of cancelled or completed requests
    final status = data?['status'];
    if (status != 'cancelled' && status != 'completed') {
      throw Exception('Can only delete cancelled or completed requests');
    }

    // Delete the request document
    await _db.collection('requests').doc(requestId).delete();
    
    // Note: Consider also deleting related data (requestTracking, payments, etc.)
    // For now, we only delete the main request document
  }

  // =========================================================
  // GET USER PROFILE
  // =========================================================

  /// Fetches mechanic profile data (name, phone, etc.) for display
  /// Used by: RequestDetailScreen, ChatMechanicScreen
  Future<Map<String, dynamic>?> getMechanicProfile(String mechanicId) async {
    final doc = await _db.collection('mechanics').doc(mechanicId).get();
    return doc.exists ? doc.data() : null;
  }

  // =========================================================
  // HELPERS
  // =========================================================

  List<Map<String, dynamic>> _mapSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map(_mapDoc).toList();
  }

  Map<String, dynamic> _mapDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return {};
    return {
      'requestId': d['requestId'] ?? doc.id,
      'userId': d['userId'],
      'mechanicId': d['mechanicId'],
      'vehicleType': d['vehicleType'],
      'issue': d['issue'],
      'location': d['location'],
      'locationAddress': d['locationAddress'],
      'status': d['status'],
      'images': d['images'] ?? [],
      'userLat': d['userLat'],
      'userLng': d['userLng'],
      'createdAt': (d['createdAt'] as Timestamp?)?.toDate(),
      'updatedAt': (d['updatedAt'] as Timestamp?)?.toDate(),
      'completedAt': (d['completedAt'] as Timestamp?)?.toDate(),
      'amount': d['amount'] ?? 0,
    };
  }
}
