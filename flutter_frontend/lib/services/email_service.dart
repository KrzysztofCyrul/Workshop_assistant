// services/email_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // dla debugPrint
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../models/email_settings.dart';
import '../utils/constants.dart'; // <-- tu pewnie masz 'baseUrl' zdefiniowane

class EmailService {
  /// Pobiera ustawienia e-mail z backendu (host, port, user, hasło, useTls).
  static Future<EmailSettings> getEmailSettings(String accessToken, String workshopId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/email-settings/');
    debugPrint('[EmailService] GET $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('[EmailService] Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return EmailSettings.fromJson(data);
    } else {
      throw Exception(
        'Błąd podczas pobierania ustawień e-mail: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Aktualizuje ustawienia e-mail w backendzie (PUT).
  static Future<void> updateEmailSettings({
    required String accessToken,
    required String workshopId,
    required EmailSettings emailSettings,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/email-settings/');
    final body = json.encode(emailSettings.toJson());

    debugPrint('[EmailService] PUT $url');
    debugPrint('[EmailService] Request Body: $body');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint('[EmailService] Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Błąd podczas aktualizacji ustawień e-mail: ${response.body}',
      );
    }
  }

  /// Wysyła maila lokalnie, korzystając z biblioteki `mailer`.
  /// Nie ma żadnego wywołania do backendu, wszystko idzie przez SMTP.
  static Future<void> sendEmail({
    required EmailSettings emailSettings,
    required String subject,
    required String body,
    required List<String> recipients,
  }) async {
    debugPrint('[EmailService] Przygotowanie do wysyłki lokalnej...');
    debugPrint('[EmailService] SMTP host: ${emailSettings.smtpHost}');
    debugPrint('[EmailService] SMTP port: ${emailSettings.smtpPort}');
    debugPrint('[EmailService] SMTP user: ${emailSettings.smtpUser}');
    debugPrint('[EmailService] Use TLS: ${emailSettings.useTls}');
    debugPrint('[EmailService] Odbiorcy: $recipients');
    debugPrint('[EmailService] Temat: $subject');
    debugPrint('[EmailService] Treść: $body');

    // Konfiguracja serwera SMTP na bazie pobranych ustawień
    final smtpServer = SmtpServer(
      emailSettings.smtpHost,
      port: emailSettings.smtpPort,
      username: emailSettings.smtpUser,
      password: emailSettings.smtpPassword,
      ssl: emailSettings.useTls, // np. port 465
      ignoreBadCertificate: false,
      allowInsecure: false,
    );

    // Tworzymy obiekt wiadomości
    final message = Message()
      ..from = Address(emailSettings.smtpUser, emailSettings.mailFrom)
      ..recipients.addAll(recipients)
      ..subject = subject
      ..text = body; 

    debugPrint('[EmailService] Próba wysłania przez mailer...');

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
    rethrow;

  }
}
}
