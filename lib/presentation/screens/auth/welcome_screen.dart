import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/auth_button.dart';
import 'auth_layout.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showAppBar: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(
            Icons.vpn_key_rounded,
            size: 100,
            color: Color(0xFF7C4DFF),
          ),
          const SizedBox(height: 32),
          Text(
            'FidelyKey',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sécurisez vos comptes,\nsimplement et partout.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[400],
                  height: 1.5,
                ),
          ),
          const Spacer(),
          AuthButton(
            text: 'Se connecter',
            onPressed: () => context.push('/login'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/signup'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF7C4DFF)),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Créer un compte',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
