import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyManager {
  static const _storage = FlutterSecureStorage();
  static const _keyParams = 'encryption_key';

  /// Saves the encryption key securely (or as securely as possible on Web)
  static Future<void> saveKey(String key) async {
    if (kIsWeb) {
      // On Web, we use SharedPreferences for persistence as requested.
      // Note: This is not as secure as native Keychain/Keystore.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyParams, key);
    } else {
      await _storage.write(key: _keyParams, value: key);
    }
  }

  /// Retrieves the encryption key
  static Future<String?> getKey() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyParams);
    } else {
      return await _storage.read(key: _keyParams);
    }
  }

  /// Clears the stored key
  static Future<void> clearKey() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyParams);
    } else {
      await _storage.delete(key: _keyParams);
    }
  }
}
