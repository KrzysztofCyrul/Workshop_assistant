import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl$loginEndpoint');
    final response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Zapisz tokeny tutaj, jeśli to konieczne
      return data;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Błąd logowania');
    }
  }

  static Future<Map<String, dynamic>?> register(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl$registerEndpoint');
    final response = await http.post(
      url,
      body: userData,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Zapisz tokeny tutaj, jeśli to konieczne
      return data;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['errors'] ?? 'Błąd rejestracji');
    }
  }

  static Future<void> logout(String refreshToken) async {
    final url = Uri.parse('$baseUrl$logoutEndpoint');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refresh_token': refreshToken,
      }),
    );

    if (response.statusCode != 205) {
      final errorData = jsonDecode(response.body);
      throw Exception('Błąd wylogowania: ${errorData['error'] ?? 'Nieznany błąd'}');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    final url = Uri.parse('$baseUrl/user/profile/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Błąd pobierania profilu użytkownika');
    }
  }

}
