import 'package:flutter/material.dart';
import '../../domain/entities/totp_entity.dart';

class EditAccountDialog extends StatefulWidget {
  final TotpEntity account;
  final Function(String issuer, String accountName) onSave;

  const EditAccountDialog({
    super.key,
    required this.account,
    required this.onSave,
  });

  @override
  State<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends State<EditAccountDialog> {
  late TextEditingController _issuerController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _issuerController = TextEditingController(text: widget.account.issuer);
    _nameController = TextEditingController(text: widget.account.accountName);
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modifier le compte"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _issuerController,
            decoration: const InputDecoration(labelText: "Service (ex: Google)"),
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Nom du compte (ex: email)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_issuerController.text, _nameController.text);
            Navigator.of(context).pop();
          },
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }
}
