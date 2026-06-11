import 'package:cloud_firestore/cloud_firestore.dart';

/// Vehicle Model
/// Represents a user's vehicle with details and image
class Vehicle {
  final String id;
  final String userId;
  final String name;
  final String type;       // Car, Bike, Truck, Other, or custom
  final String make;       // Brand/Company (e.g., Tata, Toyota)
  final String model;
  final String year;
  final String licensePlate;
  final String? fuelType;  // Petrol, Diesel, CNG, Electric
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
    this.fuelType,
    this.imageUrl,
    required this.createdAt,
  });

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
      'fuelType': fuelType,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

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
      fuelType: map['fuelType'],
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
