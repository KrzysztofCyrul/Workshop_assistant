import '../repositories/vehicle_repository.dart';

class UpdateVehicle {
  final VehicleRepository repository;

  UpdateVehicle(this.repository);

  Future<void> execute({
    required String workshopId,
    required String vehicleId,
    required String make,
    required String model,
    required int year,
    required String vin,
    required String licensePlate,
    required int mileage,
  }) async {
    await repository.updateVehicle(
      workshopId: workshopId,
      vehicleId: vehicleId,
      make: make,
      model: model,
      year: year,
      vin: vin,
      licensePlate: licensePlate,
      mileage: mileage,
    );
  }
}