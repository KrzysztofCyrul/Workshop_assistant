import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/core/utils/constants.dart' as api_constants;
import 'package:flutter_frontend/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});


  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('${api_constants.baseUrl}/login/'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      throw ServerException(message: 'Błąd logowania');
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await client.post(
      Uri.parse('${api_constants.baseUrl}/register/'),
      body: userData,
    );

    if (response.statusCode != 201) {
      throw ServerException(message: 'Błąd rejestracji');
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }

  @override
  Future<void> logout(String refreshToken) async {
    final response = await client.post(
      Uri.parse('${api_constants.baseUrl}/logout/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) {
      throw ServerException(message: 'Błąd wylogowania');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    final response = await client.get(
      Uri.parse('${api_constants.baseUrl}/user/profile/'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw ServerException(message: 'Błąd pobierania profilu użytkownika');
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }
}