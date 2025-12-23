import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/totp_provider.dart';
import '../widgets/otp_card.dart';
import '../providers/sync_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/edit_account_dialog.dart';
import '../../domain/entities/totp_entity.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Data
    final allTotps = ref.watch(totpProvider);
    
    // 2. Filter Data
    final filteredTotps = allTotps.where((totp) {
      final query = _searchQuery.toLowerCase();
      return totp.issuer.toLowerCase().contains(query) ||
             totp.accountName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Modern AppBar
          SliverAppBar(
            expandedHeight: 160.0,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 60), // Adjust for search bar
              title: Text(
                'Mon Coffre-fort',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20
                ), // Smaller font in collapsed state usually, but FlexibleSpaceBar handles scale
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1E1E2C),
                      const Color(0xFF1E1E2C).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
               // Sync Status
               Consumer(
                builder: (context, ref, child) {
                  final syncState = ref.watch(syncProvider);
                  IconData icon;
                  Color color;
                  String tooltip;

                  switch (syncState.status) {
                    case SyncStatus.syncing:
                      return const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        ),
                      );
                    case SyncStatus.upToDate:
                      icon = Icons.cloud_done;
                      color = const Color(0xFF00E5FF);
                      tooltip = "Synchronisé\nPlateforme: ${syncState.lastUpdatedPlatform ?? 'Inconnue'}\nHeure: ${syncState.lastUpdatedTime?.hour}:${syncState.lastUpdatedTime?.minute}";
                      break;
                    case SyncStatus.error:
                      icon = Icons.cloud_off;
                      color = Colors.redAccent;
                      tooltip = "Erreur de synchronisation";
                      break;
                    case SyncStatus.idle:
                      icon = Icons.cloud_queue;
                      color = Colors.grey;
                      tooltip = "En attente";
                      break;
                  }
                      return IconButton(
                    icon: Icon(icon, color: color),
                    tooltip: tooltip,
                    onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tooltip)));
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push('/settings'),
              ),
            ],
            // Search Bar at the bottom of AppBar
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un compte...',
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0), // Centered vertically
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), // Pill shape
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Staggered List / Grid
          SliverPadding(
            padding: const EdgeInsets.all(16), // Global padding
            sliver: filteredTotps.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          Icon(Icons.search_off, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text("Aucun compte trouvé", style: GoogleFonts.inter(color: Colors.white54)),
                        ],
                      ),
                    ),
                  )
                : SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.crossAxisExtent > 600;
                      if (isWide) {
                        return SliverGrid(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 2.2, // Adjusted for new card size
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final account = filteredTotps[index];
                              return GestureDetector(
                                onLongPress: () => _showAccountOptions(context, ref, account),
                                child: OtpCard(totp: account),
                              )
                              .animate(delay: (50 * index).ms) // Staggered Animation
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
                            },
                            childCount: filteredTotps.length,
                          ),
                        );
                      } else {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final account = filteredTotps[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onLongPress: () => _showAccountOptions(context, ref, account),
                                  child: OtpCard(totp: account),
                                ),
                              )
                              .animate(delay: (50 * index).ms) // Staggered
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
                            },
                            childCount: filteredTotps.length,
                          ),
                        );
                      }
                    },
                  ),
          ),
          
          // Extra space at bottom for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF00E5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
             final width = MediaQuery.of(context).size.width;
             if (width < 600) {
               context.push('/scan');
             } else {
               context.push('/manual');
             }
          },
          backgroundColor: Colors.transparent, // Important for gradient
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }

  void _showAccountOptions(BuildContext context, WidgetRef ref, TotpEntity account) {
     showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D44),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: Text("Modifier le compte", style: GoogleFonts.inter(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (context) => EditAccountDialog(
                    account: account,
                    onSave: (issuer, name) {
                      final updated = account.copyWith(
                        issuer: issuer,
                        accountName: name,
                      );
                      ref.read(totpProvider.notifier).updateAccount(updated);
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFFF5252)),
              title: Text("Supprimer", style: GoogleFonts.inter(color: const Color(0xFFFF5252), fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF2D2D44),
                    title: Text("Supprimer ?", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                    content: Text(
                      "Voulez-vous vraiment supprimer ${account.issuer} ?\nCette action est irréversible.",
                      style: GoogleFonts.inter(color: Colors.white70)
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Annuler", style: GoogleFonts.inter(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(totpProvider.notifier).deleteAccount(account.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Compte supprimé")),
                          );
                        },
                        child: Text("Supprimer", style: GoogleFonts.inter(color: const Color(0xFFFF5252), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
