import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometrics are available on the device
  static Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint("Error checking biometrics: $e");
      return false;
    }
  }

  /// Trigger authentication prompt
  /// Returns [true] if authenticated successfully
  static Future<bool> authenticate() async {
    // 1. Bypass on Web for now (Chrome often has issues with local_auth without proper setup)
    if (kIsWeb) return true;

    try {
      final isAvailable = await canCheckBiometrics();
      if (!isAvailable) {
        return true; 
      }

      return await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à FidelyKey',
      ).timeout(const Duration(seconds: 5), onTimeout: () {
          debugPrint("Biometric auth timed out");
          return false; // Fail on timeout, or true? False makes sense, but if it's broken... 
          // If it times out, user can click retry.
      });
    } on PlatformException catch (e) {
      debugPrint("Error during authentication: $e");
      return false; 
    } catch (e) {
      debugPrint("Unknown error during authentication: $e");
      return false;
    }
  }
}
