import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final bool showAppBar; // Optional if we want to hide back button on Welcome

  const AuthLayout({
    super.key,
    required this.child,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Desktop / Tablet: Centered Card
            return Center(
              child: Card(
                elevation: 4,
                color: Theme.of(context).inputDecorationTheme.fillColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: SizedBox(
                  width: 450,
                  height: constraints.maxHeight > 700 ? 700 : null, // Limit height or auto
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(child: child), // Center content inside card
                  ),
                ),
              ),
            );
          } else {
            // Mobile: Full screen with SafeArea
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(child: child),
              ),
            );
          }
        },
      ),
    );
  }
}
