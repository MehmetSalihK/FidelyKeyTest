import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/totp_provider.dart';
import '../../../domain/entities/totp_entity.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _accountController = TextEditingController();
  final _secretController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajout Manuel")),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _issuerController,
                  decoration: const InputDecoration(labelText: "Service / Émetteur (ex: Google)"),
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountController,
                  decoration: const InputDecoration(labelText: "Compte / Email"),
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _secretController,
                  decoration: const InputDecoration(labelText: "Clé Secrète"),
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Enregistrer"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newAccount = TotpEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        issuer: _issuerController.text,
        accountName: _accountController.text,
        secret: _secretController.text,
        currentCode: '000000',
        progress: 1.0,
      );

      ref.read(totpProvider.notifier).addAccount(newAccount);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compte ajouté !")),
      );
      context.pop();
    }
  }
}
