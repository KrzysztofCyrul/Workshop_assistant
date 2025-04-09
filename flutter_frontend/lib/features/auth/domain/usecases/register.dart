import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<void> execute(Map<String, dynamic> userData) async {
    return await repository.register(userData);
  }
}