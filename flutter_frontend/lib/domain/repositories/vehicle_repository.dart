import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getVehicles(String accessToken, String workshopId);
  Future<List<Vehicle>> getVehiclesForClient(String accessToken, String workshopId, String clientId);
  Future<Vehicle> getVehicleDetails(String accessToken, String workshopId, String vehicleId);
  Future<void> addVehicle({
    required String accessToken,
    required String workshopId,
    required String clientId,
    required String make,
    required String model,
    required int year,
    required String vin,
    required String licensePlate,
    required int mileage,
  });
  Future<void> updateVehicle({
    required String accessToken,
    required String workshopId,
    required String vehicleId,
    required String make,
    required String model,
    required int year,
    required String vin,
    required String licensePlate,
    required int mileage,
  });
  Future<void> deleteVehicle(String accessToken, String workshopId, String vehicleId);
}