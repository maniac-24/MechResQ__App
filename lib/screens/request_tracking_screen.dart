import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/request_tracking.dart';
import '../services/request_tracking_service.dart';

/// Request Tracking Screen
/// Shows real-time tracking with map, ETA, and timeline
class RequestTrackingScreen extends StatefulWidget {
  final String requestId;

  const RequestTrackingScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends State<RequestTrackingScreen> {
  final RequestTrackingService _trackingService = RequestTrackingService();
  
  GoogleMapController? _mapController;
  StreamSubscription<RequestTracking>? _trackingSubscription;
  Timer? _updateTimer;
  
  RequestTracking? _currentTracking;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  // Draggable sheet controller
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _trackingService.startActiveTracking(widget.requestId);
    
    _trackingSubscription = _trackingService
        .trackRequest(widget.requestId)
        .listen(_handleTrackingUpdate, onError: (error) {
      setState(() => _isLoading = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorTrackingRequest(error.toString()))),
      );
    });
    
    // Start periodic update timer (every 15 seconds)
    _updateTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_currentTracking?.canTrack == true) {
        // The stream will automatically fetch updated data
      }
    });
  }

  void _handleTrackingUpdate(RequestTracking tracking) {
    setState(() {
      _currentTracking = tracking;
      _isLoading = false;
      _updateMapMarkers(tracking);
    });

    // Auto-zoom map to fit markers
    if (_mapController != null && tracking.canTrack) {
      _fitMapToMarkers(tracking);
    }
  }

  void _updateMapMarkers(RequestTracking tracking) async {
    final markers = <Marker>{};
    final l10n = AppLocalizations.of(context)!;

    // User marker (blue)
    markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(tracking.userLatitude, tracking.userLongitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: l10n.yourLocation,
          snippet: tracking.userAddress ?? '',
        ),
      ),
    );

    // Mechanic marker (custom icon - for now using red, will add custom icon later)
    if (tracking.canTrack) {
      markers.add(
        Marker(
          markerId: const MarkerId('mechanic'),
          position: LatLng(tracking.mechanicLatitude!, tracking.mechanicLongitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: tracking.mechanicName ?? l10n.mechanicLabel,
            snippet: '${tracking.distanceDisplay} ${l10n.awayLabel}',
          ),
          // Rotation for direction (optional enhancement)
          flat: true,
        ),
      );

      // Draw SOLID BLUE LINE between user and mechanic
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(tracking.mechanicLatitude!, tracking.mechanicLongitude!),
            LatLng(tracking.userLatitude, tracking.userLongitude),
          ],
          color: Colors.blue.shade600,
          width: 4,
          // Remove dash pattern for solid line
        ),
      };
    }

    setState(() {
      _markers = markers;
    });
  }

  void _fitMapToMarkers(RequestTracking tracking) {
    if (!tracking.canTrack) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        tracking.userLatitude < tracking.mechanicLatitude!
            ? tracking.userLatitude
            : tracking.mechanicLatitude!,
        tracking.userLongitude < tracking.mechanicLongitude!
            ? tracking.userLongitude
            : tracking.mechanicLongitude!,
      ),
      northeast: LatLng(
        tracking.userLatitude > tracking.mechanicLatitude!
            ? tracking.userLatitude
            : tracking.mechanicLatitude!,
        tracking.userLongitude > tracking.mechanicLongitude!
            ? tracking.userLongitude
            : tracking.mechanicLongitude!,
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  Future<void> _callMechanic() async {
    if (_currentTracking?.mechanicPhone == null) return;

    final phone = _currentTracking!.mechanicPhone!;
    final uri = Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    _updateTimer?.cancel();
    _trackingService.stopActiveTracking();
    _mapController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trackRequest),
        actions: [
          if (_currentTracking?.mechanicPhone != null)
            IconButton(
              icon: const Icon(Icons.phone),
              tooltip: l10n.callMechanic,
              onPressed: _callMechanic,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: scheme.primary))
          : _currentTracking == null
              ? Center(child: Text(l10n.trackingNotAvailable))
              : Stack(
                  children: [
                    // Full-screen map
                    _buildMap(),

                    // Draggable bottom sheet with status info
                    DraggableScrollableSheet(
                      controller: _sheetController,
                      initialChildSize: 0.35, // Start at 35% of screen
                      minChildSize: 0.2, // Can collapse to 20%
                      maxChildSize: 0.75, // Can expand to 75%
                      builder: (context, scrollController) {
                        return _buildDraggableInfoSheet(scrollController);
                      },
                    ),
                  ],
                ),
    );
  }

  Widget _buildMap() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_currentTracking == null) {
      return Center(child: Text(l10n.loadingMap));
    }

    final initialPosition = LatLng(
      _currentTracking!.userLatitude,
      _currentTracking!.userLongitude,
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      padding: const EdgeInsets.only(bottom: 250), // Add padding for bottom sheet
      onMapCreated: (controller) {
        _mapController = controller;
        if (_currentTracking!.canTrack) {
          _fitMapToMarkers(_currentTracking!);
        }
      },
    );
  }

  Widget _buildDraggableInfoSheet(ScrollController scrollController) {
    final scheme = Theme.of(context).colorScheme;
    final tracking = _currentTracking!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  _buildStatusBadge(tracking),
                  const SizedBox(height: 16),

                  // Mechanic info (if assigned)
                  if (tracking.isMechanicAssigned) ...[
                    _buildMechanicInfo(tracking),
                    const SizedBox(height: 16),
                  ],

                  // ETA & Distance info
                  if (tracking.canTrack) ...[
                    _buildETAInfo(tracking),
                    const SizedBox(height: 16),
                  ],

                  // Timeline
                  Text(
                    l10n.statusTimeline,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTimeline(tracking),
                  
                  // Payment button based on status
                  const SizedBox(height: 20),
                  _buildPaymentButton(tracking),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RequestTracking tracking) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    IconData statusIcon;

    switch (tracking.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case RequestStatus.accepted:
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case RequestStatus.mechanicEnRoute:
        statusColor = Colors.purple;
        statusIcon = Icons.directions_car;
        break;
      case RequestStatus.mechanicNearby:
        statusColor = Colors.amber;
        statusIcon = Icons.location_on;
        break;
      case RequestStatus.mechanicArrived:
        statusColor = Colors.green;
        statusIcon = Icons.place;
        break;
      case RequestStatus.workInProgress:
        statusColor = Colors.indigo;
        statusIcon = Icons.build;
        break;
      case RequestStatus.completed:
        statusColor = Colors.teal;
        statusIcon = Icons.done_all;
        break;
      case RequestStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _localizeStatus(tracking.status, l10n),
              style: TextStyle(
                color: statusColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localizeStatus(RequestStatus status, AppLocalizations l10n) {
    switch (status) {
      case RequestStatus.pending:
        return l10n.pending;
      case RequestStatus.accepted:
        return l10n.accepted;
      case RequestStatus.mechanicEnRoute:
        return l10n.mechanicEnRoute;
      case RequestStatus.mechanicNearby:
        return l10n.mechanicNearby;
      case RequestStatus.mechanicArrived:
        return l10n.mechanicArrived;
      case RequestStatus.workInProgress:
        return l10n.workInProgress;
      case RequestStatus.completed:
        return l10n.completed;
      case RequestStatus.cancelled:
        return l10n.cancelled;
    }
  }

  Widget _buildMechanicInfo(RequestTracking tracking) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tracking.mechanicName ?? l10n.mechanicLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (tracking.mechanicPhone != null)
                  Text(
                    tracking.mechanicPhone!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                if (tracking.mechanicVehicleNumber != null)
                  Text(
                    '${l10n.vehicleLabel}: ${tracking.mechanicVehicleNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            color: Theme.of(context).colorScheme.primary,
            onPressed: _callMechanic,
          ),
        ],
      ),
    );
  }

  Widget _buildETAInfo(RequestTracking tracking) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.location_on,
            label: l10n.distance,
            value: tracking.distanceDisplay,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.access_time,
            label: l10n.eta,
            value: tracking.etaDisplay,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(RequestTracking tracking) {
    final l10n = AppLocalizations.of(context)!;
    final timelineItems = <Map<String, dynamic>>[];

    // Build timeline based on status
    timelineItems.add({
      'title': l10n.requestCreated,
      'time': tracking.createdAt,
      'completed': true,
    });

    if (tracking.acceptedAt != null) {
      timelineItems.add({
        'title': l10n.requestAccepted,
        'time': tracking.acceptedAt,
        'completed': true,
      });
    }

    timelineItems.add({
      'title': l10n.mechanicEnRoute,
      'completed': tracking.status.index >= RequestStatus.mechanicEnRoute.index,
    });

    timelineItems.add({
      'title': l10n.mechanicNearby,
      'completed': tracking.status.index >= RequestStatus.mechanicNearby.index,
    });

    if (tracking.arrivedAt != null) {
      timelineItems.add({
        'title': l10n.mechanicArrived,
        'time': tracking.arrivedAt,
        'completed': true,
      });
    } else {
      timelineItems.add({
        'title': l10n.mechanicArrived,
        'completed': tracking.status.index >= RequestStatus.mechanicArrived.index,
      });
    }

    timelineItems.add({
      'title': l10n.workInProgress,
      'completed': tracking.status.index >= RequestStatus.workInProgress.index,
    });

    if (tracking.completedAt != null) {
      timelineItems.add({
        'title': l10n.completed,
        'time': tracking.completedAt,
        'completed': true,
      });
    } else {
      timelineItems.add({
        'title': l10n.completed,
        'completed': tracking.status == RequestStatus.completed,
      });
    }

    return Column(
      children: timelineItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == timelineItems.length - 1;

        return _buildTimelineItem(
          title: item['title'],
          time: item['time'],
          completed: item['completed'],
          isLast: isLast,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    DateTime? time,
    required bool completed,
    required bool isLast,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final color = completed ? scheme.primary : scheme.onSurface.withValues(alpha: 0.3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? scheme.primary : Colors.transparent,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: completed
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: scheme.onPrimary,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: color,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
                    color: completed
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (time != null)
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return l10n.justNow;
    } else if (diff.inMinutes < 60) {
      return l10n.minAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      if (diff.inHours == 1) {
        return l10n.hourAgo(diff.inHours);
      } else {
        return l10n.hoursAgo(diff.inHours);
      }
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  // Payment button based on request status - REMOVED
  // Payment is now handled via Bill Screen after request creation
  Widget _buildPaymentButton(RequestTracking tracking) {
    return const SizedBox.shrink();
  }
}
