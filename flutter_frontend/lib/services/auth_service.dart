import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthService {
  static final _storage = FlutterSecureStorage();

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
      final data = json.decode(utf8.decode(response.bodyBytes));
      await _storage.write(key: 'accessToken', value: data['access_token']);
      await _storage.write(key: 'refreshToken', value: data['refresh_token']);
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
      final data = json.decode(utf8.decode(response.bodyBytes));
      // Zapisz tokeny tutaj, jeśli to konieczne
      await _storage.write(key: 'accessToken', value: data['access_token']);
      await _storage.write(key: 'refreshToken', value: data['refresh_token']);
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
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
    } else {
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

  static Future<void> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw Exception('Brak tokenu odświeżania');
    }

    final url = Uri.parse('$baseUrl$refreshEndpoint');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refresh_token': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      await _storage.write(key: 'accessToken', value: data['access_token']);
      await _storage.write(key: 'refreshToken', value: data['refresh_token']);
    } else {
      throw Exception('Błąd odświeżania tokena');
    }
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  static Future<String?> getWorkshopId() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Brak tokenu dostępu');
    }

    final userProfile = await getUserProfile(accessToken);
    final workshopId = userProfile['employeeProfiles']?.first['workshopId'];
    if (workshopId == null) {
      throw Exception('Brak workshopId w profilu użytkownika');
    }

    return workshopId;
  }
}
