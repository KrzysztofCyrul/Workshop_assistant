import '../../repositories/appointment_repository.dart';
import '../../entities/repair_item.dart';

class GetRepairItems {
  final AppointmentRepository repository;

  GetRepairItems(this.repository);

  Future<List<RepairItem>> execute({
    required String workshopId,
    required String appointmentId,
  }) async {
    return await repository.getRepairItems(
      workshopId: workshopId,
      appointmentId: appointmentId,
    );
  }
}