import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Location Service
/// Handles location permissions, tracking, and address geocoding
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final StreamController<Position> _positionController = StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _positionController.stream;
  Position? get currentPosition => _currentPosition;

  // ═══════════════════════════════════════════
  // PERMISSIONS
  // ═══════════════════════════════════════════

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location permission status
  Future<LocationPermission> getPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permissions
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }

  /// Check if we have location permissions
  Future<bool> hasPermission() async {
    final permission = await getPermissionStatus();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  // ═══════════════════════════════════════════
  // LOCATION FETCHING
  // ═══════════════════════════════════════════

  /// Get current location (one-time)
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return null;
      }

      // Check permissions
      final hasPermissions = await hasPermission();
      if (!hasPermissions) {
        final permission = await requestPermission();
        if (permission == LocationPermission.denied || 
            permission == LocationPermission.deniedForever) {
          print('❌ Location permission denied');
          return null;
        }
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Current location: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      return _currentPosition;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  /// Start real-time location tracking
  Future<void> startTracking({
    int distanceFilter = 10, // meters
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      // Check permissions first
      final hasPermissions = await hasPermission();
      if (!hasPermissions) {
        final permission = await requestPermission();
        if (permission == LocationPermission.denied || 
            permission == LocationPermission.deniedForever) {
          print('❌ Cannot start tracking: Location permission denied');
          return;
        }
      }

      // Cancel existing subscription if any
      await stopTracking();

      // Start position stream
      final locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          _positionController.add(position);
          print('📍 Location updated: ${position.latitude}, ${position.longitude}');
        },
        onError: (error) {
          print('❌ Location tracking error: $error');
        },
      );

      print('✅ Location tracking started');
    } catch (e) {
      print('❌ Error starting location tracking: $e');
    }
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    print('🛑 Location tracking stopped');
  }

  // ═══════════════════════════════════════════
  // DISTANCE CALCULATIONS
  // ═══════════════════════════════════════════

  /// Calculate distance between two positions (in meters)
  double calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Calculate distance from current position to a target
  double? calculateDistanceFromCurrent({
    required double targetLat,
    required double targetLng,
  }) {
    if (_currentPosition == null) return null;

    return calculateDistance(
      startLat: _currentPosition!.latitude,
      startLng: _currentPosition!.longitude,
      endLat: targetLat,
      endLng: targetLng,
    );
  }

  // ═══════════════════════════════════════════
  // ETA CALCULATIONS
  // ═══════════════════════════════════════════

  /// Calculate estimated time of arrival (in minutes)
  /// Assumes average speed of 30 km/h in city traffic
  int calculateETA({
    required double distanceInMeters,
    double averageSpeedKmH = 30.0,
  }) {
    final distanceInKm = distanceInMeters / 1000;
    final hours = distanceInKm / averageSpeedKmH;
    final minutes = (hours * 60).ceil();
    return minutes;
  }

  /// Calculate ETA from current position to target
  int? calculateETAFromCurrent({
    required double targetLat,
    required double targetLng,
    double averageSpeedKmH = 30.0,
  }) {
    final distance = calculateDistanceFromCurrent(
      targetLat: targetLat,
      targetLng: targetLng,
    );

    if (distance == null) return null;

    return calculateETA(
      distanceInMeters: distance,
      averageSpeedKmH: averageSpeedKmH,
    );
  }

  // ═══════════════════════════════════════════
  // GEOCODING
  // ═══════════════════════════════════════════

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = <String>[];

      if (place.street != null && place.street!.isNotEmpty) {
        parts.add(place.street!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      }
      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        parts.add(place.administrativeArea!);
      }
      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        parts.add(place.postalCode!);
      }

      return parts.join(', ');
    } catch (e) {
      print('❌ Error getting address: $e');
      return null;
    }
  }

  /// Get current address
  Future<String?> getCurrentAddress() async {
    if (_currentPosition == null) {
      await getCurrentLocation();
    }

    if (_currentPosition == null) return null;

    return getAddressFromCoordinates(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
    );
  }

  /// Get coordinates from address (forward geocoding)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      
      if (locations.isEmpty) return null;

      final location = locations.first;
      return Position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    } catch (e) {
      print('❌ Error getting coordinates: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════
  // UTILITY
  // ═══════════════════════════════════════════

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
    _positionController.close();
  }
}
