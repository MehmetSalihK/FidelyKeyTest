import 'package:cloud_firestore/cloud_firestore.dart';

class CloudStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadBackup(String uid, String encryptedBlob) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('backups')
          .doc('latest')
          .set({
        'encrypted_blob': encryptedBlob,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  Future<String?> downloadBackup(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('backups')
          .doc('latest')
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['encrypted_blob'] as String;
      }
      return null;
    } catch (e) {
      throw Exception("Download failed: $e");
    }
  }
}
