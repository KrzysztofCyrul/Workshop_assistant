import 'package:flutter/material.dart';
import '../../services/temporary_code_service.dart';

class GenerateCodeProvider with ChangeNotifier {
  final TemporaryCodeService _temporaryCodeService = TemporaryCodeService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _generatedCode;
  DateTime? _expiresAt;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get generatedCode => _generatedCode;
  DateTime? get expiresAt => _expiresAt;

  Future<void> generateCode(String workshopId, String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    _generatedCode = null;
    _expiresAt = null;
    notifyListeners();

    try {
      final result = await _temporaryCodeService.generateCode(workshopId, accessToken);

      if (result['success']) {
        _generatedCode = result['code'];
        _expiresAt = result['expiresAt'];
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Wystąpił błąd. Spróbuj ponownie.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    notifyListeners();
  }
}