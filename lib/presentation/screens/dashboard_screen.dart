import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/totp_provider.dart';
import '../widgets/otp_card.dart';
import '../../core/security/encryption_service.dart';
import '../../data/datasources/cloud_storage_service.dart';
import '../providers/auth_provider.dart';
import 'dart:convert';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockTotps = ref.watch(totpProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FidelyKey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
              final authState = ref.read(authProvider);
              final accounts = ref.read(totpProvider);

              if (authState.user == null) {
                // Show Login Dialog
                _showLoginDialog(context, ref);
              } else {
                // Sync
                if (authState.encryptionKey == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Clé de chiffrement manquante (Reconnectez-vous)."))
                  );
                  return;
                }
                
                try {
                  final jsonString = jsonEncode(accounts.map((e) => e.toJson()).toList());
                  final encrypted = EncryptionService.encryptData(jsonString, authState.encryptionKey!);
                  
                  await CloudStorageService().uploadBackup(authState.user!.uid, encrypted);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sauvegarde chiffrée réussie !")),
                    );
                  }
                } catch (e) {
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur de sauvegarde : $e")),
                    );
                   }
                }
              }
            },
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile View: ListView
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: mockTotps.length,
              itemBuilder: (context, index) {
                return OtpCard(totp: mockTotps[index]);
              },
            );
          } else {
            // Desktop View: GridView
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 2.5, // Ratio to make cards look like cards, not squares
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: mockTotps.length,
              itemBuilder: (context, index) {
                return OtpCard(totp: mockTotps[index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Check if Desktop or Mobile for navigation
          final width = MediaQuery.of(context).size.width;
          if (width < 600) {
            context.push('/scan');
          } else {
            context.push('/manual');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  void _showLoginDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Connexion / Inscription"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Connectez-vous pour sauvegarder vos comptes (Zero-Knowledge)."),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await ref.read(authProvider.notifier).signUp(
                  emailController.text, 
                  passwordController.text
                );
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte créé ! Cliquez à nouveau sur Sync.")));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
                }
              }
            },
            child: const Text("S'inscrire"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(authProvider.notifier).login(
                  emailController.text, 
                  passwordController.text
                );
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connecté ! Cliquez à nouveau sur Sync.")));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
                }
              }
            },
            child: const Text("Se connecter"),
          ),
        ],
      ),
    );
  }
}
