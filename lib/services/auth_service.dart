import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

/// Authentication Service (OTP-BASED ONLY)
/// 
/// This app uses phone number OTP authentication exclusively.
/// Email/password and Google Sign-In have been removed.
class AuthService {
  // ─────────────────────────────────────────────────────────────
  // SINGLETON
  // ─────────────────────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // ─────────────────────────────────────────────────────────────
  // AUTH STATE
  // ─────────────────────────────────────────────────────────────
  
  /// Check if user is currently logged in
  bool isLoggedIn() => _auth.currentUser != null;

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ─────────────────────────────────────────────────────────────
  // PROFILE ACCESS (UI SAFE)
  // ─────────────────────────────────────────────────────────────

  /// Get current user profile (Future-based)
  /// Used in: FutureBuilder screens, splash screen
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    return _firestore.getMyProfile();
  }

  /// Get current user profile (backward compatibility)
  /// Used in: Various screens that call getMyProfile()
  Future<Map<String, dynamic>?> getMyProfile() async {
    return _firestore.getMyProfile();
  }

  /// Stream current user profile for real-time updates
  /// Used in: StreamBuilder screens, ProfileScreen
  Stream<Map<String, dynamic>?> getMyProfileStream() {
    return _firestore.getMyProfileStream();
  }

  /// Get user role for routing decisions
  /// Used in: SplashScreen, HomeRouter
  Future<String?> getRole() async {
    final profile = await getCurrentUserProfile();
    return profile?['role']?.toString();
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────
  
  /// Sign out current user
  /// Used in: SettingsScreen, ProfileScreen
  Future<void> logout() async {
    await _auth.signOut();
  }
}
