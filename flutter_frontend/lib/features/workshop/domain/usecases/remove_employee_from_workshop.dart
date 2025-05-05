import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class RemoveEmployeeFromWorkshop {
  final WorkshopRepository repository;

  RemoveEmployeeFromWorkshop(this.repository);

  Future<void> call({
    required String workshopId,
    required String employeeId,
  }) async {
    return await repository.removeEmployeeFromWorkshop(
      workshopId: workshopId,
      employeeId: employeeId,
    );
  }
}