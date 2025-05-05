import '../../repositories/appointment_repository.dart';

class DeletePart {
  final AppointmentRepository repository;

  DeletePart(this.repository);

  Future<void> execute({
    required String workshopId,
    required String appointmentId,
    required String partId,
  }) async {
    await repository.deletePart(
      workshopId: workshopId,
      appointmentId: appointmentId,
      partId: partId,
    );
  }
}