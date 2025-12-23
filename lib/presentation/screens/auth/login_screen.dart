import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/auth_button.dart';
import 'auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) {
        // Validation handled by AuthWrapper in main.dart or standard navigation
        // If we pushReplacement to root, main.dart will redirect to Dashboard.
        // But context.pop() might return to Welcome Screen if we pushed from there.
        // It's safer to go to root.
        context.go('/'); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ravi de vous revoir !")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de connexion : $e")),
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
              Icons.lock_person_rounded,
              size: 100,
              color: Color(0xFF7C4DFF),
            ),
            const SizedBox(height: 30),
            Text(
              'Bon retour !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Vos codes sont en sécurité.',
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            AuthButton(
              text: 'Se connecter',
              isLoading: _isLoading,
              onPressed: _login,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pas encore de compte ?',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    // Navigate to Signup
                    context.pushReplacement('/signup');
                  },
                  child: const Text(
                    'S\'inscrire',
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
