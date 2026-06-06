import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ----------------------------------------------------------------
/// ENUMS (Shared with Mechanic App)
/// ----------------------------------------------------------------
enum UserRole { user, mechanic }

enum VerificationStatus {
  pending,
  approved,
  rejected;

  String get value => name;
}

/// ----------------------------------------------------------------
/// FIRESTORE SERVICE (USER-SIDE ONLY)
/// ----------------------------------------------------------------
/// 
/// Mechanic-specific functions have been moved to the mechanic app.
/// This version only handles user profile operations.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // =========================================================
  // CREATE USER PROFILE
  // =========================================================
  
  /// Creates a new user profile in Firestore
  /// Used by: RegisterUserScreen, CreateProfileScreen
  Future<void> createUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    final now = FieldValue.serverTimestamp();

    await _db.collection("users").doc(_uid).set(
      {
        "uid": _uid,
        "role": UserRole.user.name,
        "name": name,
        "email": email,
        "phone": phone,
        "createdAt": now,
        "updatedAt": now,
      },
      SetOptions(merge: true),
    );
  }

  // =========================================================
  // UPDATE USER PROFILE
  // =========================================================
  
  /// Updates user profile information
  /// Used by: EditProfileScreen
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;

    await _db.collection("users").doc(_uid).update(updates);
  }

  /// Updates complete user profile with all fields
  /// Used by: EditProfileScreen (comprehensive profile update)
  Future<void> updateCompleteUserProfile({
    String? name,
    String? email,
    String? phone,
    String? gender,
    List<String>? languages,
    String? dob,
    String? pincode,
    String? city,
    String? state,
    bool? serviceReminders,
    bool? biometricLogin,
  }) async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    if (gender != null) updates['gender'] = gender;
    if (languages != null) updates['languages'] = languages;
    if (dob != null) updates['dob'] = dob;
    if (pincode != null) updates['pincode'] = pincode;
    if (city != null) updates['city'] = city;
    if (state != null) updates['state'] = state;
    if (serviceReminders != null) updates['serviceReminders'] = serviceReminders;
    if (biometricLogin != null) updates['biometricLogin'] = biometricLogin;

    // Use set with merge to create fields if they don't exist
    await _db.collection("users").doc(_uid).set(
      updates,
      SetOptions(merge: true),
    );
  }

  // =========================================================
  // GET CURRENT PROFILE
  // =========================================================
  
  /// Get the current user's profile (Future-based)
  /// Used by: AuthService, ProfileScreen
  Future<Map<String, dynamic>?> getMyProfile() async {
    if (_uid == null) return null;

    final userDoc = await _db.collection("users").doc(_uid).get();

    if (userDoc.exists) {
      return userDoc.data();
    }

    // Fallback: Check if user is actually a mechanic
    // (This should not happen in pure user app, but kept for safety)
    final mechDoc = await _db.collection("mechanics").doc(_uid).get();

    if (mechDoc.exists) {
      return mechDoc.data();
    }

    return null;
  }

  // =========================================================
  // PROFILE STREAM
  // =========================================================
  
  /// Stream the current user's profile for real-time updates
  /// Used by: ProfileScreen, SettingsScreen
  Stream<Map<String, dynamic>?> getMyProfileStream() {
    if (_uid == null) {
      return const Stream.empty();
    }

    final userRef = _db.collection("users").doc(_uid);

    return userRef.snapshots().map((userSnap) {
      if (userSnap.exists) {
        return userSnap.data();
      }
      return null;
    });
  }

  // =========================================================
  // DELETE USER ACCOUNT
  // =========================================================
  
  /// Delete user profile and all associated data
  /// Used by: SettingsScreen (account deletion feature)
  Future<void> deleteUserAccount() async {
    if (_uid == null) {
      throw Exception('User not authenticated');
    }

    // Delete user profile
    await _db.collection("users").doc(_uid).delete();

    // Note: You may want to also delete:
    // - User's requests
    // - User's vehicles
    // - User's chat messages
    // Consider using Cloud Functions for cascading deletes
  }
}
