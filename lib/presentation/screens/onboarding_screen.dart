import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/auth_button.dart';

import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.shield_rounded,
                size: 120,
                color: Color(0xFF7C4DFF),
              ),
              const SizedBox(height: 40),
              Text(
                'Bienvenue sur FidelyKey',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                'Gérez vos codes 2FA en toute sécurité.\nSynchronisation Cloud chiffrée de bout en bout.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[400],
                      height: 1.5,
                    ),
              ),
              const Spacer(),
              AuthButton(
                text: 'Commencer',
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seenOnboarding', true);
                  if (context.mounted) {
                    context.go('/'); 
                  }
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  context.push('/login');
                },
                child: const Text(
                  'Déjà un compte ? Se connecter',
                  style: TextStyle(
                    color: Color(0xFF7C4DFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
