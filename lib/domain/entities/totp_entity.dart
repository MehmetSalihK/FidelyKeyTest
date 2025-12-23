class TotpEntity {
  final String id;
  final String issuer;
  final String accountName;
  final String secret;
  final String currentCode;
  final double progress; // 0.0 to 1.0

  const TotpEntity({
    required this.id,
    required this.issuer,
    required this.accountName,
    required this.secret,
    required this.currentCode,
    required this.progress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issuer': issuer,
      'accountName': accountName,
      'secret': secret,
    };
  }

  factory TotpEntity.fromJson(Map<String, dynamic> json) {
    return TotpEntity(
      id: json['id'] as String,
      issuer: json['issuer'] as String,
      accountName: json['accountName'] as String,
      secret: json['secret'] as String,
      currentCode: '000000',
      progress: 1.0,
    );
  }
}
