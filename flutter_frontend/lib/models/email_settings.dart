class EmailSettings {
  final String mailFrom;
  final String smtpHost;
  final int smtpPort;
  final String smtpUser;
  final String smtpPassword;
  final bool useTls;

  EmailSettings({
    required this.mailFrom,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpUser,
    required this.smtpPassword,
    required this.useTls,
  });

  factory EmailSettings.fromJson(Map<String, dynamic> json) {
    return EmailSettings(
      mailFrom: json['mail_from'],
      smtpHost: json['smtp_host'],
      smtpPort: json['smtp_port'],
      smtpUser: json['smtp_user'],
      smtpPassword: json['smtp_password'],
      useTls: json['use_tls'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mail_from': mailFrom,
      'smtp_host': smtpHost,
      'smtp_port': smtpPort,
      'smtp_user': smtpUser,
      'smtp_password': smtpPassword,
      'use_tls': useTls,
    };
  }
}
