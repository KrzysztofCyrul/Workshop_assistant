import 'package:flutter/material.dart';
import '../data/models/email_settings.dart';
import '../services/email_service.dart';

class EmailProvider with ChangeNotifier {
  EmailSettings? _emailSettings;
  bool _isLoading = false;
  String? _errorMessage;

  EmailSettings? get emailSettings => _emailSettings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Pobieranie ustawień e-mail z backendu
  Future<void> fetchEmailSettings(String accessToken, String workshopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _emailSettings = await EmailService.getEmailSettings(accessToken, workshopId);
    } catch (e) {
      _errorMessage = 'Błąd podczas pobierania ustawień e-mail: $e';
      _emailSettings = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aktualizacja ustawień w backendzie
  Future<void> updateEmailSettings(
    String accessToken,
    String workshopId,
    EmailSettings emailSettings,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await EmailService.updateEmailSettings(
        accessToken: accessToken,
        workshopId: workshopId,
        emailSettings: emailSettings,
      );
      _emailSettings = emailSettings;
    } catch (e) {
      _errorMessage = 'Błąd podczas aktualizacji ustawień e-mail: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Wysyłanie maila **lokalnie** z użyciem ustawień SMTP
  Future<void> sendEmailLocally({
    required String subject,
    required String body,
    required List<String> recipients,
  }) async {
    if (_emailSettings == null) {
      throw Exception('Brak ustawień e-mail. Najpierw pobierz je z backendu.');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final validEmails = <String>[];
final invalidEmails = <String>[];

for (final email in recipients) {
  if (_isValidEmail(email)) {
    validEmails.add(email);
  } else {
    invalidEmails.add(email);
  }
}

// Wyślij tylko do poprawnych
if (validEmails.isNotEmpty) {
  await EmailService.sendEmail(
    emailSettings: _emailSettings!,
    subject: subject,
    body: body,
    recipients: validEmails,
  );
}

if (invalidEmails.isNotEmpty) {
  // Poinformuj np. w _errorMessage albo pokaż w UI
  _errorMessage = 'Następujące adresy są niepoprawne i pominięte: $invalidEmails';
  notifyListeners();
}

    } catch (e, st) {
      _errorMessage = 'Błąd podczas wysyłania wiadomości: $e';
      debugPrint('[EmailProvider] StackTrace: $st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Przykładowa prosta walidacja adresu e-mail.
  /// Lepiej użyć pakietu `email_validator`, ale jeśli nie chcesz,
  /// możesz użyć tej prostej regexowej metody.
  bool _isValidEmail(String email) {
    // Bardzo podstawowy regex:
    const pattern = r'^[^@]+@[^@]+\.[^@]+$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }
}
