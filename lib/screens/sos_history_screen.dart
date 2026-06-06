import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/sos_event.dart';
import '../services/sos_service.dart';
import '../l10n/app_localizations.dart';

/// SOS History Screen
/// Shows all past SOS activations
class SOSHistoryScreen extends StatefulWidget {
  const SOSHistoryScreen({super.key});

  @override
  State<SOSHistoryScreen> createState() => _SOSHistoryScreenState();
}

class _SOSHistoryScreenState extends State<SOSHistoryScreen> {
  final SOSService _sosService = SOSService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _showArchived = false; // Toggle for showing archived events

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sosHistory),
        backgroundColor: scheme.surface,
        actions: [
          // Toggle for showing archived events
          IconButton(
            icon: Icon(_showArchived ? Icons.archive : Icons.archive_outlined),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
            tooltip: _showArchived ? l10n.hideArchived : l10n.showArchived,
          ),
        ],
      ),
      body: StreamBuilder<List<SOSEvent>>(
        stream: _sosService.getSOSHistoryStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: scheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingHistory,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final events = snapshot.data ?? [];

          // Filter events based on archive toggle
          final filteredEvents = events.where((event) {
            if (_showArchived) {
              return event.isArchived; // Show only archived
            } else {
              return !event.isArchived; // Show only active
            }
          }).toList();

          if (filteredEvents.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              return _buildEventCard(context, filteredEvents[index]);
            },
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════
  // UI COMPONENTS
  // ═══════════════════════════════════════════

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: scheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              _showArchived ? l10n.noArchivedEvents : l10n.noSosHistory,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _showArchived
                  ? l10n.archivedEventsMessage
                  : l10n.sosHistoryMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, SOSEvent event) {
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    // Color based on status
    Color statusColor;
    switch (event.status) {
      case 'responded':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.orange;
        break;
      case 'resolved':
        statusColor = scheme.primary;
        break;
      default:
        statusColor = scheme.secondary;
    }

    return Opacity(
      opacity: event.isArchived ? 0.5 : 1.0, // Grayed out if archived
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: InkWell(
          onTap: () => _showEventDetails(context, event),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.statusEmoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          event.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: scheme.onSurface.withOpacity(0.3),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date and time
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(event.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats
              Row(
                children: [
                  _buildStatChip(
                    context,
                    Icons.contacts,
                    '${event.contactsNotified.length} ${AppLocalizations.of(context)!.contacted}',
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.build,
                    '${event.mechanicsAlerted} ${AppLocalizations.of(context)!.alerted}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: scheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // EVENT DETAILS DIALOG
  // ═══════════════════════════════════════════

  void _showEventDetails(BuildContext context, SOSEvent event) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emergency, color: scheme.error),
                        const SizedBox(width: 12),
                        Text(
                          l10n.sosEventDetails,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildDetailRow(
                          context,
                          l10n.status,
                          '${event.statusEmoji} ${event.status.toUpperCase()}',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          l10n.emergencyType,
                          '${event.emergencyTypeEmoji} ${event.emergencyTypeDisplay}',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          l10n.dateAndTime,
                          dateFormat.format(event.timestamp),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          l10n.currentLocation,
                          event.location,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          l10n.coordinates,
                          '${event.latitude.toStringAsFixed(6)}, ${event.longitude.toStringAsFixed(6)}',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          l10n.contactsNotifiedLabel,
                          '${event.contactsNotified.length} ${l10n.emergencyContacts.toLowerCase()}',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          l10n.mechanicsAlertedLabel,
                          '${event.mechanicsAlerted} ${l10n.mechanicsNearby.toLowerCase()}',
                        ),
                        if (event.respondedBy != null) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            context,
                            l10n.respondedBy,
                            event.respondedBy!,
                          ),
                        ],
                        if (event.notes != null && event.notes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            context,
                            l10n.notes,
                            event.notes!,
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Action buttons
                        ElevatedButton.icon(
                          onPressed: () => _openInMaps(event.mapsLink),
                          icon: const Icon(Icons.map),
                          label: Text(l10n.viewOnGoogleMaps),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Archive/Unarchive button
                        OutlinedButton.icon(
                          onPressed: () => _toggleArchive(context, event),
                          icon: Icon(
                            event.isArchived ? Icons.unarchive : Icons.archive,
                          ),
                          label: Text(
                            event.isArchived ? l10n.unarchiveEvent : l10n.archiveEvent,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            foregroundColor: event.isArchived
                                ? scheme.primary
                                : scheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════

  Future<void> _openInMaps(String mapsLink) async {
    final uri = Uri.parse(mapsLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _toggleArchive(BuildContext context, SOSEvent event) async {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.isArchived ? l10n.unarchiveEvent : l10n.archiveEvent),
        content: Text(
          event.isArchived
              ? l10n.unarchiveEventConfirm
              : l10n.archiveEventConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: event.isArchived ? scheme.primary : scheme.secondary,
            ),
            child: Text(event.isArchived ? l10n.unarchiveEvent : l10n.archiveEvent),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Perform archive/unarchive
    final success = event.isArchived
        ? await _sosService.unarchiveSOSEvent(userId, event.id)
        : await _sosService.archiveSOSEvent(userId, event.id);

    if (!context.mounted) return;

    final l10nAfter = AppLocalizations.of(context)!;

    if (success) {
      // Close the details modal
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            event.isArchived ? l10nAfter.eventUnarchived : l10nAfter.eventArchived,
          ),
          backgroundColor: scheme.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${event.isArchived ? l10nAfter.failedToUnarchive : l10nAfter.failedToArchive}',
          ),
          backgroundColor: scheme.error,
        ),
      );
    }
  }
}
