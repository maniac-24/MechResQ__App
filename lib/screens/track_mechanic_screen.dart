// lib/screens/track_mechanic_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/snackbar_helper.dart';
import '../utils/map_config.dart';
import '../services/routing_service.dart';
import '../widgets/request_status_chip.dart'; // RequestStatus enum
import 'user_mechanic_detail_screen.dart';
import 'chat_mechanic_screen.dart';
import 'bill_approval_screen.dart';
import '../l10n/app_localizations.dart';

/// ============================================================================
/// TRACK MECHANIC SCREEN — PRODUCTION REAL-TIME TRACKING
/// ============================================================================
class TrackMechanicScreen extends StatefulWidget {
  final String requestId;

  const TrackMechanicScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<TrackMechanicScreen> createState() => _TrackMechanicScreenState();
}

class _TrackMechanicScreenState extends State<TrackMechanicScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MapController _mapController = MapController();
  bool _mapReady = false;

  // Real-time route & ETA (Geoapify)
  RouteResult? _route;
  String? _etaText;
  double? _distanceKm;

  // Marker animation
  LatLng? _lastMechanicPos;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GEOAPIFY ROUTING — fetch route + ETA (free, no credit card)
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final result = await RoutingService.fetchRoute(
      originLat: origin.latitude,
      originLng: origin.longitude,
      destLat: destination.latitude,
      destLng: destination.longitude,
    );

    if (!mounted || result == null) return;

    setState(() {
      _route = result;
      _etaText = '${result.durationMinutes} min';
      _distanceKm = result.distanceKm;
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Smooth marker animation
  // ──────────────────────────────────────────────────────────────────────────
  void _animateMechanicMarker(LatLng newPos) {
    if (_lastMechanicPos == null) {
      setState(() => _lastMechanicPos = newPos);
      return;
    }

    const steps = 10;
    const duration = Duration(milliseconds: 100);
    int step = 0;

    Timer.periodic(duration, (timer) {
      if (step >= steps) {
        timer.cancel();
        return;
      }

      if (!mounted) {
        timer.cancel();
        return;
      }

      final lat = _lastMechanicPos!.latitude +
          (newPos.latitude - _lastMechanicPos!.latitude) * (step / steps);
      final lng = _lastMechanicPos!.longitude +
          (newPos.longitude - _lastMechanicPos!.longitude) * (step / steps);

      setState(() => _lastMechanicPos = LatLng(lat, lng));
      step++;
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Camera bounds to fit both markers (+ route)
  // ──────────────────────────────────────────────────────────────────────────
  void _fitBounds(LatLng userPos, LatLng mechanicPos) {
    if (!_mapReady) return;
    final pts = <LatLng>[
      userPos,
      mechanicPos,
      ...?_route?.points,
    ];
    final distinct = pts.toSet().toList();
    if (distinct.length < 2) {
      _mapController.move(userPos, 15);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: distinct,
        padding: const EdgeInsets.all(50),
        maxZoom: 16,
      ),
    );
  }

  /// Full-screen live map: route polyline + user & mechanic markers.
  Widget _buildMap(
      ColorScheme scheme, LatLng userPos, LatLng mechanicPos, bool hasLive) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: hasLive ? mechanicPos : userPos,
        initialZoom: 14,
        maxZoom: 18,
        minZoom: 3,
        onMapReady: () {
          _mapReady = true;
          if (hasLive) {
            _fitBounds(userPos, _lastMechanicPos ?? mechanicPos);
          } else {
            _mapController.move(userPos, 15);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: isMapConfigured ? kMapTileUrl : kOsmTileUrl,
          userAgentPackageName: 'com.aistudio.mechresq.mchras',
        ),
        if (hasLive && _route != null && _route!.points.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _route!.points,
                strokeWidth: 5,
                color: scheme.primary,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: userPos,
              width: 44,
              height: 44,
              child: const Icon(Icons.person_pin_circle,
                  color: Colors.blue, size: 40),
            ),
            if (hasLive)
              Marker(
                point: _lastMechanicPos ?? mechanicPos,
                width: 44,
                height: 44,
                child: const Icon(Icons.build_circle,
                    color: Colors.orange, size: 38),
              ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UI helpers
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _callMechanic(String phone) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      SnackBarHelper.showError(context, l10n.cannotLaunchDialer);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trackMechanic),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('requests').doc(widget.requestId).snapshots(),
        builder: (context, requestSnap) {
          // Loading
          if (requestSnap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: scheme.primary),
            );
          }

          // Error
          if (requestSnap.hasError ||
              !requestSnap.hasData ||
              !requestSnap.data!.exists) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: scheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.requestNotFound,
                    style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ),
            );
          }

          final reqData = requestSnap.data!.data() as Map<String, dynamic>;
          final status = parseRequestStatus(reqData['status'] as String?);
          final mechanicId = reqData['mechanicId'] as String?;
          final userLat = (reqData['userLat'] as num?)?.toDouble();
          final userLng = (reqData['userLng'] as num?)?.toDouble();
          final vehicleType = reqData['vehicleType'] as String? ?? 'Vehicle';
          final issue =
              reqData['issueDescription'] ?? reqData['issue'] ?? 'Issue not specified';
          final createdAt = (reqData['createdAt'] as Timestamp?)?.toDate();
          // Task 2: read billStatus to detect when mechanic submits final bill
          final billStatus = reqData['billStatus'] as String?;
          final billReady = billStatus == 'awaiting_payment';

          // No mechanic assigned yet
          if (mechanicId == null || mechanicId.isEmpty) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, color: scheme.tertiary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.waitingForMechanic,
                    style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ),
            );
          }

          // Invalid user location
          if (userLat == null || userLng == null) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Text(
                l10n.userLocationNotAvailable,
                style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
              ),
            );
          }

          final userPos = LatLng(userLat, userLng);

          // Nested: mechanic data stream
          return StreamBuilder<DocumentSnapshot>(
            stream: _db.collection('mechanics').doc(mechanicId).snapshots(),
            builder: (context, mechanicSnap) {
              if (mechanicSnap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                );
              }

              if (mechanicSnap.hasError ||
                  !mechanicSnap.hasData ||
                  !mechanicSnap.data!.exists) {
                final l10n = AppLocalizations.of(context)!;
                return Center(
                  child: Text(
                    l10n.mechanicDataNotFound,
                    style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
                  ),
                );
              }

              final mechData = mechanicSnap.data!.data() as Map<String, dynamic>;
              final mechanicName = mechData['name'] as String? ?? 'Mechanic';
              final phone = mechData['phone'] as String? ?? '';
              final liveLat = (mechData['liveLat'] as num?)?.toDouble();
              final liveLng = (mechData['liveLng'] as num?)?.toDouble();
              final lastUpdated =
                  (mechData['lastUpdated'] as Timestamp?)?.toDate();
              final rating = (mechData['rating'] as num?)?.toDouble() ?? 4.5;
              final totalReviews = mechData['totalReviews'] as int? ?? 0;

              final hasLive = liveLat != null && liveLng != null;
              // When the live location isn't available (e.g. the mechanic has
              // arrived and stopped sharing GPS), fall back to the customer's
              // own location so the map still renders instead of erroring out.
              final mechanicPos = (liveLat != null && liveLng != null)
                  ? LatLng(liveLat, liveLng)
                  : userPos;
              final l10n = AppLocalizations.of(context)!;

              // Offline detection (2 min threshold) — only meaningful if live.
              final now = DateTime.now();
              final isOffline = hasLive &&
                  (lastUpdated == null ||
                      now.difference(lastUpdated).inMinutes > 2);

              // Fetch route + animate the marker only when truly live.
              if (hasLive) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_lastMechanicPos == null ||
                      _lastMechanicPos!.latitude != mechanicPos.latitude ||
                      _lastMechanicPos!.longitude != mechanicPos.longitude) {
                    _animateMechanicMarker(mechanicPos);
                    _fetchRoute(origin: mechanicPos, destination: userPos);
                  }
                });
              }

              // UI LAYOUT — full-screen map + draggable info sheet
              return Stack(
                children: [
                  // ── Full-screen live map ─────────────────────────
                  Positioned.fill(
                    child: _buildMap(scheme, userPos, mechanicPos, hasLive),
                  ),

                  // ── Top overlay: timeline + offline banner ───────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // STATUS TIMELINE
                        _StatusTimeline(status: status, scheme: scheme),

                        // OFFLINE BANNER
                        if (isOffline)
                          Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: scheme.errorContainer,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.signal_wifi_off,
                              color: scheme.onErrorContainer,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.mechanicOffline,
                              style: TextStyle(
                                color: scheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                        // No-live-GPS banner (mechanic arrived / locating)
                        if (!hasLive)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            color: scheme.secondaryContainer,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  (status == RequestStatus.arrived ||
                                          status == RequestStatus.inProgress)
                                      ? Icons.check_circle
                                      : Icons.my_location,
                                  color: scheme.onSecondaryContainer,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    (status == RequestStatus.arrived ||
                                            status == RequestStatus.inProgress)
                                        ? 'Your mechanic has arrived'
                                        : 'Locating your mechanic...',
                                    style: TextStyle(
                                      color: scheme.onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                      ],
                    ),
                  ),

                  // ── Draggable info sheet ─────────────────────────
                  DraggableScrollableSheet(
                    initialChildSize: 0.42,
                    minChildSize: 0.16,
                    maxChildSize: 0.9,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: scheme.onSurface.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                    // ETA PILL
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_etaText != null && !isOffline)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: scheme.primary),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_alarm,
                                    size: 17,
                                    color: scheme.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ETA $_etaText',
                                    style: TextStyle(
                                      color: scheme.onPrimaryContainer,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_distanceKm != null)
                            Text(
                              '${_distanceKm!.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: scheme.onSurface.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // MECHANIC CARD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _MechanicCard(
                        name: mechanicName,
                        rating: rating,
                        totalReviews: totalReviews,
                        phone: phone,
                        isOnline: !isOffline,
                        scheme: scheme,
                        onTapProfile: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UserMechanicDetailScreen(mechanicId: mechanicId),
                            ),
                          );
                        },
                        onCall: () => _callMechanic(phone),
                      ),
                    ),

                    // REQUEST SUMMARY
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _SummaryCard(
                        requestId: widget.requestId,
                        vehicleType: vehicleType,
                        issue: issue,
                        createdAt: createdAt,
                        scheme: scheme,
                      ),
                    ),

                    // BILL-READY BANNER (Task 2)
                    // Shown when mechanic submits final bill
                    if (billReady)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _BillReadyBanner(
                          requestId: widget.requestId,
                          vehicleType: vehicleType,
                          issueDescription: issue is String ? issue : issue.toString(),
                          scheme: scheme,
                        ),
                      ),

                    // ACTION BUTTONS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _Actions(
                        canCancel: status == RequestStatus.accepted,
                        phone: phone,
                        mechanicId: mechanicId,
                        requestId: widget.requestId,
                        scheme: scheme,
                        onCall: () => _callMechanic(phone),
                        onChat: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatMechanicScreen(mechanicName: mechanicName),
                          ),
                        ),
                        onCancel: () => _showCancelDialog(),
                        onSOS: () {
                          SnackBarHelper.showWarning(
                            context,
                            l10n.sosCallInitiated,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  void _showCancelDialog() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: scheme.surface,
        title: Text(
          l10n.cancelRequest,
          style: TextStyle(color: scheme.onSurface),
        ),
        content: Text(
          l10n.cancelRequestMessage,
          style: TextStyle(color: scheme.onSurface.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _db.collection('requests').doc(widget.requestId).update({
                  'status': 'cancelled',
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (!mounted) return;
                SnackBarHelper.showSuccess(context, l10n.requestCancelled);
              } catch (e) {
                if (!mounted) return;
                final l10n = AppLocalizations.of(context)!;
                SnackBarHelper.showError(context, '${l10n.cancelRequest}: $e');
              }
            },
            child: Text(l10n.yesCancel),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// STATUS TIMELINE
// ══════════════════════════════════════════════════════════════════════════
class _StatusTimeline extends StatelessWidget {
  final RequestStatus status;
  final ColorScheme scheme;
  
  const _StatusTimeline({
    required this.status,
    required this.scheme,
  });

  static const _steps = [
    RequestStatus.accepted,
    RequestStatus.onTheWay,
    RequestStatus.completed,
  ];
  
  static const _icons = {
    RequestStatus.accepted: Icons.check_circle_outline,
    RequestStatus.onTheWay: Icons.two_wheeler,
    RequestStatus.completed: Icons.star,
  };

  @override
  Widget build(BuildContext context) {
    // Handle arrived as onTheWay for timeline display
    final displayStatus = status == RequestStatus.pending
        ? RequestStatus.accepted
        : status;
    
    final cur = _steps.indexOf(displayStatus).clamp(0, _steps.length - 1);
    final l10n = AppLocalizations.of(context)!;
    
    final labels = {
      RequestStatus.accepted: l10n.timelineAccepted,
      RequestStatus.onTheWay: l10n.timelineOnTheWay,
      RequestStatus.completed: l10n.timelineCompleted,
    };

    return Container(
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final done = i <= cur;
          final active = i == cur;

          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: active ? 44 : 34,
                      height: active ? 44 : 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? scheme.primaryContainer
                            : scheme.surfaceContainerHigh,
                      ),
                      child: Icon(
                        _icons[_steps[i]]!,
                        size: active ? 22 : 17,
                        color: done
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[_steps[i]]!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        color: done
                            ? scheme.onSurface
                            : scheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                if (i < _steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: i < cur
                            ? scheme.primary
                            : scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// MECHANIC CARD
// ══════════════════════════════════════════════════════════════════════════
class _MechanicCard extends StatelessWidget {
  final String name;
  final double rating;
  final int totalReviews;
  final String phone;
  final bool isOnline;
  final ColorScheme scheme;
  final VoidCallback onTapProfile;
  final VoidCallback onCall;

  const _MechanicCard({
    required this.name,
    required this.rating,
    required this.totalReviews,
    required this.phone,
    required this.isOnline,
    required this.scheme,
    required this.onTapProfile,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTapProfile,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      name.isNotEmpty ? name[0] : 'M',
                      style: TextStyle(
                        fontSize: 22,
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isOnline ? scheme.tertiary : scheme.outlineVariant,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.surfaceContainerHighest,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onTapProfile,
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 15, color: scheme.tertiary),
                      const SizedBox(width: 3),
                      Text(
                        '$rating ($totalReviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCall,
              icon: Icon(Icons.phone, color: scheme.primary, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// REQUEST SUMMARY
// ══════════════════════════════════════════════════════════════════════════
class _SummaryCard extends StatelessWidget {
  final String requestId;
  final String vehicleType;
  final String issue;
  final DateTime? createdAt;
  final ColorScheme scheme;

  const _SummaryCard({
    required this.requestId,
    required this.vehicleType,
    required this.issue,
    required this.createdAt,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = createdAt != null ? _fmt(createdAt!) : 'Unknown';

    return Card(
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_outlined, color: scheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Request Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _field('Request ID', requestId),
            _field('Vehicle', vehicleType),
            _field('Requested At', timeStr),
            _fieldMulti('Issue', issue),
          ],
        ),
      ),
    );
  }

  static String _fmt(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m $ap';
  }

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget _fieldMulti(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════
// ACTION BUTTONS
// ══════════════════════════════════════════════════════════════════════════
class _Actions extends StatelessWidget {
  final bool canCancel;
  final String phone;
  final String mechanicId;
  final String requestId;
  final ColorScheme scheme;
  final VoidCallback onCall, onChat, onCancel, onSOS;

  const _Actions({
    required this.canCancel,
    required this.phone,
    required this.mechanicId,
    required this.requestId,
    required this.scheme,
    required this.onCall,
    required this.onChat,
    required this.onCancel,
    required this.onSOS,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                context,
                Icons.phone,
                'Call',
                scheme.primaryContainer,
                scheme.onPrimaryContainer,
                onCall,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _btn(
                context,
                Icons.chat_bubble_outline,
                'Chat',
                scheme.secondaryContainer,
                scheme.onSecondaryContainer,
                onChat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (canCancel) ...[
              Expanded(
                child: _btn(
                  context,
                  Icons.cancel_outlined,
                  'Cancel',
                  scheme.surfaceContainerHigh,
                  scheme.onSurface,
                  onCancel,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: _btn(
                context,
                Icons.emergency,
                'SOS',
                scheme.errorContainer,
                scheme.onErrorContainer,
                onSOS,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _btn(
    BuildContext ctx,
    IconData icon,
    String label,
    Color bgColor,
    Color fgColor,
    VoidCallback onTap,
  ) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 0),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      );
}

// ══════════════════════════════════════════════════════════════════════════
// BILL-READY BANNER (Task 2)
// ══════════════════════════════════════════════════════════════════════════
class _BillReadyBanner extends StatelessWidget {
  final String requestId;
  final String vehicleType;
  final String issueDescription;
  final ColorScheme scheme;

  const _BillReadyBanner({
    required this.requestId,
    required this.vehicleType,
    required this.issueDescription,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BillApprovalScreen(
            requestId: requestId,
            vehicleType: vehicleType,
            issueDescription: issueDescription,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long,
                  color: scheme.onPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your mechanic has submitted the bill',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to review and approve before paying',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onPrimaryContainer.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
