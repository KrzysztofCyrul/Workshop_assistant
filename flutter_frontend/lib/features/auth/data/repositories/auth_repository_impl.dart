import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/core/network/network_info.dart';
import 'package:flutter_frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_frontend/features/auth/domain/entities/user.dart';
import 'package:flutter_frontend/features/auth/domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'package:flutter_frontend/features/auth/domain/entities/auth_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<AuthResult> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final tokens = await remoteDataSource.login(email, password);
        await localDataSource.cacheTokens(tokens['access'], tokens['refresh']);
        final user = await getUserProfile();
        return AuthResult(
          user: user,
          accessToken: tokens['access'],
        );
      } on ServerException catch (e) {
        throw AuthException(message: e.message);
      }
    }
    throw NetworkException();
  }

  @override
  Future<void> register(Map<String, dynamic> userData) async {
    if (await networkInfo.isConnected) {
      await remoteDataSource.register(userData);
    } else {
      throw NetworkException();
    }
  }

@override
Future<User> getUserProfile() async {
  final accessToken = await localDataSource.getAccessToken();
  if (accessToken == null) {
    throw AuthException(message: 'Not authenticated');
  }

  try {
    final userData = await remoteDataSource.getUserProfile(accessToken);
    return UserModel.fromJson(userData).toEntity();
  } on AuthException catch (_) {
    // Token wygasł - próbuj odświeżyć
    final newToken = await _refreshToken();
    final userData = await remoteDataSource.getUserProfile(newToken);
    return UserModel.fromJson(userData).toEntity();
  }
}

  @override
  Future<void> logout() async {
    final refreshToken = await localDataSource.getRefreshToken();
    if (refreshToken != null) {
      await remoteDataSource.logout(refreshToken);
    }
    await localDataSource.clearTokens();
  }

  Future<String> _refreshToken() async {
  final refreshToken = await localDataSource.getRefreshToken();
  if (refreshToken == null) {
    throw AuthException(message: 'No refresh token available');
  }

  try {
    final newTokens = await remoteDataSource.refreshToken(refreshToken);
    await localDataSource.cacheTokens(newTokens['access'], newTokens['refresh']);
    return newTokens['access'];
  } catch (e) {
    await localDataSource.clearTokens(); // Czyść tokeny przy niepowodzeniu
    throw AuthException(message: 'Token refresh failed');
  }
}
}