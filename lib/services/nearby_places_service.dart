// lib/services/nearby_places_service.dart
// Fetches nearby vehicle-related places using Google Places API (Nearby Search).
// Categories: auto workshops, petrol/gas stations, towing services.

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../utils/google_maps_config.dart';

enum PlaceCategory {
  autoWorkshop,
  petrolBunk,
  towingService,
  carWash,
  sparePartShop,
}

class NearbyPlace {
  final String placeId;
  final String name;
  final double lat;
  final double lng;
  final PlaceCategory category;
  final double? rating;
  final bool isOpen;

  const NearbyPlace({
    required this.placeId,
    required this.name,
    required this.lat,
    required this.lng,
    required this.category,
    this.rating,
    this.isOpen = true,
  });
}

class NearbyPlacesService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  // Google Places types that match vehicle services
  static const Map<PlaceCategory, List<String>> _typesByCategory = {
    PlaceCategory.autoWorkshop: ['car_repair'],
    PlaceCategory.petrolBunk:   ['gas_station'],
    PlaceCategory.towingService: ['car_repair'],
    PlaceCategory.carWash:      ['car_wash'],
    PlaceCategory.sparePartShop: ['car_dealer'],
  };

  // Keywords to refine towing / spare parts results
  static const Map<PlaceCategory, String?> _keywordByCategory = {
    PlaceCategory.autoWorkshop: null,
    PlaceCategory.petrolBunk:   null,
    PlaceCategory.towingService: 'towing',
    PlaceCategory.carWash:      null,
    PlaceCategory.sparePartShop: 'spare parts',
  };

  /// Fetch all vehicle-related nearby places within [radiusMeters].
  static Future<List<NearbyPlace>> fetchAll({
    required double lat,
    required double lng,
    int radiusMeters = 1000,
  }) async {
    final results = <NearbyPlace>[];
    final seenIds = <String>{};

    for (final category in PlaceCategory.values) {
      try {
        final places = await _fetchCategory(
          lat: lat,
          lng: lng,
          category: category,
          radiusMeters: radiusMeters,
        );
        for (final p in places) {
          if (!seenIds.contains(p.placeId)) {
            seenIds.add(p.placeId);
            results.add(p);
          }
        }
      } catch (e) {
        developer.log(
          'NearbyPlaces fetch error for $category: $e',
          name: 'NearbyPlacesService',
        );
      }
    }

    developer.log(
      'Found ${results.length} nearby places',
      name: 'NearbyPlacesService',
    );
    return results;
  }

  static Future<List<NearbyPlace>> _fetchCategory({
    required double lat,
    required double lng,
    required PlaceCategory category,
    required int radiusMeters,
  }) async {
    final types = _typesByCategory[category]!;
    final keyword = _keywordByCategory[category];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'location': '$lat,$lng',
      'radius': radiusMeters.toString(),
      'type': types.first,
      if (keyword != null) 'keyword': keyword,
      'key': kGoogleMapsApiKey,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final status = json['status'] as String?;
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      developer.log(
        'Places API status: $status',
        name: 'NearbyPlacesService',
      );
      return [];
    }

    final items = json['results'] as List<dynamic>? ?? [];
    return items.map((item) {
      final geo = item['geometry']['location'];
      final openNow = item['opening_hours']?['open_now'] as bool? ?? true;
      return NearbyPlace(
        placeId: item['place_id'] as String,
        name: item['name'] as String,
        lat: (geo['lat'] as num).toDouble(),
        lng: (geo['lng'] as num).toDouble(),
        category: category,
        rating: (item['rating'] as num?)?.toDouble(),
        isOpen: openNow,
      );
    }).toList();
  }
}
