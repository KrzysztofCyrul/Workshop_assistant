import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheTokens(String accessToken, String refreshToken) async {
    await secureStorage.write(key: 'accessToken', value: accessToken);
    await secureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() => secureStorage.read(key: 'accessToken');

  @override
  Future<String?> getRefreshToken() => secureStorage.read(key: 'refreshToken');

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
  }
}