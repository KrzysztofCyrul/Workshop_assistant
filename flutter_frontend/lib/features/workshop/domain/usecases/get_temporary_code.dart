import 'package:flutter_frontend/features/workshop/domain/entities/temporary_code.dart';
import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class GetTemporaryCode {
  final WorkshopRepository repository;

  GetTemporaryCode(this.repository);

  Future<TemporaryCode> call(String workshopId) async {
    return await repository.getTemporaryCode(workshopId);
  }
}