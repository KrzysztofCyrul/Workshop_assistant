import 'package:flutter/material.dart';
import '../../services/temporary_code_service.dart';

class TemporaryCodeProvider with ChangeNotifier {
  final TemporaryCodeService _temporaryCodeService = TemporaryCodeService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> useCode(String code, String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _temporaryCodeService.useCode(code, accessToken);

      if (result['success']) {
        _successMessage = result['message'];
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
    _successMessage = null;
    notifyListeners();
  }
}