import '../repositories/appointment_repository.dart';
import '../entities/appointment.dart';

class GetAppointmentDetails {
  final AppointmentRepository repository;

  GetAppointmentDetails(this.repository);

  Future<Appointment> execute(String workshopId, String appointmentId) async {
    return await repository.getAppointmentDetails(workshopId, appointmentId);
  }
}