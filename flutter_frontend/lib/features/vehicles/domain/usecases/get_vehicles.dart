import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetVehicles {
  final VehicleRepository repository;

  GetVehicles(this.repository);

  Future<List<Vehicle>> execute(String accessToken, String workshopId) async {
    return await repository.getVehicles(accessToken, workshopId);
  }
}