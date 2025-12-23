import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class EncryptionService {
  /// Encrypts the [plainJson] using a key derived from [password].
  /// Returns a Base64 string containing both the IV and the Encrypted Data.
  static String encryptData(String plainJson, String password) {
    // 1. Derive a 32-byte key from the password using SHA-256
    // In production, PBKDF2 with a salt is better, but SHA-256 is acceptable for this MVP.
    final keyBytes = sha256.convert(utf8.encode(password)).bytes;
    final key = Key(Uint8List.fromList(keyBytes));

    // 2. Generate a random IV (Initialization Vector)
    final iv = IV.fromLength(16); // 16 bytes for AES

    // 3. Encrypt using AES (CBC mode is common, GCM is better but 'encrypt' package defaults often to simple blocks)
    // We will use AES mode CBC with PKCS7 padding default of the encrypter
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(plainJson, iv: iv);

    // 4. Combine IV and Encrypted data to allow decryption
    // Format: iv_base64 : encrypted_base64
    return "${iv.base64}:${encrypted.base64}";
  }

  /// Decrypts the [encryptedBlob] using a key derived from [password].
  /// Returns the original JSON string.
  static String decryptData(String encryptedBlob, String password) {
    try {
      final parts = encryptedBlob.split(':');
      if (parts.length != 2) throw Exception("Invalid encrypted format");

      final iv = IV.fromBase64(parts[0]);
      final encryptedData = Encrypted.fromBase64(parts[1]);

      final keyBytes = sha256.convert(utf8.encode(password)).bytes;
      final key = Key(Uint8List.fromList(keyBytes));

      final encrypter = Encrypter(AES(key));

      return encrypter.decrypt(encryptedData, iv: iv);
    } catch (e) {
      throw Exception("Decryption failed: Incorrect password or corrupted data.");
    }
  }
}
