import '../entities/user.dart';
import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<void> register(Map<String, dynamic> userData);
  Future<void> logout();
  Future<User> getUserProfile();
}