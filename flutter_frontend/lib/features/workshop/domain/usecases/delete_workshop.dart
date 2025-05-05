import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class DeleteWorkshop {
  final WorkshopRepository repository;

  DeleteWorkshop(this.repository);

  Future<void> call(String workshopId) async {
    return await repository.deleteWorkshop(workshopId);
  }
}