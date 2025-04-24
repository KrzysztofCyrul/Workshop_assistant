import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/features/vehicles/data/mappers/vehicle_mapper.dart';
import 'package:flutter_frontend/features/vehicles/domain/repositories/vehicle_repository.dart';
import '../../domain/entities/vehicle.dart';
import '../datasources/vehicle_remote_data_source.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Vehicle>> getVehicles(String workshopId) async {
    try {
      final models = await remoteDataSource.getVehicles(workshopId);
      return models.map((model) => VehicleMapper.toEntity(model)).toList();
    } on AuthException {
      rethrow; // Przekaż wyjątki autentykacji bez zmian
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<Vehicle> getVehicleDetails(
    String workshopId, 
    String vehicleId
  ) async {
    try {
      final model = await remoteDataSource.getVehicleDetails(
        workshopId, 
        vehicleId
      );
      return VehicleMapper.toEntity(model);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<List<Vehicle>> getVehiclesForClient(
    String workshopId, 
    String clientId
  ) async {
    try {
      final models = await remoteDataSource.getVehiclesForClient(
        workshopId, 
        clientId
      );
      return models.map((model) => VehicleMapper.toEntity(model)).toList();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<void> addVehicle({
    required String workshopId,
    required String clientId,
    required String make,
    required String model,
    required int year,
    required String vin,
    required String licensePlate,
    required int mileage,
  }) async {
    try {
      await remoteDataSource.addVehicle(
        workshopId: workshopId,
        clientId: clientId,
        make: make,
        model: model,
        year: year,
        vin: vin,
        licensePlate: licensePlate,
        mileage: mileage,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<void> updateVehicle({
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
        workshopId: workshopId,
        vehicleId: vehicleId,
        make: make,
        model: model,
        year: year,
        vin: vin,
        licensePlate: licensePlate,
        mileage: mileage,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<void> deleteVehicle(
    String workshopId, 
    String vehicleId
  ) async {
    try {
      await remoteDataSource.deleteVehicle(
        workshopId, 
        vehicleId
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw _handleException(e);
    }
  }

  Exception _handleException(dynamic error) {
    if (error is ServerException) return error;
    if (error is DioException) {
      return ServerException(
        message: error.response?.data['message'] ?? 'Network request failed'
      );
    }
    return ServerException(message: 'Vehicle operation failed: ${error.toString()}');
  }
}