import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  User? _user;

  String? get accessToken => _accessToken;
  User? get user => _user;

  bool get isAuthenticated => _accessToken != null;

  Future<void> login(String email, String password) async {
  try {
    final data = await AuthService.login(email, password);
    _accessToken = data?['access'];
    _refreshToken = data?['refresh'];
    
    // Pobierz dane użytkownika z API
    final userData = await AuthService.getUserProfile(_accessToken!);
    _user = User.fromJson(userData);

    notifyListeners();
  } catch (e) {
    rethrow;
  }
}


  Future<void> register(Map<String, dynamic> userData) async {
    try {
      final data = await AuthService.register(userData);
      _accessToken = data?['access'];
      _refreshToken = data?['refresh'];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_refreshToken != null) {
      await AuthService.logout(_refreshToken!);
      _accessToken = null;
      _refreshToken = null;
      _user = null;
      notifyListeners();
    }
  }
}
