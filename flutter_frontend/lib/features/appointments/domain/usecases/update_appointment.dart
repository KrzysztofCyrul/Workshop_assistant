import '../repositories/appointment_repository.dart';

class UpdateAppointment {
  final AppointmentRepository repository;

  UpdateAppointment(this.repository);

  Future<void> execute({
    required String workshopId,
    required String appointmentId,
    required String status,
    String? notes,
    int? mileage,
    String? recommendations,
    Duration? estimatedDuration,
    double? totalCost,
  }) async {
    await repository.updateAppointment(
      workshopId: workshopId,
      appointmentId: appointmentId,
      status: status,
      notes: notes,
      mileage: mileage,
      recommendations: recommendations,
      estimatedDuration: estimatedDuration,
      totalCost: totalCost,
    );
  }
}