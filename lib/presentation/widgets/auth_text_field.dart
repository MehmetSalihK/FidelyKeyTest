import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(
            prefixIcon,
            color: theme.colorScheme.primary, // Accent color icon
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          // Borders are handled by the global theme in main.dart
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
