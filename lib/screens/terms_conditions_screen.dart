import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsConditions),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              l10n.mechresqTermsConditions,
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
                  'Welcome to MechResQ ("we", "our", or "us"). By accessing or using the MechResQ mobile application '
                  '(the "App"), you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree to '
                  'these Terms, please do not use the App.\n\n'
                  'MechResQ is a platform that connects users with verified mechanics for vehicle breakdown assistance '
                  'and repair services. These Terms govern your use of the App and the services provided through it.',
            ),

            _buildSection(
              context,
              title: '2. Eligibility',
              content:
                  'You must be at least 18 years old to use the App. By using the App, you represent and warrant that:\n\n'
                  '• You are at least 18 years of age\n'
                  '• You have the legal capacity to enter into these Terms\n'
                  '• You will use the App in compliance with all applicable laws and regulations\n'
                  '• All information you provide is accurate, current, and complete',
            ),

            _buildSection(
              context,
              title: '3. Account Registration',
              content:
                  'To use certain features of the App, you must register for an account:\n\n'
                  '• You agree to provide accurate and complete information during registration\n'
                  '• You are responsible for maintaining the confidentiality of your account credentials\n'
                  '• You are responsible for all activities that occur under your account\n'
                  '• You must immediately notify us of any unauthorized use of your account\n'
                  '• We reserve the right to suspend or terminate accounts that violate these Terms',
            ),

            _buildSection(
              context,
              title: '4. Services Provided',
              content:
                  'MechResQ provides a platform to connect users with mechanics:\n\n'
                  '• Service Requests: Users can submit requests for vehicle assistance\n'
                  '• Mechanic Discovery: Browse and view profiles of verified mechanics\n'
                  '• Real-time Tracking: Track mechanic location during service\n'
                  '• Communication: Chat and call features to communicate with mechanics\n'
                  '• Payment Processing: Secure payment gateway for service fees\n\n'
                  'MechResQ acts as an intermediary platform. We do not directly provide mechanical services. '
                  'The actual services are performed by independent mechanics.',
            ),

            _buildSection(
              context,
              title: '5. User Responsibilities',
              content:
                  'As a user of the App, you agree to:\n\n'
                  '• Provide accurate vehicle and location information\n'
                  '• Treat mechanics with respect and professionalism\n'
                  '• Pay for services as agreed upon\n'
                  '• Not misuse the App or engage in fraudulent activities\n'
                  '• Not share your account with others\n'
                  '• Comply with all applicable laws and regulations\n'
                  '• Not use the App for any illegal or unauthorized purpose',
            ),

            _buildSection(
              context,
              title: '6. Mechanic Verification',
              content:
                  'While we take reasonable measures to verify mechanics on our platform:\n\n'
                  '• We conduct background checks and verify credentials\n'
                  '• We cannot guarantee the quality of service provided by mechanics\n'
                  '• Users should exercise their own judgment when selecting a mechanic\n'
                  '• We encourage users to review ratings and feedback before making a selection\n'
                  '• Report any issues or concerns immediately through the App',
            ),

            _buildSection(
              context,
              title: '7. Payments and Fees',
              content:
                  'Payment terms for using MechResQ:\n\n'
                  '• Service fees are determined by the mechanic and agreed upon before service\n'
                  '• Platform fees may apply as disclosed during checkout\n'
                  '• Payments are processed securely through our payment gateway partners\n'
                  '• All fees are in Indian Rupees (INR) unless otherwise specified\n'
                  '• Refunds are subject to our Refund Policy\n'
                  '• We reserve the right to change fees with prior notice',
            ),

            _buildSection(
              context,
              title: '8. Cancellation Policy',
              content:
                  'Users may cancel service requests under the following conditions:\n\n'
                  '• Free cancellation before mechanic accepts the request\n'
                  '• Cancellation fees may apply after acceptance\n'
                  '• Fees depend on mechanic\'s progress toward your location\n'
                  '• Refunds for cancellations are processed within 5-7 business days\n'
                  '• Repeated cancellations may result in account restrictions',
            ),

            _buildSection(
              context,
              title: '9. Limitation of Liability',
              content:
                  'To the maximum extent permitted by law:\n\n'
                  '• MechResQ is not liable for the quality of services provided by mechanics\n'
                  '• We are not responsible for damages to your vehicle during service\n'
                  '• We are not liable for delays, accidents, or injuries during service\n'
                  '• Our total liability is limited to the amount paid for the specific service\n'
                  '• We are not responsible for indirect, incidental, or consequential damages\n'
                  '• Use of the App is at your own risk',
            ),

            _buildSection(
              context,
              title: '10. Intellectual Property',
              content:
                  'All content and materials on the App are protected by intellectual property laws:\n\n'
                  '• The MechResQ name, logo, and trademarks are our property\n'
                  '• All software, design, text, graphics, and other content are protected\n'
                  '• You may not copy, modify, distribute, or reverse engineer any part of the App\n'
                  '• User-generated content remains your property, but you grant us a license to use it',
            ),

            _buildSection(
              context,
              title: '11. Privacy and Data Protection',
              content:
                  'Your privacy is important to us:\n\n'
                  '• We collect and process personal data as described in our Privacy Policy\n'
                  '• We use data to provide and improve our services\n'
                  '• We implement security measures to protect your data\n'
                  '• We comply with applicable data protection laws including GDPR\n'
                  '• Please review our Privacy Policy for detailed information',
            ),

            _buildSection(
              context,
              title: '12. Prohibited Activities',
              content:
                  'You may not use the App to:\n\n'
                  '• Violate any laws or regulations\n'
                  '• Infringe on intellectual property rights\n'
                  '• Transmit viruses, malware, or harmful code\n'
                  '• Engage in fraudulent activities or impersonation\n'
                  '• Harass, abuse, or harm other users or mechanics\n'
                  '• Scrape or collect data from the App without permission\n'
                  '• Interfere with the proper functioning of the App',
            ),

            _buildSection(
              context,
              title: '13. Termination',
              content:
                  'We may suspend or terminate your account:\n\n'
                  '• If you violate these Terms\n'
                  '• If you engage in fraudulent or abusive behavior\n'
                  '• If required by law or regulatory authorities\n'
                  '• At our sole discretion for any reason\n\n'
                  'Upon termination:\n'
                  '• Your access to the App will be revoked\n'
                  '• Outstanding payments must be settled\n'
                  '• Some provisions of these Terms will survive termination',
            ),

            _buildSection(
              context,
              title: '14. Changes to Terms',
              content:
                  'We reserve the right to modify these Terms at any time:\n\n'
                  '• Changes will be effective immediately upon posting\n'
                  '• We will notify you of significant changes via the App or email\n'
                  '• Continued use of the App constitutes acceptance of modified Terms\n'
                  '• You should review these Terms periodically',
            ),

            _buildSection(
              context,
              title: '15. Governing Law',
              content:
                  'These Terms are governed by the laws of India:\n\n'
                  '• Any disputes will be subject to the exclusive jurisdiction of courts in [Your City], India\n'
                  '• You agree to resolve disputes through binding arbitration where applicable\n'
                  '• Class action lawsuits are waived to the extent permitted by law',
            ),

            _buildSection(
              context,
              title: '16. Contact Us',
              content:
                  'If you have questions about these Terms, please contact us:\n\n'
                  '• Email: legal@mechresq.com\n'
                  '• Phone: +91 98765 00000\n'
                  '• Address: [Your Company Address]\n'
                  '• Support Hours: 24/7 via app, 9 AM - 6 PM for legal queries',
            ),

            const SizedBox(height: 32),

            // Agreement Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                l10n.termsAgreementFooter,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
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
