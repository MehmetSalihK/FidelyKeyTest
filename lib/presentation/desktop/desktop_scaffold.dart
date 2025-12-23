import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../screens/dashboard_screen.dart';

class DesktopScaffold extends ConsumerWidget {
  const DesktopScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    final List<Widget> pages = [
      const DashboardScreen(),
      const Center(child: Text("Scanner")),
      const Center(child: Text("Paramètres")),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => ref.read(navigationIndexProvider.notifier).setIndex(index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text("Dashboard")),
              NavigationRailDestination(icon: Icon(Icons.qr_code_scanner), label: Text("Scanner")),
              NavigationRailDestination(icon: Icon(Icons.settings), label: Text("Paramètres")),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Container(
              color: Colors.grey[100], // Different background as requested
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
