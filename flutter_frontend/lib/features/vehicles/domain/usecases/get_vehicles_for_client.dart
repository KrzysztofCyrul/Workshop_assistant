import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetVehiclesForClient {
  final VehicleRepository repository;

  GetVehiclesForClient(this.repository);

  Future<List<Vehicle>> execute(String workshopId, String clientId) async {
    return await repository.getVehiclesForClient(workshopId, clientId);
  }
}