import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';
import '../models/sos_event.dart';

/// SOS Service - Handles all emergency operations
/// Simple, lightweight, no complex dependencies
class SOSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════
  // EMERGENCY CONTACTS MANAGEMENT
  // ═══════════════════════════════════════════

  /// Get all emergency contacts for a user
  Future<List<EmergencyContact>> getEmergencyContacts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergencyContacts')
          .orderBy('isPrimary', descending: true)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EmergencyContact.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  /// Get emergency contacts as stream (real-time updates)
  Stream<List<EmergencyContact>> getEmergencyContactsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('emergencyContacts')
        .orderBy('isPrimary', descending: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyContact.fromMap(doc.data()))
            .toList());
  }

  /// Add new emergency contact
  Future<bool> addEmergencyContact(
    String userId,
    EmergencyContact contact,
  ) async {
    try {
      // Check if user already has 5 contacts (max limit)
      final existing = await getEmergencyContacts(userId);
      if (existing.length >= 5) {
        print('Maximum 5 emergency contacts allowed');
        return false;
      }

      // If this is marked as primary, remove primary from others
      if (contact.isPrimary) {
        await _removePrimaryFromOthers(userId);
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergencyContacts')
          .doc(contact.id)
          .set(contact.toMap());

      return true;
    } catch (e) {
      print('Error adding emergency contact: $e');
      return false;
    }
  }

  /// Update emergency contact
  Future<bool> updateEmergencyContact(
    String userId,
    EmergencyContact contact,
  ) async {
    try {
      // If this is marked as primary, remove primary from others
      if (contact.isPrimary) {
        await _removePrimaryFromOthers(userId, exceptId: contact.id);
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergencyContacts')
          .doc(contact.id)
          .update(contact.toMap());

      return true;
    } catch (e) {
      print('Error updating emergency contact: $e');
      return false;
    }
  }

  /// Delete emergency contact
  Future<bool> deleteEmergencyContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergencyContacts')
          .doc(contactId)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting emergency contact: $e');
      return false;
    }
  }

  /// Remove primary status from all contacts except one
  Future<void> _removePrimaryFromOthers(String userId,
      {String? exceptId}) async {
    final contacts = await getEmergencyContacts(userId);
    for (var contact in contacts) {
      if (contact.id != exceptId && contact.isPrimary) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('emergencyContacts')
            .doc(contact.id)
            .update({'isPrimary': false});
      }
    }
  }

  // ═══════════════════════════════════════════
  // SOS ACTIVATION & ALERTS
  // ═══════════════════════════════════════════

  /// Activate SOS - Main emergency function
  /// Returns SOS event ID if successful
  Future<String?> activateSOS({
    required String userId,
    required String userName,
    required String userPhone,
    required String location,
    required double latitude,
    required double longitude,
    String? notes,
    String emergencyType = 'vehicle',
  }) async {
    try {
      // Create SOS event
      final sosId = _firestore.collection('sosEvents').doc().id;
      
      final sosEvent = SOSEvent(
        id: sosId,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        timestamp: DateTime.now(),
        location: location,
        latitude: latitude,
        longitude: longitude,
        status: 'sent',
        contactsNotified: [],
        mechanicsAlerted: 0,
        notes: notes,
        emergencyType: emergencyType,
      );

      // Save SOS event to Firestore
      await _firestore
          .collection('sosEvents')
          .doc(sosId)
          .set(sosEvent.toMap());

      // Also save in user's SOS history
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sosHistory')
          .doc(sosId)
          .set(sosEvent.toMap());

      return sosId;
    } catch (e) {
      print('Error activating SOS: $e');
      return null;
    }
  }

  /// Send SMS to emergency contacts
  /// Uses SMS app (works without internet)
  Future<bool> sendSMSToContacts({
    required String sosId,
    required List<EmergencyContact> contacts,
    required String userName,
    required String userPhone,
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final mapsLink = 'https://maps.google.com/?q=$latitude,$longitude';
      
      final message = Uri.encodeComponent(
        '🚨 EMERGENCY - MechResQ SOS Alert\n\n'
        '$userName needs urgent help!\n\n'
        '📍 Location: $location\n'
        '🗺️ Maps: $mapsLink\n'
        '📞 Call: $userPhone\n'
        '🕐 Time: ${DateTime.now().toString().substring(0, 16)}\n\n'
        'This is an automated emergency message from MechResQ app.',
      );

      // Send to all contacts
      for (var contact in contacts) {
        final smsUri = 'sms:${contact.phone}?body=$message';
        final uri = Uri.parse(smsUri);
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      }

      // Update SOS event with notified contacts
      await _firestore.collection('sosEvents').doc(sosId).update({
        'contactsNotified': contacts.map((c) => c.id).toList(),
      });

      return true;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  /// Alert nearby mechanics
  /// Creates high-priority SOS request
  Future<int> alertNearbyMechanics({
    required String sosId,
    required String userId,
    required String userName,
    required String userPhone,
    required String location,
    required double latitude,
    required double longitude,
    double radiusKm = 10.0, // Alert mechanics within 10km
  }) async {
    try {
      // Get nearby mechanics (simplified - you can enhance with geohash)
      final mechanicsSnapshot = await _firestore
          .collection('mechanics')
          .where('isAvailable', isEqualTo: true)
          .limit(10) // Get top 10 available
          .get();

      int alertedCount = 0;

      // Create SOS broadcast notification for each mechanic
      for (var mechanicDoc in mechanicsSnapshot.docs) {
        final mechanicId = mechanicDoc.id;
        
        // Create notification in mechanic's collection
        await _firestore
            .collection('mechanics')
            .doc(mechanicId)
            .collection('sosAlerts')
            .doc(sosId)
            .set({
          'sosId': sosId,
          'userId': userId,
          'userName': userName,
          'userPhone': userPhone,
          'location': location,
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending', // pending, accepted, expired
          'priority': 'high',
          'expiresAt': DateTime.now().add(Duration(minutes: 15)),
        });

        alertedCount++;
      }

      // Update SOS event with alerted count
      await _firestore.collection('sosEvents').doc(sosId).update({
        'mechanicsAlerted': alertedCount,
      });

      return alertedCount;
    } catch (e) {
      print('Error alerting mechanics: $e');
      return 0;
    }
  }

  // ═══════════════════════════════════════════
  // PHONE CALLS
  // ═══════════════════════════════════════════

  /// Call primary emergency contact
  Future<bool> callPrimaryContact(String userId) async {
    try {
      final contacts = await getEmergencyContacts(userId);
      final primary = contacts.firstWhere(
        (c) => c.isPrimary,
        orElse: () => contacts.isNotEmpty ? contacts.first : EmergencyContact(
          id: '', name: '', phone: '', relationship: '', createdAt: DateTime.now(),
        ),
      );

      if (primary.phone.isEmpty) return false;

      return await makeCall(primary.phone);
    } catch (e) {
      print('Error calling primary contact: $e');
      return false;
    }
  }

  /// Make a phone call
  Future<bool> makeCall(String phoneNumber) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      print('Error making call: $e');
      return false;
    }
  }

  /// Call emergency services (112 in India)
  Future<bool> callEmergencyServices() async {
    return await makeCall('112');
  }

  // ═══════════════════════════════════════════
  // SOS HISTORY
  // ═══════════════════════════════════════════

  /// Get user's SOS history
  Future<List<SOSEvent>> getSOSHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sosHistory')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SOSEvent.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting SOS history: $e');
      return [];
    }
  }

  /// Get SOS history as stream
  Stream<List<SOSEvent>> getSOSHistoryStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('sosHistory')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SOSEvent.fromMap(doc.data())).toList());
  }

  /// Update SOS event status
  Future<bool> updateSOSStatus(
    String userId,
    String sosId,
    String status,
  ) async {
    try {
      await _firestore
          .collection('sosEvents')
          .doc(sosId)
          .update({'status': status});

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sosHistory')
          .doc(sosId)
          .update({'status': status});

      return true;
    } catch (e) {
      print('Error updating SOS status: $e');
      return false;
    }
  }

  /// Archive SOS event (hide from main view)
  Future<bool> archiveSOSEvent(String userId, String sosId) async {
    try {
      await _firestore
          .collection('sosEvents')
          .doc(sosId)
          .update({'isArchived': true});

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sosHistory')
          .doc(sosId)
          .update({'isArchived': true});

      return true;
    } catch (e) {
      print('Error archiving SOS event: $e');
      return false;
    }
  }

  /// Unarchive SOS event (show in main view)
  Future<bool> unarchiveSOSEvent(String userId, String sosId) async {
    try {
      await _firestore
          .collection('sosEvents')
          .doc(sosId)
          .update({'isArchived': false});

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sosHistory')
          .doc(sosId)
          .update({'isArchived': false});

      return true;
    } catch (e) {
      print('Error unarchiving SOS event: $e');
      return false;
    }
  }
}
