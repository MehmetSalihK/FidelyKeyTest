import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/totp_entity.dart';
import '../providers/timer_provider.dart';
import '../../core/security/totp_service.dart';

class OtpCard extends ConsumerWidget {
  final TotpEntity totp;

  const OtpCard({super.key, required this.totp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the timer stream to rebuild every second (or 500ms)
    // The value doesn't matter, just the event triggering a rebuild
    ref.watch(timerProvider);

    // Calculate real values
    final currentCode = TotpService.generateCode(totp.secret);
    final progress = TotpService.getProgress();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Issuer Icon / Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                totp.issuer.isNotEmpty ? totp.issuer[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totp.issuer,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    totp.accountName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Animated Code
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                       return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      "${currentCode.substring(0, 3)} ${currentCode.substring(3)}",
                      key: ValueKey<String>(currentCode), // Triggers animation on change
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: progress < 0.2 
                            ? Colors.red // Turn red when expiring
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Progress & Copy
            Column(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey[200],
                        color: progress < 0.2 ? Colors.red : null,
                      ),
                      Text(
                        "${(progress * 30).toInt()}",
                        style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold,
                            color: progress < 0.2 ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: currentCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Code $currentCode copié !')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
