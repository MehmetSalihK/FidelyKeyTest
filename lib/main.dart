import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Add this import

import 'presentation/layout/responsive_layout.dart';
import 'presentation/mobile/screens/scan_qr_screen.dart';
import 'presentation/screens/manual_entry_screen.dart';
import 'presentation/mobile/mobile_scaffold.dart';
import 'presentation/desktop/desktop_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // Fallback if options are missing or wrong platform, ensuring app still starts
    if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(); 
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanQrScreen(),
    ),
    GoRoute(
      path: '/manual',
      builder: (context, state) => const ManualEntryScreen(),
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FidelyKey',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      routerConfig: _router,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: MobileScaffold(),
      desktopBody: DesktopScaffold(),
    );
  }
}
