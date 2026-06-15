import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/snackbar_helper.dart';

class MechanicDetailScreen extends StatelessWidget {
  final Map<String, String> mechanic;

  const MechanicDetailScreen({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    
    final name = (mechanic['name'] ?? 'Mechanic').trim();
    final shop = (mechanic['shopName'] ?? 'Garage / Workshop').trim();

    final services = (mechanic['serviceTypes']?.trim().isNotEmpty ?? false)
        ? mechanic['serviceTypes']!.trim()
        : (mechanic['vehicleTypes'] ?? 'General Repair').trim();

    final rating = (mechanic['rating'] ?? '4.5').trim();
    final distance = (mechanic['distanceKm'] ?? '0.0').trim();

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ HEADER CARD
            Card(
              color: scheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: scheme.primary,
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 15,
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: scheme.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "$rating • $distance km",
                                style: TextStyle(
                                  color: scheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ✅ SERVICES
            Text(
              l10n.servicesOffered,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              services.isNotEmpty
                  ? services
                  : l10n.generalVehicleRepairServices,
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 18),

            // ✅ CONTACT
            Text(
              l10n.contactDetails,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: scheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Phone number is shared after the mechanic accepts '
                      'your request. Create a request to get connected.',
                      style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ✅ ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(l10n.createRequest),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/create_request',
                        arguments: mechanic,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: Text(l10n.share),
                  onPressed: () {
                    SnackBarHelper.showInfo(
                      context,
                      l10n.shareFeatureComingSoon,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ NOTES
            Text(
              l10n.notes,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "• ${l10n.confirmServiceCharges}\n"
              "• ${l10n.paymentOptions}\n"
              "• ${l10n.verifyMechanicIdentity}",
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}