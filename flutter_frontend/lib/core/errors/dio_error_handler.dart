import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';

class DioErrorHandler {
  static Exception handle(DioException e) {
    if (e.response?.statusCode == 401) {
      return AuthException(message: 'Session expired');
    } else if (e.response?.statusCode == 404) {
      return ServerException(message: 'Resource not found');
    } else if (e.response?.statusCode == 400) {
      return ServerException(
        message: e.response?.data['message'] ?? 'Invalid request'
      );
    } else if (e.response?.statusCode == 403) {
      return ServerException(message: 'Access denied');
    } else if (e.response?.statusCode == 500) {
      return ServerException(message: 'Internal server error');
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout ||
               e.type == DioExceptionType.sendTimeout) {
      return ServerException(message: 'Connection timeout');
    } else if (e.type == DioExceptionType.connectionError) {
      return ServerException(message: 'No internet connection');
    }
    return ServerException(message: 'Unknown error occurred');
  }
}