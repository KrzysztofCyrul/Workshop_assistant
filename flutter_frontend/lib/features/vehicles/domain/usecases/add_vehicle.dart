import '../repositories/vehicle_repository.dart';

class AddVehicle {
  final VehicleRepository repository;

  AddVehicle(this.repository);

  Future<void> execute({
    required String workshopId,
    required String clientId,
    required String make,
    required String model,
    required int year,
    required String vin,
    required String licensePlate,
    required int mileage,
  }) async {
    await repository.addVehicle(
      workshopId: workshopId,
      clientId: clientId,
      make: make,
      model: model,
      year: year,
      vin: vin,
      licensePlate: licensePlate,
      mileage: mileage,
    );
  }
}