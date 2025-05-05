import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class UseTemporaryCode {
  final WorkshopRepository repository;

  UseTemporaryCode(this.repository);

  Future<void> call(String code) async {
    return await repository.useTemporaryCode(code: code);
  }
}