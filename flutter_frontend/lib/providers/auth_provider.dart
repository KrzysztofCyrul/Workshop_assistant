import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../data/models/user.dart';

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
      try {
        await AuthService.logout(_refreshToken!);
        _accessToken = null;
        _refreshToken = null;
        notifyListeners();
      } catch (e) {
        throw Exception('Błąd wylogowania: $e');
      }
    } else {
      throw Exception('Brak tokenu odświeżania');
    }
  }

  Future<void> refreshUserProfile() async {
  if (_accessToken != null) {
    try {
      final userData = await AuthService.getUserProfile(_accessToken!);
      _user = User.fromJson(userData);
      notifyListeners();
    } catch (e) {
      throw Exception('Błąd odświeżania profilu: $e');
    }
  }
}

bool get isWorkshopOwnerWithoutWorkshop {
  final isOwner = user?.roles.contains('workshop_owner') ?? false;
  final hasWorkshop = user?.employeeProfiles.isNotEmpty ?? false;
  return isOwner && !hasWorkshop;
}
}
