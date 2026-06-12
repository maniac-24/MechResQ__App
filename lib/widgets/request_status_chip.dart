import 'package:flutter/material.dart';

/// Type-safe request status enum aligned with the shared `requests`
/// Firestore schema used by BOTH the user app and the mechanic app.
///
/// Unified flow:
///   pending → accepted → onTheWay → arrived → inProgress → completed
///   (cancelled can occur at any point)
enum RequestStatus {
  pending,
  accepted,
  onTheWay,
  arrived,
  inProgress,
  completed,
  cancelled,
}

/// Extensions for RequestStatus enum
extension RequestStatusExtension on RequestStatus {
  /// Display label for UI
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'PENDING';
      case RequestStatus.accepted:
        return 'ACCEPTED';
      case RequestStatus.onTheWay:
        return 'ON THE WAY';
      case RequestStatus.arrived:
        return 'ARRIVED';
      case RequestStatus.inProgress:
        return 'IN PROGRESS';
      case RequestStatus.completed:
        return 'COMPLETED';
      case RequestStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Check if request is still active (trackable/cancellable)
  bool get isActive {
    return this == RequestStatus.pending ||
        this == RequestStatus.accepted ||
        this == RequestStatus.onTheWay ||
        this == RequestStatus.arrived ||
        this == RequestStatus.inProgress;
  }

  /// Check if request can be tracked (mechanic assigned and moving/working)
  bool get isTrackable {
    return this == RequestStatus.accepted ||
        this == RequestStatus.onTheWay ||
        this == RequestStatus.arrived ||
        this == RequestStatus.inProgress;
  }

  /// Check if request can be cancelled
  bool get isCancellable {
    return this == RequestStatus.pending || this == RequestStatus.accepted;
  }

  /// Get semantic color from ColorScheme
  Color getColor(ColorScheme scheme) {
    switch (this) {
      case RequestStatus.accepted:
        return scheme.primary;
      case RequestStatus.onTheWay:
        return scheme.tertiary;
      case RequestStatus.arrived:
        return scheme.tertiary;
      case RequestStatus.inProgress:
        return scheme.secondary;
      case RequestStatus.completed:
        return scheme.secondary;
      case RequestStatus.cancelled:
        return scheme.error;
      case RequestStatus.pending:
        return scheme.outline;
    }
  }
}

/// Parse Firestore status string to enum.
/// Accepts the unified snake_case scheme plus a few legacy variants
/// so older requests still display correctly.
RequestStatus parseRequestStatus(String? status) {
  final normalized = status?.toLowerCase().replaceAll(' ', '_');

  switch (normalized) {
    case 'accepted':
      return RequestStatus.accepted;
    case 'on_the_way':
    case 'ontheway':
    case 'mechanic_en_route':
    case 'mechanicenroute':
      return RequestStatus.onTheWay;
    case 'arrived':
    case 'mechanic_arrived':
    case 'mechanicarrived':
      return RequestStatus.arrived;
    case 'in_progress':
    case 'inprogress':
    case 'work_in_progress':
    case 'workinprogress':
    case 'in_progress_started': // legacy
    case 'in_progress_ongoing': // legacy
      return RequestStatus.inProgress;
    case 'completed':
      return RequestStatus.completed;
    case 'cancelled':
    case 'canceled':
      return RequestStatus.cancelled;
    default:
      return RequestStatus.pending;
  }
}

/// Reusable status chip widget with Material 3 theming
class RequestStatusChip extends StatelessWidget {
  final RequestStatus status;
  final double fontSize;

  const RequestStatusChip({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = status.getColor(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
