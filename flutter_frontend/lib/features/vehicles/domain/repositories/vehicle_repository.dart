import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getVehicles(String workshopId);
  Future<List<Vehicle>> getVehiclesForClient(String workshopId, String clientId);
  Future<Vehicle> getVehicleDetails(String workshopId, String vehicleId);
  
  Future<void> addVehicle({
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
    required String workshopId,
    required String vehicleId,
    required String make,
    required String model,
    required int year,
    required String vin,
    required String licensePlate,
    required int mileage,
  });
  
  Future<void> deleteVehicle(String workshopId, String vehicleId);
}