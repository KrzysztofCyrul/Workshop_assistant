import '../../repositories/appointment_repository.dart';
import '../../entities/part.dart';

class AddPart {
  final AppointmentRepository repository;

  AddPart(this.repository);

  Future<Part> execute({
    required String workshopId,
    required String appointmentId,
    required String name,
    required String description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  }) async {
    return await repository.addPart(
      workshopId: workshopId,
      appointmentId: appointmentId,
      name: name,
      description: description,
      quantity: quantity,
      costPart: costPart,
      costService: costService,
      buyCostPart: buyCostPart,
    );
  }
}