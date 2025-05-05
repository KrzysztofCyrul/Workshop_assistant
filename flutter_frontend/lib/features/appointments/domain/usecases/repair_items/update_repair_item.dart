import '../../repositories/appointment_repository.dart';
import '../../entities/repair_item.dart';

class UpdateRepairItem {
  final AppointmentRepository repository;

  UpdateRepairItem(this.repository);

  Future<RepairItem> execute({
    required String workshopId,
    required String appointmentId,
    required String repairItemId,
    required String description,
    required String status,
    required int order,
    bool? isCompleted,
  }) async {
    return await repository.updateRepairItem(
      workshopId: workshopId,
      appointmentId: appointmentId,
      repairItemId: repairItemId,
      description: description,
      status: status,
      order: order,
      isCompleted: isCompleted,
    );
  }
}