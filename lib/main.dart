import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Add this import

import 'presentation/layout/responsive_layout.dart';
import 'presentation/screens/scan_qr_screen.dart'; // Corrected path
import 'presentation/screens/manual_entry_screen.dart';
import 'presentation/mobile/mobile_scaffold.dart';
import 'presentation/desktop/desktop_scaffold.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/auth/verify_code_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/widgets/biometric_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // Fallback
    if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(); 
    }
  }
  
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(ProviderScope(child: MyApp(initialLocation: seenOnboarding ? '/' : '/onboarding')));
}

class MyApp extends ConsumerWidget {
  final String initialLocation;
  const MyApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AuthWrapper(),
        ),
        GoRoute(
          path: '/scan',
          builder: (context, state) => const ScanQrScreen(),
        ),
        GoRoute(
          path: '/manual',
          builder: (context, state) => const ManualEntryScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'FidelyKey',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C), // Deep Blue-Grey
        cardColor: const Color(0xFF2D2D44), // Surface
        primaryColor: const Color(0xFF6C63FF), // Modern Purple
        
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00E5FF), // Cyan Accent
          surface: Color(0xFF2D2D44),
          onSurface: Colors.white,
          error: Color(0xFFFF5252),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
            headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
            titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
            bodyLarge: GoogleFonts.inter(color: Colors.white),
            bodyMedium: GoogleFonts.inter(color: Colors.white70),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(55),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2D2D44),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: GoogleFonts.inter(color: Colors.white30),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
          ),
        ),
        
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        
        iconTheme: const IconThemeData(color: Colors.white),
        dividerTheme: DividerThemeData(color: Colors.white.withOpacity(0.1)),
      ),
      builder: (context, child) => BiometricGuard(child: child!),
      routerConfig: router,
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Check if authenticated
    if (authState.user != null) {
      if (authState.isTwoFactorVerified) {
         return const HomePage();
      } else {
         return const VerifyCodeScreen();
      }
    } else {
      return const WelcomeScreen();
    }
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
