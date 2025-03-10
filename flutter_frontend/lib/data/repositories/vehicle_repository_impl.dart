import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/domain/repositories/vehicle_repository.dart';

import '../../domain/entities/vehicle.dart';
import '../data_sources/remote/vehicle_remote_data_source.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Vehicle>> getVehicles(String accessToken, String workshopId) async {
    final models = await remoteDataSource.getVehicles(accessToken, workshopId);
    return models.map((model) => model as Vehicle).toList();
  }

  @override
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
  }) async {
    await remoteDataSource.addVehicle(
      accessToken: accessToken,
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

  @override
  Future<Vehicle> getVehicleDetails(String accessToken, String workshopId, String vehicleId) async {
    final model = await remoteDataSource.getVehicleDetails(accessToken, workshopId, vehicleId);
    return model as Vehicle;
  }

  @override
  Future<List<Vehicle>> getVehiclesForClient(String accessToken, String workshopId, String clientId) async {
    final models = await remoteDataSource.getVehiclesForClient(accessToken, workshopId, clientId);
    return models.map((model) => model as Vehicle).toList();
  }
  
@override
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
  }) async {
    try {
      await remoteDataSource.updateVehicle(
        accessToken: accessToken,
        workshopId: workshopId,
        vehicleId: vehicleId,
        make: make,
        model: model,
        year: year,
        vin: vin,
        licensePlate: licensePlate,
        mileage: mileage,
      );
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<void> deleteVehicle(String accessToken, String workshopId, String vehicleId) async {
    try {
      await remoteDataSource.deleteVehicle(accessToken, workshopId, vehicleId);
    } catch (e) {
      throw _handleException(e);
    }
  }

  Exception _handleException(dynamic error) {
    if (error is ServerException) return error;
    return ServerException(message: 'Failed to process vehicle data: $error');
  }
}
