import '../repositories/appointment_repository.dart';

class UpdateAppointmentStatus {
  final AppointmentRepository repository;

  UpdateAppointmentStatus(this.repository);

  Future<void> execute({
    required String workshopId,
    required String appointmentId,
    required String status,
  }) async {
    await repository.updateAppointmentStatus(
      workshopId: workshopId,
      appointmentId: appointmentId,
      status: status,
    );
  }
}