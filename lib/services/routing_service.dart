import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../utils/map_config.dart';

/// Result of a routing request (open-source replacement for Google Directions).
class RouteResult {
  final List<LatLng> points; // polyline geometry
  final double distanceKm;
  final int durationMinutes;

  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
  });

  String get distanceText => '${distanceKm.toStringAsFixed(1)} km';
  String get durationText => '$durationMinutes min';
}

/// ============================================================
/// ROUTING SERVICE — Geoapify (free, no credit card)
/// ============================================================
/// Fetches a driving route between two points and returns the
/// polyline, distance, and ETA. Replaces the Google Directions API.
/// Mirrors the mechanic app's RoutingService so both stay in sync.
/// ============================================================
class RoutingService {
  /// Fetch a driving route from origin to destination.
  /// Falls back to a straight line if the request fails or the key is missing.
  static Future<RouteResult?> fetchRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    if (!isMapConfigured) {
      debugPrint('RoutingService: Geoapify key not configured.');
      return _straightLineFallback(originLat, originLng, destLat, destLng);
    }

    final url = Uri.parse(
      '$kGeoapifyRoutingBase'
      '?waypoints=$originLat,$originLng|$destLat,$destLng'
      '&mode=drive'
      '&apiKey=$kGeoapifyApiKey',
    );

    try {
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        debugPrint('RoutingService: HTTP ${res.statusCode} — ${res.body}');
        return _straightLineFallback(originLat, originLng, destLat, destLng);
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final features = data['features'] as List?;
      if (features == null || features.isEmpty) {
        return _straightLineFallback(originLat, originLng, destLat, destLng);
      }

      final feature = features.first as Map<String, dynamic>;
      final props = feature['properties'] as Map<String, dynamic>;
      final distanceM = (props['distance'] as num?)?.toDouble() ?? 0;
      final timeS = (props['time'] as num?)?.toDouble() ?? 0;

      // Geometry: Geoapify returns MultiLineString coordinates [lng, lat]
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final coords = geometry['coordinates'] as List;
      final points = <LatLng>[];

      for (final seg in coords) {
        if (seg is List) {
          for (final pt in seg) {
            if (pt is List && pt.length >= 2) {
              points.add(LatLng(
                (pt[1] as num).toDouble(),
                (pt[0] as num).toDouble(),
              ));
            }
          }
        }
      }

      if (points.isEmpty) {
        return _straightLineFallback(originLat, originLng, destLat, destLng);
      }

      return RouteResult(
        points: points,
        distanceKm: distanceM / 1000.0,
        durationMinutes: (timeS / 60).ceil(),
      );
    } catch (e) {
      debugPrint('RoutingService error: $e');
      return _straightLineFallback(originLat, originLng, destLat, destLng);
    }
  }

  /// When routing is unavailable, draw a straight line and estimate
  /// distance/ETA so the UI still renders something useful.
  static RouteResult _straightLineFallback(
      double oLat, double oLng, double dLat, double dLng) {
    final meters = const Distance().as(
      LengthUnit.Meter,
      LatLng(oLat, oLng),
      LatLng(dLat, dLng),
    );
    final km = meters / 1000.0;
    // Assume ~25 km/h average city speed for a rough ETA.
    final minutes = ((km / 25) * 60).ceil();
    return RouteResult(
      points: [LatLng(oLat, oLng), LatLng(dLat, dLng)],
      distanceKm: km,
      durationMinutes: minutes,
    );
  }
}
