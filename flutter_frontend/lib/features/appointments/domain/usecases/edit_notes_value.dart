import '../repositories/appointment_repository.dart';

class EditNotesValue {
  final AppointmentRepository repository;

  EditNotesValue(this.repository);

  Future<void> execute({
    required String workshopId,
    required String appointmentId,
    required String newNotes,
  }) async {
    await repository.editNotesValue(
      workshopId: workshopId,
      appointmentId: appointmentId,
      newNotes: newNotes,
    );
  }
}