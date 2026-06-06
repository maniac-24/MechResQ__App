// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../theme_controller.dart';
import '../locale_provider.dart';
import '../utils/snackbar_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ---------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------
  static const String _appVersion = "1.0.0";
  static const String _buildNumber = "42";

  final List<String> _themeOptions = ["Light", "Dark", "System"];
  
  // Language options with codes (for POC: English and Kannada only)
  final List<Map<String, String>> _languageOptions = [
    {"code": "en", "name": "English"},
    {"code": "kn", "name": "ಕನ್ನಡ"},
  ];

  // ---------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final themeController = context.watch<ThemeController>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ===== APPEARANCE =====
          _sectionHeader(context, l10n.appearance, Icons.palette_outlined),

          // Theme selector
          Card(
            color: scheme.surfaceContainerHighest,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                themeController.themeString == "Dark"
                    ? Icons.dark_mode
                    : themeController.themeString == "Light"
                        ? Icons.light_mode
                        : Icons.settings_brightness,
                color: scheme.onSurface,
              ),
              title: Text(l10n.theme),
              subtitle: Text(
                _getLocalizedThemeName(themeController.themeString, l10n),
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withOpacity(0.7),
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: scheme.onSurface.withOpacity(0.5),
              ),
              onTap: () => _showThemePicker(l10n),
            ),
          ),

          // App language selector
          Card(
            color: scheme.surfaceContainerHighest,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.translate, color: scheme.onSurface),
              title: Text(l10n.appLanguage),
              subtitle: Text(
                localeProvider.getLocaleName(localeProvider.locale.languageCode),
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withOpacity(0.7),
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: scheme.onSurface.withOpacity(0.5),
              ),
              onTap: () => _showLanguagePicker(localeProvider, l10n),
            ),
          ),

          const SizedBox(height: 16),

          // ===== ABOUT =====
          _sectionHeader(context, l10n.about, Icons.info_outlined),

          Card(
            color: scheme.surfaceContainerHighest,
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: scheme.onSurface),
                  title: Text(l10n.aboutMechResQ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: scheme.onSurface.withOpacity(0.5),
                  ),
                  onTap: () => _showInfoDialog(
                    l10n.aboutMechResQ,
                    l10n.aboutMechResQDescription(_appVersion, _buildNumber),
                    l10n,
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                // Version + build as read-only row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.version,
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        "$_appVersion (Build $_buildNumber)",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // HELPER: Get localized theme name
  // ---------------------------------------------------------------
  String _getLocalizedThemeName(String theme, AppLocalizations l10n) {
    switch (theme) {
      case "Light":
        return l10n.light;
      case "Dark":
        return l10n.dark;
      case "System":
        return l10n.system;
      default:
        return theme;
    }
  }

  // ---------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------
  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // THEME PICKER (bottom sheet)
  // ---------------------------------------------------------------
  void _showThemePicker(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    final themeController = context.read<ThemeController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.chooseTheme,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ..._themeOptions.map((option) {
                final isSelected = option == themeController.themeString;
                final icon = option == "Dark"
                    ? Icons.dark_mode
                    : option == "Light"
                        ? Icons.light_mode
                        : Icons.settings_brightness;

                return ListTile(
                  leading: Icon(icon, color: scheme.primary),
                  title: Text(
                    _getLocalizedThemeName(option, l10n),
                    style: TextStyle(color: scheme.onSurface),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: () async {
                    await themeController.setTheme(option);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    SnackBarHelper.showInfo(
                      context,
                      l10n.themeSetTo(_getLocalizedThemeName(option, l10n)),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // LANGUAGE PICKER (bottom sheet)
  // ---------------------------------------------------------------
  void _showLanguagePicker(LocaleProvider localeProvider, AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appLanguage,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ..._languageOptions.map((lang) {
                final langCode = lang["code"]!;
                final langName = lang["name"]!;
                final isSelected = langCode == localeProvider.locale.languageCode;
                
                return ListTile(
                  leading: Icon(Icons.translate, color: scheme.primary),
                  title: Text(
                    langName,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: () async {
                    await localeProvider.setLocale(Locale(langCode));
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    
                    // Wait a frame for locale to update
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted) return;
                    
                    SnackBarHelper.showInfo(
                      context,
                      AppLocalizations.of(context)!.languageChangedTo(langName),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // INFO DIALOG (About)
  // ---------------------------------------------------------------
  void _showInfoDialog(String title, String content, AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: scheme.surface,
        title: Text(
          title,
          style: TextStyle(color: scheme.onSurface),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(color: scheme.onSurface.withOpacity(0.8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}