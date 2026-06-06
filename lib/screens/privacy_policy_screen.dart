import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              l10n.mechresqPrivacyPolicy,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.lastUpdated('June 2, 2026'),
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            _buildSection(
              context,
              title: '1. Introduction',
              content:
                  'MechResQ ("we", "us", or "our") is committed to protecting your privacy. This Privacy Policy explains '
                  'how we collect, use, disclose, and safeguard your personal information when you use our mobile application.\n\n'
                  'By using MechResQ, you consent to the data practices described in this policy. If you do not agree with '
                  'this policy, please do not use our App.',
            ),

            _buildSection(
              context,
              title: '2. Information We Collect',
              content:
                  'We collect several types of information to provide and improve our services:\n\n'
                  'A. Information You Provide:\n'
                  '• Name, phone number, and email address during registration\n'
                  '• Vehicle information (make, model, year, registration number)\n'
                  '• Payment information (processed securely by our payment partners)\n'
                  '• Photos and videos you upload for service requests\n'
                  '• Chat messages with mechanics\n'
                  '• Ratings and reviews you submit\n\n'
                  'B. Information Collected Automatically:\n'
                  '• Location data (GPS coordinates when using the app)\n'
                  '• Device information (model, OS version, unique identifiers)\n'
                  '• App usage data (features used, time spent, interactions)\n'
                  '• Log data (IP address, crashes, system activity)\n'
                  '• Camera and storage access (with your permission)',
            ),

            _buildSection(
              context,
              title: '3. How We Use Your Information',
              content:
                  'We use collected information for the following purposes:\n\n'
                  '• Service Delivery: Connect you with mechanics and facilitate service requests\n'
                  '• Location Services: Show nearby mechanics and enable real-time tracking\n'
                  '• Communication: Send notifications about request status and app updates\n'
                  '• Payment Processing: Facilitate secure transactions\n'
                  '• Customer Support: Respond to inquiries and resolve issues\n'
                  '• App Improvement: Analyze usage patterns to enhance features\n'
                  '• Safety & Security: Detect fraud, prevent abuse, ensure platform integrity\n'
                  '• Legal Compliance: Meet regulatory requirements and enforce our Terms\n'
                  '• Personalization: Provide relevant recommendations and content',
            ),

            _buildSection(
              context,
              title: '4. Information Sharing and Disclosure',
              content:
                  'We may share your information in the following circumstances:\n\n'
                  'A. With Mechanics:\n'
                  '• Name, phone number, and location when you request service\n'
                  '• Vehicle information relevant to the service\n'
                  '• Chat messages and service request details\n\n'
                  'B. With Service Providers:\n'
                  '• Payment processors (Razorpay, PhonePe, etc.)\n'
                  '• Cloud storage providers (Firebase, AWS)\n'
                  '• Analytics services (Firebase Analytics)\n'
                  '• Customer support tools\n\n'
                  'C. For Legal Reasons:\n'
                  '• To comply with legal obligations or court orders\n'
                  '• To protect our rights, property, or safety\n'
                  '• To prevent fraud or illegal activities\n'
                  '• In connection with legal proceedings\n\n'
                  'D. Business Transfers:\n'
                  '• In case of merger, acquisition, or sale of assets\n\n'
                  'We do not sell your personal data to third parties for marketing purposes.',
            ),

            _buildSection(
              context,
              title: '5. Data Security',
              content:
                  'We implement security measures to protect your information:\n\n'
                  '• Encryption of data in transit (SSL/TLS)\n'
                  '• Secure storage using industry-standard practices\n'
                  '• Access controls limiting who can view your data\n'
                  '• Regular security audits and updates\n'
                  '• Secure payment processing through PCI-DSS compliant partners\n\n'
                  'However, no method of transmission or storage is 100% secure. While we strive to protect '
                  'your data, we cannot guarantee absolute security.',
            ),

            _buildSection(
              context,
              title: '6. Your Rights and Choices',
              content:
                  'You have the following rights regarding your personal data:\n\n'
                  'A. Access & Portability:\n'
                  '• Request a copy of your personal data\n'
                  '• Export your data in a machine-readable format\n\n'
                  'B. Correction:\n'
                  '• Update or correct inaccurate information in your profile\n\n'
                  'C. Deletion:\n'
                  '• Request deletion of your account and associated data\n'
                  '• Some data may be retained for legal or legitimate business purposes\n\n'
                  'D. Opt-Out:\n'
                  '• Disable location services (limits app functionality)\n'
                  '• Turn off push notifications in settings\n'
                  '• Withdraw consent for marketing communications\n\n'
                  'E. Restriction:\n'
                  '• Request limitation of processing in certain circumstances\n\n'
                  'To exercise these rights, contact us at privacy@mechresq.com',
            ),

            _buildSection(
              context,
              title: '7. Location Data',
              content:
                  'Location data is essential for MechResQ to function:\n\n'
                  '• We collect precise location when you use the app\n'
                  '• Location helps us show nearby mechanics and enable tracking\n'
                  '• You can disable location services, but core features won\'t work\n'
                  '• Location data is shared with selected mechanics during active requests\n'
                  '• We do not track your location when the app is closed (unless tracking an active service)\n'
                  '• Location history is retained for service records and dispute resolution',
            ),

            _buildSection(
              context,
              title: '8. Children\'s Privacy',
              content:
                  'MechResQ is not intended for users under 18 years of age:\n\n'
                  '• We do not knowingly collect data from children\n'
                  '• If we discover we have collected data from a child, we will delete it promptly\n'
                  '• Parents or guardians should contact us if they believe a child has provided data\n'
                  '• Age verification is required during account registration',
            ),

            _buildSection(
              context,
              title: '9. Cookies and Tracking Technologies',
              content:
                  'We use various technologies to collect data:\n\n'
                  '• Session data to maintain your login state\n'
                  '• Analytics tools to understand app usage\n'
                  '• Crash reporting to identify and fix bugs\n'
                  '• Performance monitoring to optimize the app\n\n'
                  'You can manage some tracking preferences through your device settings.',
            ),

            _buildSection(
              context,
              title: '10. Data Retention',
              content:
                  'We retain your data for as long as necessary:\n\n'
                  '• Active accounts: Data retained while account is active\n'
                  '• Deleted accounts: Most data deleted within 30 days\n'
                  '• Transaction records: Retained for 7 years for accounting/legal purposes\n'
                  '• Service history: Retained for dispute resolution and quality improvement\n'
                  '• Chat logs: Retained for 1 year or until account deletion\n'
                  '• Location data: Retained for active requests only, deleted after completion',
            ),

            _buildSection(
              context,
              title: '11. International Data Transfers',
              content:
                  'Your data may be transferred to and processed in countries outside India:\n\n'
                  '• We use cloud services that may store data globally\n'
                  '• We ensure adequate safeguards are in place for international transfers\n'
                  '• Data transfers comply with applicable data protection laws\n'
                  '• Primary data storage is within India',
            ),

            _buildSection(
              context,
              title: '12. Third-Party Links',
              content:
                  'Our App may contain links to third-party websites or services:\n\n'
                  '• We are not responsible for third-party privacy practices\n'
                  '• We encourage you to review their privacy policies\n'
                  '• This Privacy Policy applies only to MechResQ',
            ),

            _buildSection(
              context,
              title: '13. Changes to This Privacy Policy',
              content:
                  'We may update this Privacy Policy from time to time:\n\n'
                  '• Changes will be posted in the app with an updated date\n'
                  '• Significant changes will be notified via email or app notification\n'
                  '• Continued use after changes constitutes acceptance\n'
                  '• We encourage you to review this policy periodically',
            ),

            _buildSection(
              context,
              title: '14. GDPR Compliance (For EU Users)',
              content:
                  'If you are in the European Economic Area (EEA):\n\n'
                  '• Legal basis for processing: Consent, contract, legitimate interests\n'
                  '• You have additional rights under GDPR\n'
                  '• You can lodge a complaint with your local data protection authority\n'
                  '• We have appointed a Data Protection Officer (contact: dpo@mechresq.com)\n'
                  '• Data transfers outside EEA are protected by appropriate safeguards',
            ),

            _buildSection(
              context,
              title: '15. Contact Us',
              content:
                  'If you have questions or concerns about this Privacy Policy:\n\n'
                  '• Email: privacy@mechresq.com\n'
                  '• Phone: +91 98765 00000\n'
                  '• Address: [Your Company Address]\n'
                  '• Data Protection Officer: dpo@mechresq.com\n\n'
                  'We will respond to your inquiries within 30 days.',
            ),

            const SizedBox(height: 32),

            // GDPR Rights Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: scheme.secondary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.yourDataRights,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.dataRightsDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSecondaryContainer.withOpacity(0.9),
                      height: 1.5,
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
