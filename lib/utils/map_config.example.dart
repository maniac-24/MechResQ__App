/// ============================================================
/// MAP CONFIG TEMPLATE (Geoapify — free, no credit card)
/// ============================================================
/// 1. Copy this file to map_config.dart (same folder).
/// 2. Sign up at https://www.geoapify.com (no card required).
/// 3. Create a project and paste your API key below.
///
/// Free tier: 3,000 requests/day across maps, routing, and geocoding.
/// map_config.dart is gitignored — only this template is committed.
/// ============================================================
library;

/// Your Geoapify API key.
const String kGeoapifyApiKey = 'YOUR_GEOAPIFY_KEY';

/// Raster tile URL template for flutter_map.
/// Styles: osm-bright, osm-carto, dark-matter, positron, klokantech-basic
const String _kMapStyle = 'osm-bright';

String get kMapTileUrl =>
    'https://maps.geoapify.com/v1/tile/$_kMapStyle/{z}/{x}/{y}.png?apiKey=$kGeoapifyApiKey';

/// Fallback: plain OpenStreetMap tiles (no key) — useful before a key is set.
const String kOsmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Geoapify routing endpoint base.
const String kGeoapifyRoutingBase = 'https://api.geoapify.com/v1/routing';

bool get isMapConfigured => kGeoapifyApiKey != 'YOUR_GEOAPIFY_KEY';
