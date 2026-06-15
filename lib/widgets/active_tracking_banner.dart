import 'package:flutter/material.dart';
import '../models/request_tracking.dart';
import '../screens/track_mechanic_screen.dart';

/// Active Tracking Banner Widget
/// Shows a prominent banner for active requests with real-time updates
class ActiveTrackingBanner extends StatelessWidget {
  final RequestTracking tracking;

  const ActiveTrackingBanner({
    super.key,
    required this.tracking,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (tracking.status) {
      case RequestStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusMessage = 'Waiting for mechanic to accept...';
        break;
      case RequestStatus.accepted:
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        statusMessage = 'Mechanic accepted your request!';
        break;
      case RequestStatus.mechanicEnRoute:
        statusColor = Colors.purple;
        statusIcon = Icons.directions_car;
        statusMessage = 'Mechanic is on the way';
        break;
      case RequestStatus.mechanicNearby:
        statusColor = Colors.amber;
        statusIcon = Icons.location_on;
        statusMessage = 'Mechanic is nearby!';
        break;
      case RequestStatus.mechanicArrived:
        statusColor = Colors.green;
        statusIcon = Icons.place;
        statusMessage = 'Mechanic has arrived';
        break;
      case RequestStatus.workInProgress:
        statusColor = Colors.indigo;
        statusIcon = Icons.build;
        statusMessage = 'Work in progress';
        break;
      case RequestStatus.completed:
        statusColor = Colors.teal;
        statusIcon = Icons.done_all;
        statusMessage = 'Service completed';
        break;
      case RequestStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusMessage = 'Request cancelled';
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackMechanicScreen(requestId: tracking.requestId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.8),
              statusColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(statusIcon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tracking.statusDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.circle, color: Colors.white, size: 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status message
            Text(
              statusMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),

            // Mechanic info & ETA (if available)
            if (tracking.isMechanicAssigned) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white30, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Mechanic name
                  Expanded(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.black87, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tracking.mechanicName ?? 'Mechanic',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (tracking.mechanicVehicleNumber != null)
                                Text(
                                  tracking.mechanicVehicleNumber!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Distance & ETA
                  if (tracking.canTrack) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, 
                                color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                tracking.distanceDisplay,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time, 
                                color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                tracking.etaDisplay,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],

            // Track button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackMechanicScreen(
                        requestId: tracking.requestId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Track on Map',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
