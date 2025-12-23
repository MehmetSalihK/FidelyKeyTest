import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/security/encryption_service.dart';
import '../../core/security/key_manager.dart';
import '../../domain/entities/totp_entity.dart';
import 'auth_provider.dart';
import 'totp_provider.dart';

enum SyncStatus { idle, syncing, upToDate, error }

class SyncState {
  final SyncStatus status;
  final String? lastUpdatedPlatform;
  final DateTime? lastUpdatedTime;

  const SyncState({this.status = SyncStatus.idle, this.lastUpdatedPlatform, this.lastUpdatedTime});
}

class SyncNotifier extends Notifier<SyncState> {
  StreamSubscription? _subscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  SyncState build() {
    // Listen to Auth changes to start/stop sync
    final authState = ref.watch(authProvider);
    if (authState.user != null) {
      _startListening(authState.user!.uid);
    } else {
      _stopListening();
    }
    return const SyncState();
  }

  void _startListening(String uid) {
    if (_subscription != null) return;

    _subscription = _firestore.collection('users').doc(uid).snapshots().listen((snapshot) async {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null || !data.containsKey('encrypted_data')) return;

      // We could check if the update came from us to avoid redundant processing, 
      // but processing it ensures consistency.
      
      state = SyncState(
        status: SyncStatus.syncing, 
        lastUpdatedPlatform: data['last_updated_platform'],
        lastUpdatedTime: (data['timestamp'] as Timestamp?)?.toDate(),
      );

      try {
        final encryptedData = data['encrypted_data'] as String;
        final key = await KeyManager.getKey();
        
        if (key != null) {
          final decryptedJson = EncryptionService.decryptData(encryptedData, key);
          final List<dynamic> decoded = jsonDecode(decryptedJson);
          final List<TotpEntity> accounts = decoded.map((e) => TotpEntity.fromJson(e)).toList();
          
          // Update Local Provider
          // Note: setAccounts should NOT trigger pushToCloud back to avoid loops.
          // We need TotpProvider to know if it's a "local" action or "remote" action.
          // Or we just update state without side effects in TotpProvider.
          // The current setAccounts implementation only saves to local storage, keeping it safe.
          await ref.read(totpProvider.notifier).setAccounts(accounts);
          
          state = SyncState(
            status: SyncStatus.upToDate,
            lastUpdatedPlatform: data['last_updated_platform'],
            lastUpdatedTime: (data['timestamp'] as Timestamp?)?.toDate(),
          );
        } else {
            // Missing key (e.g. fresh install/login without persisting key on web?)
             debugPrint("Sync Error: Missing Encryption Key");
             state = SyncState(status: SyncStatus.error); 
        }
      } catch (e) {
        debugPrint("Sync Error: $e");
        state = SyncState(status: SyncStatus.error);
      }
    });
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
  
  // Method called by TotpProvider when local changes happen
  Future<void> pushToCloud(List<TotpEntity> accounts) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    // Optimistic UI update could be done here, but we set status to syncing
    state = SyncState(status: SyncStatus.syncing, lastUpdatedPlatform: state.lastUpdatedPlatform, lastUpdatedTime: state.lastUpdatedTime);

    try {
      final key = await KeyManager.getKey();
      if (key == null) {
          debugPrint("Push Error: No Key found");
          return; 
      }

      final jsonString = jsonEncode(accounts.map((e) => e.toJson()).toList());
      final encryptedData = EncryptionService.encryptData(jsonString, key);
      
      String platformName = 'Generic';
      if (kIsWeb) {
        platformName = 'Web';
      } else {
        switch (defaultTargetPlatform) {
            case TargetPlatform.android: platformName = 'Android'; break;
            case TargetPlatform.iOS: platformName = 'iOS'; break;
            case TargetPlatform.windows: platformName = 'Windows'; break;
            case TargetPlatform.macOS: platformName = 'macOS'; break;
            case TargetPlatform.linux: platformName = 'Linux'; break;
            case TargetPlatform.fuchsia: platformName = 'Fuchsia'; break;
        }
      }

      await _firestore.collection('users').doc(user.uid).set({
        'encrypted_data': encryptedData,
        'timestamp': FieldValue.serverTimestamp(),
        'last_updated_platform': platformName,
      });
      
      // We don't necessarily need to set 'upToDate' here because the snapshot listener 
      // will fire and do that for us (eventually). 
      // But setting it gives immediate feedback.
      state = SyncState(status: SyncStatus.upToDate, lastUpdatedPlatform: platformName, lastUpdatedTime: DateTime.now());
      
    } catch (e) {
       debugPrint("Push Error: $e");
       state = SyncState(status: SyncStatus.error);
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);
