import '../repositories/vehicle_repository.dart';

class DeleteVehicle {
  final VehicleRepository repository;

  DeleteVehicle(this.repository);

  Future<void> execute(String workshopId, String vehicleId) async {
    await repository.deleteVehicle(workshopId, vehicleId);
  }
}