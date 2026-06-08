import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../utils/snackbar_helper.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // Launch phone dialer
  Future<void> _callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+91 98765 00000');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  // Launch email client
  Future<void> _emailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@mechresq.com',
      queryParameters: {
        'subject': 'MechResQ Support Request',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpSupportTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Card(
              color: scheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: scheme.primary, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.needHelp,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.helpDescription,
                          style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ================= QUICK ACTIONS =================
          Text(
            l10n.quickActions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _actionButton(
                context: context,
                icon: Icons.phone,
                label: l10n.callSupport,
                background: scheme.primaryContainer,
                foreground: scheme.onPrimaryContainer,
                onTap: () => _callSupport(),
              ),
              const SizedBox(width: 12),
              _actionButton(
                context: context,
                icon: Icons.email,
                label: l10n.emailUs,
                background: scheme.secondaryContainer,
                foreground: scheme.onSecondaryContainer,
                onTap: () => _emailSupport(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= FAQ =================
          Text(
            l10n.frequentlyAskedQuestions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          _faqTile(
            context,
            l10n.faqQuestion1,
            l10n.faqAnswer1,
            Icons.build,
          ),
          _faqTile(
            context,
            l10n.faqQuestion2,
            l10n.faqAnswer2,
            Icons.location_on,
          ),
          _faqTile(
            context,
            l10n.faqQuestion3,
            l10n.faqAnswer3,
            Icons.directions_car,
          ),
          _faqTile(
            context,
            l10n.faqQuestion4,
            l10n.faqAnswer4,
            Icons.emergency,
          ),
          _faqTile(
            context,
            l10n.faqQuestion5,
            l10n.faqAnswer5,
            Icons.payment,
          ),
          _faqTile(
            context,
            l10n.faqQuestion6,
            l10n.faqAnswer6,
            Icons.cancel,
          ),

          const SizedBox(height: 24),

          // ================= SAFETY TIPS =================
          Text(
            l10n.emergencySafety,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            color: scheme.errorContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.error),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: scheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Text(
                        l10n.safetyGuidelines,
                        style: TextStyle(
                          color: scheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.safetyTips,
                    style: TextStyle(
                      color: scheme.onErrorContainer.withOpacity(0.9),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ================= CONTACT INFO =================
          Text(
            l10n.contactInformation,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: scheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _contactTile(
                  context,
                  Icons.email,
                  l10n.emailSupport,
                  "support@mechresq.com",
                  () => _emailSupport(),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                _contactTile(
                  context,
                  Icons.phone,
                  l10n.phoneSupport,
                  "+91 98765 00000",
                  () => _callSupport(),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                _contactTile(
                  context,
                  Icons.access_time,
                  l10n.supportHours,
                  l10n.support24x7,
                  null,
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                _contactTile(
                  context,
                  Icons.location_on,
                  l10n.location,
                  l10n.locationIndia,
                  null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ================= SUBMIT TICKET =================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'support@mechresq.com',
                  queryParameters: {
                    'subject': 'MechResQ Support Ticket',
                    'body':
                        'Name: \n'
                        'Phone Number: \n'
                        'Issue Type: (e.g. Payment / App issue / Request issue / Other)\n'
                        'Description: \n\n'
                        'Please describe your issue in detail below:\n\n',
                  },
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (context.mounted) {
                    SnackBarHelper.showError(
                      context,
                      'Could not open email app. Please email support@mechresq.com directly.',
                    );
                  }
                }
              },
              icon: const Icon(Icons.support_agent),
              label: Text(
                l10n.submitSupportTicket,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ================= FOOTER =================
          Center(
            child: Column(
              children: [
                Text(
                  l10n.mechresqVersion,
                  style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.copyrightMechresq,
                  style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
      ),
    );
  }

  // ================= HELPERS =================

  static Widget _faqTile(
    BuildContext context,
    String q,
    String a,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      color: scheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: scheme.onSurface.withOpacity(0.7),
          size: 20,
        ),
        title: Text(
          q,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        iconColor: scheme.onSurface,
        collapsedIconColor: scheme.onSurface.withOpacity(0.7),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Text(
            a,
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          )
        ],
      ),
    );
  }

  static Widget _contactTile(
    BuildContext context,
    IconData icon,
    String title,
    String text,
    VoidCallback? onTap,
  ) {
    final scheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: scheme.onSurface.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
      subtitle: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: scheme.onSurface.withOpacity(0.4),
            )
          : null,
      onTap: onTap,
    );
  }

  static Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: foreground.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: foreground, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}