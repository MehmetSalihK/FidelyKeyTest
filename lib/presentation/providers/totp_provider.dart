import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/totp_entity.dart';
import '../../data/datasources/secure_storage_service.dart';
import 'sync_provider.dart';

class TotpNotifier extends Notifier<List<TotpEntity>> {
  final _storage = SecureStorageService();

  @override
  List<TotpEntity> build() {
    // Load accounts immediately on build
    _loadAccounts();
    return []; // Return empty initially while loading
  }

  Future<void> _loadAccounts() async {
    final accounts = await _storage.loadAccounts();
    if (accounts.isNotEmpty) {
      state = accounts;
    } else {
        // Optional: Keep mock data if storage is empty for demo purposes?
        // For now, let's keep it empty to verify persistence properly.
        // Or if you want to preload mock data once:
        // state = _getMockData();
        // _storage.saveAccounts(state);
    }
  }

  Future<void> addAccount(TotpEntity account) async {
    state = [...state, account];
    await _storage.saveAccounts(state);
    // Push to Cloud
    ref.read(syncProvider.notifier).pushToCloud(state);
  }

  Future<void> deleteAccount(String id) async {
    state = state.where((account) => account.id != id).toList();
    await _storage.saveAccounts(state);
    // Push to Cloud
    ref.read(syncProvider.notifier).pushToCloud(state);
  }

  Future<void> updateAccount(TotpEntity updatedAccount) async {
    state = state.map((account) {
      if (account.id == updatedAccount.id) {
        return updatedAccount;
      }
      return account;
    }).toList();
    await _storage.saveAccounts(state);
    // Push to Cloud
    ref.read(syncProvider.notifier).pushToCloud(state);
  }

  /// Sets accounts from external source (e.g. Cloud Sync)
  Future<void> setAccounts(List<TotpEntity> accounts) async {
    state = accounts;
    await _storage.saveAccounts(state);
  }

  // Helper for mock data if needed
  /*
  List<TotpEntity> _getMockData() {
      return [ ... ];
  }
  */
}

final totpProvider = NotifierProvider<TotpNotifier, List<TotpEntity>>(TotpNotifier.new);
