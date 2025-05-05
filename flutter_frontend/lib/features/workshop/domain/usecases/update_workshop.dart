import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class UpdateWorkshop {
  final WorkshopRepository repository;

  UpdateWorkshop(this.repository);

  Future<void> call({
    required String workshopId,
    required String name,
    required String address,
    required String postCode,
    required String nipNumber,
    required String email,
    required String phoneNumber,
  }) async {
    return await repository.updateWorkshop(
      workshopId: workshopId,
      name: name,
      address: address,
      postCode: postCode,
      nipNumber: nipNumber,
      email: email,
      phoneNumber: phoneNumber,
    );
  }
}