import 'package:flutter_frontend/features/auth/domain/entities/user.dart';

class AuthResult {
  final User user;
  final String accessToken;

  const AuthResult({
    required this.user,
    required this.accessToken,
  });
}