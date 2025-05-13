import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';

class DioErrorHandler {
  static Exception handle(DioException e) {
    final responseData = e.response?.data;
    String errorMessage;
    
    if (responseData != null && responseData is Map<String, dynamic>) {
      errorMessage = responseData['message'] ?? responseData['detail'] ?? 
                    responseData.values.firstWhere(
                      (v) => v is String, 
                      orElse: () => 'Unknown error'
                    ).toString();
    } else {
      errorMessage = 'Unknown error occurred';
    }

    if (e.response?.statusCode == 401) {
      return AuthException(message: errorMessage);
    } else if (e.response?.statusCode == 404) {
      return ServerException(message: 'Resource not found: $errorMessage');
    } else if (e.response?.statusCode == 400) {
      return ServerException(message: errorMessage);
    } else if (e.response?.statusCode == 403) {
      return ServerException(message: 'Access denied: $errorMessage');
    } else if (e.response?.statusCode == 500) {
      return ServerException(message: 'Internal server error: $errorMessage');
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout ||
               e.type == DioExceptionType.sendTimeout) {
      return ServerException(message: 'Connection timeout');
    } else if (e.type == DioExceptionType.connectionError) {
      return ServerException(message: 'No internet connection');
    }
    return ServerException(message: errorMessage);
  }
}