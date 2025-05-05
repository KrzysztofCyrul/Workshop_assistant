import '../repositories/appointment_repository.dart';

class DeleteAppointment {
  final AppointmentRepository repository;

  DeleteAppointment(this.repository);

  Future<void> execute(String workshopId, String appointmentId) async {
    await repository.deleteAppointment(workshopId, appointmentId);
  }
}