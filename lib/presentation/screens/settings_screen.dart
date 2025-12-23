import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: ListView(
        children: [
          if (authState.user != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Compte"),
              subtitle: Text(authState.user?.email ?? "Utilisateur"),
            ),
          if (authState.user != null)
            const Divider(),
          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("À propos"),
            subtitle: const Text("FidelyKey v1.0.0"), // Could use PackageInfo here
          ),
          
          const Divider(),
          
          if (authState.user != null)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Se déconnecter", style: TextStyle(color: Colors.red)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Déconnexion"),
                    content: const Text("Voulez-vous vraiment vous déconnecter ? La clé de chiffrement sera effacée de la mémoire."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Se déconnecter")),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/'); // Return to home (which might be dashboard or login depending on flow)
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Déconnecté")));
                  }
                }
              },
            )
          else
             ListTile(
              leading: const Icon(Icons.login),
              title: const Text("Se connecter"),
              onTap: () => context.push('/login'),
            ),
        ],
      ),
    );
  }
}
