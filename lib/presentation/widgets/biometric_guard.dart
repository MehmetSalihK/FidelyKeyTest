import 'package:flutter/material.dart';
import '../../core/security/biometric_service.dart';

class BiometricGuard extends StatefulWidget {
  final Widget child;
  const BiometricGuard({super.key, required this.child});

  @override
  State<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends State<BiometricGuard> with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial auth
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Backgrounded -> Lock
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      // Foregrounded -> Authenticate if not already
      if (!_isAuthenticated) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    
    if (mounted) setState(() => _isAuthenticating = true);
    
    // Setup for authentication
    try {
      final authenticated = await BiometricService.authenticate();
      if (mounted) {
        setState(() {
          _isAuthenticated = authenticated;
        });
      }
    } finally {
      _isAuthenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The App Content (always there, but maybe covered)
        widget.child,

        // The Lock Screen Overlay
        if (!_isAuthenticated)
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 80,
                    color: Color(0xFF7C4DFF),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'FidelyKey Verrouillé',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Authentification requise pour accéder à vos codes.'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: _isAuthenticating 
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text('Déverrouiller'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
