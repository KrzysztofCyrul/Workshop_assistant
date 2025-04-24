// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/features/auth/data/datasources/auth_local_data_source.dart';

class ApiClient {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  ApiClient({
    required this.dio,
    required this.localDataSource,
  }) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await localDataSource.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final newToken = await _refreshToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              return handler.resolve(await dio.fetch(error.requestOptions));
            } catch (e) {
              await localDataSource.clearTokens();
              return handler.reject(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<String> _refreshToken() async {
    final refreshToken = await localDataSource.getRefreshToken();
    if (refreshToken == null) {
      throw AuthException(message: 'No refresh token available');
    }

    final response = await dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    await localDataSource.cacheTokens(
      response.data['access_token'],
      response.data['refresh_token'],
    );
    return response.data['access_token'];
  }
}