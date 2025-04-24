import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class SearchVehicles {
  final VehicleRepository repository;

  SearchVehicles(this.repository);

  Future<List<Vehicle>> execute(String workshopId, String query) async {
    final vehicles = await repository.getVehicles(workshopId);
    return vehicles.where((vehicle) =>
      vehicle.make.toLowerCase().contains(query.toLowerCase()) ||
      vehicle.model.toLowerCase().contains(query.toLowerCase()) ||
      vehicle.licensePlate.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}