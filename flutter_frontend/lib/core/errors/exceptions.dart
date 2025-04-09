class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ServerException({
    required this.message,
    this.statusCode,
    this.errors,
  });
}

class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = 'Brak połączenia z internetem'});
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
}