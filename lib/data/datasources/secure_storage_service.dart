import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/totp_entity.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _keyAccounts = 'fidely_accounts';

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        // encryptedSharedPreferences is deprecated and default options are secure enough or migrated
      );
  
  IOSOptions _getIOSOptions() => const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  Future<void> saveAccounts(List<TotpEntity> accounts) async {
    try {
      final List<Map<String, dynamic>> jsonList = accounts.map((e) => e.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await _storage.write(
        key: _keyAccounts,
        value: jsonString,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      // Handle or log error
      debugPrint("Error saving accounts: $e");
    }
  }

  Future<List<TotpEntity>> loadAccounts() async {
    try {
      final String? jsonString = await _storage.read(
        key: _keyAccounts,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => TotpEntity.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error loading accounts: $e");
      return [];
    }
  }
}
