import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'theme.dart';
import 'theme_controller.dart';
import 'locale_provider.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_requests_screen.dart';
import 'screens/create_request_screen.dart';
import 'screens/request_success_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting();
  
  // Initialize Notification Service
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MechResQApp(),
    ),
  );
}

class MechResQApp extends StatelessWidget {
  const MechResQApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.hazardTheme(),
      themeMode: themeController.themeMode,
      
      // Localization setup
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('kn'), // Kannada (Proof of Concept)
        // Future languages:
        // Locale('hi'), // Hindi
        // Locale('ta'), // Tamil
        // Locale('te'), // Telugu
      ],
      
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MechanicListScreen(),
        '/profile': (_) => ProfileScreen(),
        '/my_requests': (_) => MyRequestsScreen(),
        '/create_request': (_) => const CreateRequestScreen(),
        '/request_success': (_) => const RequestSuccessScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _decideNavigation();
  }

    Future<void> _decideNavigation() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    try {
      final isLoggedIn = _auth.isLoggedIn();
      if (!isLoggedIn) {
        _navigate('/login');
        return;
      }

      final role = await _auth.getRole().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      if (!mounted) return;

      if (role == 'user') {
        _navigate('/home');
      } else {
        await _auth.logout();
        _navigate('/login');
      }
    } catch (e) {
      if (!mounted) return;
      _navigate('/login');
    }
  }

  void _navigate(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'MechResQ',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}