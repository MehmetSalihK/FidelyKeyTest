import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final User? user;
  final String? encryptionKey; // Derived from password

  const AuthState({this.user, this.encryptionKey});
}

class AuthNotifier extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  AuthState build() {
    // Listen to auth changes
    _auth.authStateChanges().listen((user) {
      // If user logs out, clear state
      if (user == null) {
        state = const AuthState();
      } else {
        // If user is already logged in, we might not have the encryption key (password)
        // This is a limitation: if auto-login happens, we need to ask for password again to decrypt!
        // For this MVP, we will assume session starts with login/signup to capture password.
        if (state.user != user) {
           state = AuthState(user: user, encryptionKey: state.encryptionKey);
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
    // Store password as key
    state = AuthState(user: credential.user, encryptionKey: password);
  }

  Future<void> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Store password as key
    state = AuthState(user: credential.user, encryptionKey: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
