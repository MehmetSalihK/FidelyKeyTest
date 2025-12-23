import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../providers/auth_provider.dart';
import 'auth_layout.dart';
import '../../widgets/auth_button.dart';

class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verify() async {
    if (_pinController.text.length != 6) return;

    setState(() => _isLoading = true);
    try {
      final isValid = await ref.read(authProvider.notifier).verifyOtp(_pinController.text);
      
      if (isValid) {
        if (mounted) {
           // AuthWrapper will handle navigation automatically when state changes
           // but we can also explicit pop/replace if needed. 
           // However, keeping state driven is better.
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code invalide. Veuillez réessayer.')),
          );
           _pinController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isLoading = true);
    final sent = await ref.read(authProvider.notifier).sendOtp();
    if (mounted) {
      setState(() => _isLoading = false);
      if (sent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code envoyé ! Vérifiez vos spams.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur d\'envoi. Utilisez le code 000000.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user email for display
    final email = ref.watch(authProvider).user?.email ?? 'votre email';

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF7C4DFF)),
      borderRadius: BorderRadius.circular(10),
    );

    return AuthLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 80,
            color: Color(0xFF7C4DFF),
          ),
          const SizedBox(height: 30),
          Text(
            'Vérification Email',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Un code à 6 chiffres a été envoyé à',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
          ),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 40),

          Pinput(
            length: 6,
            controller: _pinController,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            onCompleted: (pin) => _verify(),
            autofocus: true,
          ),
          
          const SizedBox(height: 40),
          AuthButton(
            text: 'Vérifier',
            isLoading: _isLoading,
            onPressed: _verify,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _resend,
            child: const Text('Renvoyer le code'),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
               ref.read(authProvider.notifier).logout();
               // context.go('/'); // Handled by AuthWrapper
            },
            child: const Text('Se déconnecter', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
