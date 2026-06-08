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
import 'utils/notification_navigation_helper.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_requests_screen.dart';
import 'screens/create_request_screen.dart';
import 'screens/request_success_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/track_mechanic_screen.dart';
import 'screens/request_detail_screen.dart';
import 'screens/chat_mechanic_screen.dart';
import 'screens/sos_history_screen.dart';
import 'screens/service_reminders_screen.dart';
import 'screens/submit_review_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/receipt_success_screen.dart';
import 'screens/receipt_detail_screen.dart';
export 'screens/bill_screen.dart' show BillMode;

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
      navigatorKey: NotificationNavigationHelper.navigatorKey, // Add navigator key for notification navigation
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
        '/sos_history': (_) => const SOSHistoryScreen(),
        '/service_reminders': (_) => const ServiceRemindersScreen(),
      },
      onGenerateRoute: _generateRoute,
    );
  }

  /// Generate routes for screens that require arguments
  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/bill':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) return null;
        return MaterialPageRoute(
          builder: (_) => BillScreen(
            requestId: args['requestId'] as String,
            vehicleType: args['vehicle'] as String? ?? 'Car',
            issueDescription: args['issue'] as String? ?? '',
            serviceLocation: args['location'] as String? ?? '',
            distanceKm: (args['distanceKm'] as num?)?.toDouble() ?? 5.0,
            mode: BillMode.estimate, // always estimate when coming from create
          ),
        );

      case '/receipt_success':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) return null;
        return MaterialPageRoute(
          builder: (_) => ReceiptSuccessScreen(
            receiptId: args['receiptId'] as String? ?? '',
            paymentId: args['paymentId'] as String? ?? '',
            amount: (args['amount'] as num?)?.toDouble() ?? 0.0,
            vehicleType: args['vehicleType'] as String? ?? 'Vehicle',
            requestId: args['requestId'] as String? ?? '',
          ),
        );

      case '/receipt_detail':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ReceiptDetailScreen(
            receiptId: args?['receiptId'] as String?,
            requestId: args?['requestId'] as String?,
          ),
        );

      case '/track_mechanic':
        final requestId = settings.arguments as String?;
        if (requestId == null) return null;
        return MaterialPageRoute(
          builder: (_) => TrackMechanicScreen(requestId: requestId),
        );

      case '/request_detail':
        final requestId = settings.arguments as String?;
        if (requestId == null) return null;
        return MaterialPageRoute(
          builder: (_) => RequestDetailScreen(
            data: {'requestId': requestId},
          ),
        );

      case '/chat_mechanic':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['mechanicName'] == null) return null;
        return MaterialPageRoute(
          builder: (_) => ChatMechanicScreen(
            mechanicName: args['mechanicName'] as String,
          ),
        );

      case '/submit_review':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) return null;
        return MaterialPageRoute(
          builder: (_) => SubmitReviewScreen(
            requestId: args['requestId'] as String,
            mechanicId: args['mechanicId'] as String,
            mechanicName: args['mechanicName'] as String,
          ),
        );

      default:
        return null;
    }
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