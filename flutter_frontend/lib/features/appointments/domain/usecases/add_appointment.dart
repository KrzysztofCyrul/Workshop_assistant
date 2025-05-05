import '../repositories/appointment_repository.dart';

class AddAppointment {
  final AppointmentRepository repository;

  AddAppointment(this.repository);

  Future<String> execute({
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
  }) async {
    return await repository.addAppointment(
      workshopId: workshopId,
      clientId: clientId,
      vehicleId: vehicleId,
      scheduledTime: scheduledTime,
      notes: notes,
      mileage: mileage,
      recommendations: recommendations,
      estimatedDuration: estimatedDuration,
      totalCost: totalCost,
      status: status,
    );
  }
}