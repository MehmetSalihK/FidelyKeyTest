import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_otp/email_otp.dart';
import '../../core/security/key_manager.dart';

class AuthState {
  final User? user;
  final String? encryptionKey; // Derived from password
  final bool isTwoFactorVerified;

  const AuthState({
    this.user, 
    this.encryptionKey,
    this.isTwoFactorVerified = false,
  });

  AuthState copyWith({
    User? user,
    String? encryptionKey,
    bool? isTwoFactorVerified,
  }) {
    return AuthState(
      user: user ?? this.user,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      isTwoFactorVerified: isTwoFactorVerified ?? this.isTwoFactorVerified,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Initialize EmailOTP
  // Note: EmailOTP configuration should be done before sending.
  // We'll configure it in sendOtp.

  @override
  AuthState build() {
    // Listen to auth changes
    _auth.authStateChanges().listen((user) async {
      // If user logs out, clear state
      if (user == null) {
        state = const AuthState();
        await KeyManager.clearKey();
      } else {
        if (state.user?.uid != user.uid) {
           // Try to recover key from secure storage if we don't have it in memory
           String? key = state.encryptionKey;
           if (key == null) {
             key = await KeyManager.getKey();
           }
           
           // If key is still null here, we are in trouble for auto-login decryption.
           // Ideally we should prompt for password if key is missing.
           // For now, we assume key persists or session requires manual re-login if lost.
           // But 'authStateChanges' fires on restart.
           
           state = AuthState(user: user, encryptionKey: key, isTwoFactorVerified: false);
        }
      }
    });
    return AuthState(user: _auth.currentUser);
  }

  Future<void> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await KeyManager.saveKey(password);
    state = AuthState(user: credential.user, encryptionKey: password, isTwoFactorVerified: true);
  }

  Future<void> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await KeyManager.saveKey(password);
    state = AuthState(user: credential.user, encryptionKey: password, isTwoFactorVerified: false);
    
    // Send OTP
    await sendOtp();
  }

  Future<bool> sendOtp() async {
    final email = state.user?.email;
    if (email == null) return false;

    // Configure EmailOTP
    EmailOTP.config(
      appName: 'FidelyKey',
      otpType: OTPType.numeric,
      emailTheme: EmailTheme.v1, 
      otpLength: 6,
    );
    
    // Attempt send
    bool result = await EmailOTP.sendOTP(email: email);
    debugPrint("Email OTP result: $result");
    return result;
  }
  
  // Update sendOtp first, verifyOtp logic next
  Future<bool> verifyOtp(String code) async {
    // DEV BYPASS for testing
    if (code == '000000') {
      state = state.copyWith(isTwoFactorVerified: true);
      return true;
    }
    
    bool isValid = EmailOTP.verifyOTP(otp: code);
    if (isValid) {
      state = state.copyWith(isTwoFactorVerified: true);
    }
    return isValid;
  }

  Future<void> logout() async {
    await _auth.signOut();
    await KeyManager.clearKey();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
