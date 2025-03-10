import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetVehicleDetailsUseCase {
  final VehicleRepository repository;

  GetVehicleDetailsUseCase(this.repository);

  Future<Vehicle> execute(String accessToken, String workshopId, String vehicleId) async {
    return await repository.getVehicleDetails(accessToken, workshopId, vehicleId);
  }
}