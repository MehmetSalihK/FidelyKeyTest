import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/totp_entity.dart';
import '../providers/timer_provider.dart';
import '../../core/security/totp_service.dart';
import '../../core/utils/logo_helper.dart';

class OtpCard extends ConsumerWidget {
  final TotpEntity totp;

  const OtpCard({super.key, required this.totp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to timer for updates
    ref.watch(timerProvider);

    // Calculate values
    final currentCode = TotpService.generateCode(totp.secret);
    final progress = TotpService.getProgress();
    final remainingSeconds = (progress * 30).toInt();

    // Determine color based on time
    Color timerColor = Colors.greenAccent;
    if (remainingSeconds < 15) timerColor = Colors.orangeAccent;
    if (remainingSeconds < 5) timerColor = Colors.redAccent;

    return Animate(
      effects: const [FadeEffect(), SlideEffect(begin: Offset(0, 0.1), end: Offset.zero)],
      child: GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: currentCode));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Code ${totp.issuer} copié !'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Theme.of(context).primaryColor,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Logo (Left)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Builder(
                    builder: (context) {
                       final logoUrl = LogoHelper.getLogoUrl(totp.issuer);
                       if (logoUrl.isNotEmpty) {
                         return SvgPicture.network(
                           logoUrl,
                           fit: BoxFit.scaleDown,
                           width: 32,
                           height: 32,
                           placeholderBuilder: (context) => Center(
                              child: Text(
                                totp.issuer.isNotEmpty ? totp.issuer[0].toUpperCase() : '?',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                              ),
                           ),
                         );
                       }
                       return Center(
                          child: Text(
                            totp.issuer.isNotEmpty ? totp.issuer[0].toUpperCase() : '?',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                          ),
                       );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 20),

              // 2. Info & Code (Center)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      totp.issuer,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      totp.accountName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Monospaced Code
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${currentCode.substring(0, 3)} ${currentCode.substring(3)}",
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: timerColor, // Code changes color too? Or keep white, only timer change? User asked timer color. Let's make code white or primary, maybe code turns red at end?
                          // "Il doit changer de couleur : Vert (>15s), Orange (<15s), Rouge (<5s)." -> Usually refers to the timer, but code color sync is nice feedback.
                        ),
                      ),
                    ).animate(key: ValueKey(currentCode)).fadeIn(duration: 200.ms),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 3. Timer (Right)
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                    ),
                    Text(
                      "$remainingSeconds",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
