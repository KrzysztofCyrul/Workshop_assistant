import '../repositories/appointment_repository.dart';
import '../entities/appointment.dart';

class GetAppointments {
  final AppointmentRepository repository;

  GetAppointments(this.repository);

  Future<List<Appointment>> execute(String workshopId) async {
    return await repository.getAppointments(workshopId);
  }
}