import 'package:cloud_firestore/cloud_firestore.dart';

/// Vehicle Model
/// Represents a user's vehicle with details and image
class Vehicle {
  final String id;
  final String userId;
  final String name;
  final String type; // Car, Bike, Truck, Other
  final String make;
  final String model;
  final String year;
  final String licensePlate;
  final String? imageUrl;
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.imageUrl,
    required this.createdAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore Map
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'Car',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Display name (e.g., "2020 Honda Civic")
  String get displayName => '$year $make $model';

  // Vehicle type icon helper
  String get typeEmoji {
    switch (type.toLowerCase()) {
      case 'car':
        return '🚗';
      case 'bike':
      case 'motorcycle':
        return '🏍️';
      case 'truck':
        return '🚛';
      default:
        return '🚙';
    }
  }
}
