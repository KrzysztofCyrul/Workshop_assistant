import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> register(Map<String, dynamic> userData);
  Future<void> logout();
  Future<User> getUserProfile();
}