import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/core/utils/constants.dart' as api_constants;
import 'package:flutter_frontend/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  // Metoda pomocnicza do tworzenia nagłówków
  Map<String, String> _getHeaders({String? accessToken}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  // Metoda pomocnicza do obsługi odpowiedzi
  Map<String, dynamic> _handleResponse(http.Response response, String errorMessage) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 401) {
      throw AuthException(message: 'Unauthorized');
    } else {
      throw ServerException(
        message: '$errorMessage. Status code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('${api_constants.baseUrl}/login/'),
      headers: _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response, 'Błąd logowania');
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await client.post(
      Uri.parse('${api_constants.baseUrl}/register/'),
      headers: _getHeaders(),
      body: jsonEncode(userData),
    );
    return _handleResponse(response, 'Błąd rejestracji');
  }

  @override
  Future<void> logout(String refreshToken) async {
    final response = await client.post(
      Uri.parse('${api_constants.baseUrl}/logout/'),
      headers: _getHeaders(),
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    _handleResponse(response, 'Błąd wylogowania');
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    final response = await client.get(
      Uri.parse('${api_constants.baseUrl}/user/profile/'),
      headers: _getHeaders(accessToken: accessToken),
    );
    return _handleResponse(response, 'Błąd pobierania profilu użytkownika');
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await client.post(
      Uri.parse('${api_constants.baseUrl}/refresh/'),
      headers: _getHeaders(),
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    return _handleResponse(response, 'Błąd odświeżania tokena');
  }
}