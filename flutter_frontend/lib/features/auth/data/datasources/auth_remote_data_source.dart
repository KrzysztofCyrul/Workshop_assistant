abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData);
  Future<void> logout(String refreshToken);
  Future<Map<String, dynamic>> getUserProfile(String accessToken);
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
}