import '../../repositories/appointment_repository.dart';

class DeleteRepairItem {
  final AppointmentRepository repository;

  DeleteRepairItem(this.repository);

  Future<void> execute({
    required String workshopId,
    required String appointmentId,
    required String repairItemId,
  }) async {
    return await repository.deleteRepairItem(
      workshopId: workshopId,
      appointmentId: appointmentId,
      repairItemId: repairItemId,
    );
  }
}