import '../../repositories/appointment_repository.dart';
import '../../entities/part.dart';

class UpdatePart {
  final AppointmentRepository repository;

  UpdatePart(this.repository);

  Future<Part> execute({
    required String workshopId,
    required String appointmentId,
    required String partId,
    required String name,
    required String description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  }) async {
    return await repository.updatePart(
      workshopId: workshopId,
      appointmentId: appointmentId,
      partId: partId,
      name: name,
      description: description,
      quantity: quantity,
      costPart: costPart,
      costService: costService,
      buyCostPart: buyCostPart,
    );
  }
}
