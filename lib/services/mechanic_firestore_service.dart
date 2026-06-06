// lib/services/mechanic_firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to fetch verified mechanics from Firestore (USER-SIDE ONLY)
/// 
/// This service is used by users to discover and view mechanic profiles.
/// Mechanic-specific functions have been moved to the mechanic app.
class MechanicFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns a stream of verified mechanics as List<Map<String, dynamic>>
  /// Only mechanics where isVerified == true are included
  /// Ordered by creation date (newest first) for consistent UI presentation
  /// 
  /// Used by: HomeScreen, MechanicListView
  Stream<List<Map<String, dynamic>>> getVerifiedMechanicsStream() {
    return _db
        .collection('mechanics')
        .where('isVerified', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final uid = doc.id;

        // Role safety: only include documents with mechanic role
        if (data['role'] != 'mechanic') {
          return null;
        }

        return {
          'uid': uid,
          'id': uid,

          // Core mechanic info
          'name': (data['name'] ?? '').toString(),
          'shopName': (data['shopName'] ?? '').toString(),
          'email': (data['email'] ?? '').toString(),
          'phone': (data['phone'] ?? '').toString(),
          'address': (data['address'] ?? '').toString(),

          // Vehicle types as List<String>
          'vehicleTypes': (data['vehicleTypes'] is List)
              ? List<String>.from(data['vehicleTypes'])
              : <String>[],

          // Services offered as List<String>
          'services': (data['services'] is List)
              ? List<String>.from(data['services'])
              : <String>[],

          // Verification status
          'isVerified': data['isVerified'] ?? false,

          // Real metrics (not dummy data)
          'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
          'totalReviews': (data['totalReviews'] as num?)?.toInt() ?? 0,
          'experienceYears': (data['experienceYears'] as num?)?.toInt() ?? 0,

          // Timestamps
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],

          // NOTE: distanceKm is NOT stored in Firestore
          // It must be computed client-side based on user location:
          // double distanceKm = calculateDistance(userLat, userLng, mechLat, mechLng);
        };
      }).whereType<Map<String, dynamic>>().toList(); // Filter out nulls from role check
    });
  }

  /// Get a single mechanic's profile by ID
  /// Used by: MechanicDetailScreen, UserMechanicDetailScreen
  Future<Map<String, dynamic>?> getMechanicProfile(String mechanicId) async {
    final doc = await _db.collection('mechanics').doc(mechanicId).get();
    
    if (!doc.exists) return null;
    
    final data = doc.data();
    if (data == null || data['role'] != 'mechanic') return null;
    
    return {
      'uid': doc.id,
      'id': doc.id,
      'name': (data['name'] ?? '').toString(),
      'shopName': (data['shopName'] ?? '').toString(),
      'email': (data['email'] ?? '').toString(),
      'phone': (data['phone'] ?? '').toString(),
      'address': (data['address'] ?? '').toString(),
      'vehicleTypes': (data['vehicleTypes'] is List)
          ? List<String>.from(data['vehicleTypes'])
          : <String>[],
      'services': (data['services'] is List)
          ? List<String>.from(data['services'])
          : <String>[],
      'isVerified': data['isVerified'] ?? false,
      'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
      'totalReviews': (data['totalReviews'] as num?)?.toInt() ?? 0,
      'experienceYears': (data['experienceYears'] as num?)?.toInt() ?? 0,
      'createdAt': data['createdAt'],
      'updatedAt': data['updatedAt'],
    };
  }
}
