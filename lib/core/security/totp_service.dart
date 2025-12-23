import 'package:otp/otp.dart';


class TotpService {
  /// Generate a 6-digit TOTP code based on [secret].
  /// [interval] is usually 30 seconds.
  static String generateCode(String secret, {int interval = 30}) {
    try {
      // Ensure secret is valid base32. If not, this might throw.
      // Note: 'otp' package often takes the secret as a String directly
      // but commonly expects it in Base32 format and decodes internally or key.
      // Using OTP.generateTOTPCodeString:
      // algorithm: SHA1, isGoogle: true (Google Auth uses base32 secrets)
      return OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        interval: interval,
        algorithm: Algorithm.SHA1,
        isGoogle: true, // Expects Base32 secret
      );
    } catch (e) {
      // Fallback for invalid secrets (e.g. standard string not base32) or empty
      return '000000';
    }
  }

  /// Returns the progress of the current interval (0.0 to 1.0).
  /// 1.0 means full time remaining (start of interval), 0.0 means time up.
  static double getProgress({int interval = 30}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = interval - ((now ~/ 1000) % interval);
    return remaining / interval;
  }
}
