import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetVehicleDetails {
  final VehicleRepository repository;

  GetVehicleDetails(this.repository);

  Future<Vehicle> execute(String workshopId, String vehicleId) async {
    return await repository.getVehicleDetails(workshopId, vehicleId);
  }
}