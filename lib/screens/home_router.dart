import 'package:flutter/material.dart';
import '../core/storage/token_storage.dart';
import '../l10n/app_localizations.dart';

/// User role constants for type-safe role checking
class UserRoles {
  UserRoles._(); // Private constructor to prevent instantiation
  
  static const String user = 'user';
  static const String mechanic = 'mechanic'; // Keep for validation, but not used
}

/// Production-safe authentication router (USER APP ONLY)
/// 
/// Features:
/// - Post-frame navigation (prevents timing issues)
/// - User-only routing with mechanic rejection
/// - Theme-aware loading indicator
/// - Proper error handling for corrupted/unknown roles
class HomeRouter extends StatefulWidget {
  const HomeRouter({super.key});

  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  @override
  void initState() {
    super.initState();
    // Defer navigation until after first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final loggedIn = await TokenStorage.isLoggedIn();
    final role = await TokenStorage.getRole();

    if (!mounted) return;

    // Not logged in or role missing → Login screen
    if (!loggedIn || role == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      return;
    }

    // Role-based routing (USER-ONLY APP)
    switch (role) {
      case UserRoles.user:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (_) => false,
        );
        break;

      case UserRoles.mechanic:
        // Mechanic tried to log in to user app → Show error and redirect to login
        if (mounted) {
          await _showMechanicError();
        }
        await TokenStorage.clear();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (_) => false,
          );
        }
        break;

      default:
        // Unknown/corrupted role → Clear auth and redirect to login
        await TokenStorage.clear();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (_) => false,
          );
        }
    }
  }

  Future<void> _showMechanicError() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.wrongApp),
        content: Text(l10n.wrongAppMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: scheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loading,
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
