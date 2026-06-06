import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

/// Lightweight Help screen specifically for login stage
/// Matches Rapido's simple help design - focused on login issues only
class LoginHelpScreen extends StatelessWidget {
  const LoginHelpScreen({super.key});

  Future<void> _callSupport(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+919876500000');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.unableToOpenPhoneDialer),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.phoneDialerNotAvailable),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _emailSupport(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@mechresq.com',
      queryParameters: {
        'subject': 'MechResQ Login Support',
      },
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.unableToOpenEmailApp),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.emailAppNotAvailable),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginHelp),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Need Help Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: scheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.needHelp,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.needHelpDescription,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurface.withOpacity(0.7),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // FAQ Section (removed View All button)
            Text(
              l10n.frequentlyAskedQuestions,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            // Login-specific FAQs (matching Rapido's login issues)
            _FAQItem(
              icon: Icons.login,
              question: l10n.faqUnableToLogin,
              answer: l10n.faqUnableToLoginAnswer,
            ),

            _FAQItem(
              icon: Icons.sms,
              question: l10n.faqNotReceivingOtp,
              answer: l10n.faqNotReceivingOtpAnswer,
            ),

            _FAQItem(
              icon: Icons.error_outline,
              question: l10n.faqInvalidOtp,
              answer: l10n.faqInvalidOtpAnswer,
            ),

            _FAQItem(
              icon: Icons.warning_amber,
              question: l10n.faqAppCrashes,
              answer: l10n.faqAppCrashesAnswer,
            ),

            _FAQItem(
              icon: Icons.phone_android,
              question: l10n.faqChangedPhoneNumber,
              answer: l10n.faqChangedPhoneNumberAnswer,
            ),

            const SizedBox(height: 28),

            // Contact Information
            Text(
              l10n.contactInformation,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  _ContactTile(
                    icon: Icons.email,
                    title: l10n.emailSupport,
                    subtitle: 'support@mechresq.com',
                    onTap: () => _emailSupport(context),
                  ),
                  Divider(height: 1, color: scheme.outline.withOpacity(0.2)),
                  _ContactTile(
                    icon: Icons.phone,
                    title: l10n.phoneSupport,
                    subtitle: '+91 98765 00000',
                    onTap: () => _callSupport(context),
                  ),
                  Divider(height: 1, color: scheme.outline.withOpacity(0.2)),
                  _ContactTile(
                    icon: Icons.access_time,
                    title: l10n.supportHours,
                    subtitle: l10n.support24x7,
                    onTap: null,
                  ),
                  Divider(height: 1, color: scheme.outline.withOpacity(0.2)),
                  _ContactTile(
                    icon: Icons.location_on,
                    title: l10n.location,
                    subtitle: l10n.locationIndia,
                    onTap: null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer
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
                  const SizedBox(height: 4),
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
}

// ═══════════════════════════════════════════════════════
// HELPER WIDGETS
// ═══════════════════════════════════════════════════════

class _FAQItem extends StatefulWidget {
  final IconData icon;
  final String question;
  final String answer;

  const _FAQItem({
    required this.icon,
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  String? _feedback; // 'helpful' or 'not_helpful'

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline.withOpacity(0.2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: scheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            widget.question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: scheme.onSurface,
            ),
          ),
          iconColor: scheme.primary,
          collapsedIconColor: scheme.onSurface.withOpacity(0.5),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            // Answer text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: scheme.outline.withOpacity(0.1),
                ),
              ),
              child: Text(
                widget.answer,
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Feedback section
            Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.wasThisArticleHelpful,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Thumbs up
                    _FeedbackButton(
                      icon: Icons.thumb_up,
                      label: AppLocalizations.of(context)!.feedbackYes,
                      isSelected: _feedback == 'helpful',
                      onTap: () {
                        setState(() {
                          _feedback = _feedback == 'helpful' ? null : 'helpful';
                        });
                        if (_feedback == 'helpful') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.thankYouForFeedback),
                              duration: const Duration(seconds: 2),
                              backgroundColor: scheme.primary,
                            ),
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Thumbs down
                    _FeedbackButton(
                      icon: Icons.thumb_down,
                      label: AppLocalizations.of(context)!.feedbackNo,
                      isSelected: _feedback == 'not_helpful',
                      onTap: () {
                        setState(() {
                          _feedback = _feedback == 'not_helpful' ? null : 'not_helpful';
                        });
                        if (_feedback == 'not_helpful') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.sorryContactSupport),
                              duration: const Duration(seconds: 2),
                              backgroundColor: scheme.error,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? scheme.primaryContainer 
              : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? scheme.primary 
                : scheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                  ? scheme.primary 
                  : scheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected 
                    ? scheme.primary 
                    : scheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: scheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: scheme.primary.withOpacity(0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
