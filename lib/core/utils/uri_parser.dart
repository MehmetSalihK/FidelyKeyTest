import '../../domain/entities/totp_entity.dart';

TotpEntity parseTotpUri(String uriString) {
  final uri = Uri.parse(uriString);

  if (uri.scheme != 'otpauth' || uri.host != 'totp') {
    throw const FormatException("Invalid OTP URI scheme or host");
  }

  // Path often contains /Issuer:Account or /Account
  // Example: /Google:mehmet@gmail.com
  String path = uri.path;
  if (path.startsWith('/')) {
    path = path.substring(1);
  }

  String issuer = '';
  String accountName = path;

  if (path.contains(':')) {
    final parts = path.split(':');
    if (parts.length == 2) {
      issuer = parts[0];
      accountName = parts[1];
    }
  }

  // Query parameters take precedence for issuer
  final queryIssuer = uri.queryParameters['issuer'];
  if (queryIssuer != null && queryIssuer.isNotEmpty) {
    issuer = queryIssuer;
  }

  final secret = uri.queryParameters['secret'];
  if (secret == null || secret.isEmpty) {
    throw const FormatException("Missing secret in OTP URI");
  }

  return TotpEntity(
    id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID generation
    issuer: issuer.isNotEmpty ? issuer : 'Unknown',
    accountName: accountName,
    secret: secret,
    currentCode: '000000', // Default initial code
    progress: 1.0,
  );
}
