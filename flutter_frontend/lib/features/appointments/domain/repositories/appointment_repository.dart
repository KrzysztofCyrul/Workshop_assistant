import '../entities/appointment.dart';
import '../entities/part.dart';
import '../entities/repair_item.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments(String workshopId);

  Future<Appointment> getAppointmentDetails(String workshopId, String appointmentId);

  Future<String> addAppointment({
    required String workshopId,
    required String clientId,
    required String vehicleId,
    required DateTime scheduledTime,
    String? notes,
    required int mileage,
    String? recommendations,
    Duration? estimatedDuration,
    double? totalCost,
    required String status,
  });

  Future<void> updateAppointment({
    required String workshopId,
    required String appointmentId,
    required String status,
    String? notes,
    int? mileage,
    String? recommendations,
    Duration? estimatedDuration,
    double? totalCost,
  });

  Future<void> deleteAppointment(String workshopId, String appointmentId);

  Future<void> editNotesValue({
    required String workshopId,
    required String appointmentId,
    required String newNotes,
  });

  Future<List<RepairItem>> getRepairItems({
    required String workshopId,
    required String appointmentId,
  });

  Future<RepairItem> addRepairItem({
    required String workshopId,
    required String appointmentId,
    required String description,
    required String status,
    required int order,
  });

  Future<RepairItem> updateRepairItem({
    required String workshopId,
    required String appointmentId,
    required String repairItemId,
    required String description,
    required String status,
    required int order,
    bool? isCompleted,
  });

  Future<void> deleteRepairItem({
    required String workshopId,
    required String appointmentId,
    required String repairItemId,
  });

  Future<List<Part>> getParts({
    required String workshopId,
    required String appointmentId,
  });

  Future<Part> addPart({
    required String workshopId,
    required String appointmentId,
    required String name,
    required String description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  });

  Future<Part> updatePart({
    required String workshopId,
    required String appointmentId,
    required String partId,
    required String name,
    required String description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  });

  Future<void> deletePart({
    required String workshopId,
    required String appointmentId,
    required String partId,
  });
}
