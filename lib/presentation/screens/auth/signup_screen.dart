import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/auth_button.dart';
import 'auth_layout.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signUp(
            email,
            password,
          );
      if (mounted) {
        context.go('/'); // Navigate to root (Wrapper will redirect if needed or show Dashboard)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé avec succès ! Bienvenue.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur d'inscription : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Icon(
              Icons.person_add_alt_1_rounded,
              size: 100,
              color: Color(0xFF7C4DFF),
            ),
            const SizedBox(height: 30),
            Text(
              'Créer un compte',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rejoignez FidelyKey aujourd\'hui.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
            const SizedBox(height: 40),
            AuthTextField(
              controller: _emailController,
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 15),
            AuthTextField(
              controller: _passwordController,
              hintText: 'Mot de passe',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 15),
            AuthTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirmer mot de passe',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            AuthButton(
              text: 'S\'inscrire',
              isLoading: _isLoading,
              onPressed: _signUp,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Déjà membre ?',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    context.replace('/login');
                  },
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(
                      color: Color(0xFF7C4DFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
