import '../../repositories/appointment_repository.dart';
import '../../entities/repair_item.dart';

class AddRepairItem {
  final AppointmentRepository repository;

  AddRepairItem(this.repository);

  Future<RepairItem> execute({
    required String workshopId,
    required String appointmentId,
    required String description,
    required String status,
    required int order,
  }) async {
    return await repository.addRepairItem(
      workshopId: workshopId,
      appointmentId: appointmentId,
      description: description,
      status: status,
      order: order,
    );
  }
}