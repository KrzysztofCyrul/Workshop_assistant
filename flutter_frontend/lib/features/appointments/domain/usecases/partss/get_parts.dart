import '../../repositories/appointment_repository.dart';
import '../../entities/part.dart';

class GetParts {
  final AppointmentRepository repository;

  GetParts(this.repository);

  Future<List<Part>> execute({
    required String workshopId,
    required String appointmentId,
  }) async {
    return await repository.getParts(
      workshopId: workshopId,
      appointmentId: appointmentId,
    );
  }
}