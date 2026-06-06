import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/vehicle.dart';

/// Vehicle Service - Handles all vehicle operations
/// Stores vehicles in Firestore, images in Firebase Storage
class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ═══════════════════════════════════════════
  // ADD VEHICLE
  // ═══════════════════════════════════════════

  /// Add a new vehicle for a user
  Future<String?> addVehicle({
    required String userId,
    required String name,
    required String type,
    required String make,
    required String model,
    required String year,
    required String licensePlate,
    File? imageFile,
  }) async {
    try {
      final vehicleId = _firestore.collection('vehicles').doc().id;
      
      print('🚗 Adding vehicle: $vehicleId');
      print('📁 Image file provided: ${imageFile != null}');
      if (imageFile != null) {
        print('📁 Image path: ${imageFile.path}');
      }

      // Upload image to Firebase Storage if provided
      String? imageUrl;
      if (imageFile != null) {
        print('⬆️ Starting image upload...');
        imageUrl = await _uploadImage(userId, vehicleId, imageFile);
        print('✅ Image URL: $imageUrl');
      }

      final vehicle = Vehicle(
        id: vehicleId,
        userId: userId,
        name: name,
        type: type,
        make: make,
        model: model,
        year: year,
        licensePlate: licensePlate,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );
      
      print('💾 Saving to Firestore with imageUrl: $imageUrl');

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .set(vehicle.toMap());
      
      print('✅ Vehicle saved successfully');

      return vehicleId;
    } catch (e) {
      print('❌ Error adding vehicle: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════
  // UPDATE VEHICLE
  // ═══════════════════════════════════════════

  /// Update existing vehicle
  Future<bool> updateVehicle({
    required String userId,
    required String vehicleId,
    String? name,
    String? type,
    String? make,
    String? model,
    String? year,
    String? licensePlate,
    File? imageFile,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (type != null) updates['type'] = type;
      if (make != null) updates['make'] = make;
      if (model != null) updates['model'] = model;
      if (year != null) updates['year'] = year;
      if (licensePlate != null) updates['licensePlate'] = licensePlate;

      // Upload new image if provided
      if (imageFile != null) {
        final imageUrl = await _uploadImage(userId, vehicleId, imageFile);
        if (imageUrl != null) {
          updates['imageUrl'] = imageUrl;
        }
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('vehicles')
            .doc(vehicleId)
            .update(updates);
      }

      return true;
    } catch (e) {
      print('Error updating vehicle: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // DELETE VEHICLE
  // ═══════════════════════════════════════════

  /// Delete a vehicle and its image
  Future<bool> deleteVehicle(String userId, String vehicleId) async {
    try {
      // Delete image from Storage
      await _deleteImage(userId, vehicleId);

      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting vehicle: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // GET VEHICLES
  // ═══════════════════════════════════════════

  /// Get all vehicles for a user
  Future<List<Vehicle>> getVehicles(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Vehicle.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting vehicles: $e');
      return [];
    }
  }

  /// Get vehicles as stream (real-time)
  Stream<List<Vehicle>> getVehiclesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList());
  }

  /// Get single vehicle
  Future<Vehicle?> getVehicle(String userId, String vehicleId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .get();

      if (doc.exists) {
        return Vehicle.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting vehicle: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════
  // FIREBASE STORAGE - IMAGE OPERATIONS
  // ═══════════════════════════════════════════

  /// Upload image to Firebase Storage
  Future<String?> _uploadImage(
      String userId, String vehicleId, File imageFile) async {
    try {
      print('📤 Uploading to: vehicles/$userId/$vehicleId.jpg');
      
      final ref = _storage
          .ref()
          .child('vehicles')
          .child(userId)
          .child('$vehicleId.jpg');

      print('⏳ Uploading file...');
      final uploadTask = await ref.putFile(imageFile);
      
      print('🔗 Getting download URL...');
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      print('✅ Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  Future<void> _deleteImage(String userId, String vehicleId) async {
    try {
      final ref = _storage
          .ref()
          .child('vehicles')
          .child(userId)
          .child('$vehicleId.jpg');

      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw - image might not exist
    }
  }
}
