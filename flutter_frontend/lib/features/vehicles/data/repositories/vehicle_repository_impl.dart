import 'package:flutter_frontend/features/vehicles/domain/repositories/vehicle_repository.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/service_record.dart';
import '../datasources/vehicle_remote_data_source.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Vehicle>> getVehicles(String workshopId) async {
    try {
      final models = await remoteDataSource.getVehicles(workshopId);
      return models.map((model) => model.toEntity()).toList();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<Vehicle> getVehicleDetails(String workshopId, String vehicleId) async {
    try {
      final model = await remoteDataSource.getVehicleDetails(workshopId, vehicleId);
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<List<Vehicle>> getVehiclesForClient(String workshopId, String clientId) async {
    try {
      final models = await remoteDataSource.getVehiclesForClient(workshopId, clientId);
      return models.map((model) => model.toEntity()).toList();
    } on Exception {
      rethrow;
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
    } on Exception {
      rethrow;
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
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> deleteVehicle(String workshopId, String vehicleId) async {
    try {
      await remoteDataSource.deleteVehicle(workshopId, vehicleId);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<List<ServiceRecord>> getServiceRecords(String workshopId, String vehicleId) async {
    try {
      final models = await remoteDataSource.getServiceRecords(workshopId, vehicleId);
      return models.map((model) => model.toEntity()).toList();
    } on Exception {
      rethrow;
    }
  }
}
