// lib/screens/live_tracking_map_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/request_tracking_location_service.dart';

/// Type-safe tracking status enum
enum TrackingStatus {
  onTheWay,
  arrived,
}

class LiveTrackingMapScreen extends StatefulWidget {
  final String requestId;
  final String mechanicName;
  final double initialDistanceKm;
  final int initialEtaMinutes;
  final TrackingStatus status;

  const LiveTrackingMapScreen({
    super.key,
    required this.requestId,
    required this.mechanicName,
    required this.initialDistanceKm,
    required this.initialEtaMinutes,
    this.status = TrackingStatus.onTheWay,
  });

  @override
  State<LiveTrackingMapScreen> createState() => _LiveTrackingMapScreenState();
}

class _LiveTrackingMapScreenState extends State<LiveTrackingMapScreen> {
  final RequestTrackingLocationService _locationService = RequestTrackingLocationService();
  
  StreamSubscription<RequestTrackingLocation?>? _locationSubscription;
  
  // Real-time values updated from Firestore
  double _distanceKm = 0;
  int _etaMinutes = 0;
  TrackingStatus _status = TrackingStatus.onTheWay;
  RequestTrackingLocation? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _distanceKm = widget.initialDistanceKm;
    _etaMinutes = widget.initialEtaMinutes;
    _status = widget.status;
    
    // Start streaming mechanic location from Firestore
    _startRealTimeTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  /// Start real-time location tracking using Firestore stream
  void _startRealTimeTracking() {
    _locationSubscription = _locationService
        .streamRequestTrackingLocation(widget.requestId)
        .listen(
      (trackingLocation) async {
        if (!mounted || trackingLocation == null) return;

        setState(() {
          _currentLocation = trackingLocation;
          _isLoading = false;
        });

        // Calculate distance and ETA
        final metrics = await _locationService.calculateMetrics(trackingLocation);

        // Check if mechanic has arrived
        final arrived = _locationService.hasArrived(trackingLocation);

        if (!mounted) return;

        setState(() {
          _distanceKm = metrics.distanceKm;
          _etaMinutes = metrics.etaMinutes;
          _status = arrived ? TrackingStatus.arrived : TrackingStatus.onTheWay;
        });
      },
      onError: (error) {
        print('❌ Location tracking error: $error');
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // transparent appBar so map bleeds underneath
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.scrim.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: scheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.scrim.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentLocation?.isOnTheWay == true) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                l10n.liveTracking,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── MAP PLACEHOLDER ─────────────────────────────────────────────
          // Replace this Container with:
          //   GoogleMap(
          //     onMapCreated: (controller) => _mapController = controller,
          //     initialCameraPosition: CameraPosition(target: LatLng(...), zoom: 14),
          //     markers: {userMarker, mechanicMarker},
          //     polylines: {routePolyline},
          //   )
          Positioned.fill(
            child: Container(
              color: scheme.surfaceContainerLowest,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      CircularProgressIndicator(color: scheme.primary)
                    else ...[
                      Icon(
                        Icons.map,
                        size: 64,
                        color: scheme.onSurface.withOpacity(0.16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.fullScreenLiveMap,
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.24),
                          fontSize: 15,
                        ),
                      ),
                      if (_currentLocation?.isStale == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Location updated ${_currentLocation?.getTimeSinceUpdate()}',
                          style: TextStyle(
                            color: scheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Demo pin positions (static) ─────────────────────────────────
          // User pin
          Positioned(
            top: 200,
            left: 80,
            child: _MapPin(
              icon: Icons.person_pin,
              color: scheme.secondaryContainer,
              foreground: scheme.onSecondaryContainer,
              label: l10n.you,
            ),
          ),
          // Mechanic pin
          Positioned(
            top: 140,
            right: 100,
            child: _MapPin(
              icon: Icons.directions_bike,
              color: scheme.primary,
              foreground: scheme.onPrimary,
              label: widget.mechanicName,
              isOnline: _currentLocation?.isOnTheWay ?? false,
            ),
          ),

          // ── Dashed route line (visual only) ─────────────────────────────
          Positioned(
            top: 150,
            left: 100,
            width: 200,
            height: 60,
            child: CustomPaint(
              painter: _DashedLinePainter(color: scheme.primary),
            ),
          ),

          // ── BOTTOM SHEET (ETA + status) ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomPanel(
              mechanicName: widget.mechanicName,
              distanceKm: _distanceKm,
              etaMinutes: _etaMinutes,
              status: _status,
              isOnline: _currentLocation?.isOnTheWay ?? false,
              lastUpdated: _currentLocation?.getTimeSinceUpdate(),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// MAP PIN
// ===========================================================================
class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color foreground;
  final String label;
  final bool isOnline;
  
  const _MapPin({
    required this.icon,
    required this.color,
    required this.foreground,
    required this.label,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.45),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(icon, size: 22, color: foreground),
            ),
            // Online indicator
            if (isOnline)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: scheme.scrim.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// DASHED ROUTE PAINTER  (decorative — real route uses GoogleMap polylines)
// ===========================================================================
class _DashedLinePainter extends CustomPainter {
  final Color color;
  
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const dashWidth = 10.0;
    const gapWidth = 6.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashWidth, size.height / 2),
        paint,
      );
      x += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===========================================================================
// BOTTOM PANEL
// ===========================================================================
class _BottomPanel extends StatelessWidget {
  final String mechanicName;
  final double distanceKm;
  final int etaMinutes;
  final TrackingStatus status;
  final bool isOnline;
  final String? lastUpdated;
  
  const _BottomPanel({
    required this.mechanicName,
    required this.distanceKm,
    required this.etaMinutes,
    required this.status,
    required this.isOnline,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final arrived = status == TrackingStatus.arrived;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Arrived banner ──────────────────────────────────────────────
          if (arrived)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.tertiary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: scheme.onTertiaryContainer,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.mechanicHasArrived,
                    style: TextStyle(
                      color: scheme.onTertiaryContainer,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // mechanic name row
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: scheme.primary,
                    child: Text(
                      mechanicName.isNotEmpty ? mechanicName[0] : 'M',
                      style: TextStyle(
                        fontSize: 18,
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Online indicator
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mechanicName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          arrived ? l10n.atYourLocation : l10n.onTheWayToYou,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (lastUpdated != null) ...[
                          Text(
                            ' • $lastUpdated',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // distance + eta chips
          if (!arrived)
            Row(
              children: [
                Expanded(
                  child: _statChip(
                    context,
                    Icons.route,
                    "${distanceKm.toStringAsFixed(1)} ${l10n.km}",
                    l10n.distance,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statChip(
                    context,
                    Icons.access_alarm,
                    "$etaMinutes ${l10n.minutes}",
                    l10n.eta,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static Widget _statChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final scheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}