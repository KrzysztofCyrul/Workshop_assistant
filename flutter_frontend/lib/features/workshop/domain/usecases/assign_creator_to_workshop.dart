import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class AssignCreatorToWorkshop {
  final WorkshopRepository repository;

  AssignCreatorToWorkshop(this.repository);

  Future<void> call({
    required String workshopId,
    required String userId,
  }) async {
    return await repository.assignCreatorToWorkshop(
      workshopId: workshopId,
      userId: userId,
    );
  }
}