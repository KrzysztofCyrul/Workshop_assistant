import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/utils/constants.dart' as api_constants;
import 'package:flutter_frontend/features/vehicles/data/models/vehicle_model.dart';
import 'package:flutter_frontend/features/vehicles/data/models/service_record_model.dart';
import 'package:flutter_frontend/core/errors/dio_error_handler.dart';

class VehicleRemoteDataSource {
  final Dio dio;

  VehicleRemoteDataSource({required this.dio});

  Future<List<VehicleModel>> getVehicles(String workshopId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/vehicles/');
      return (response.data as List).map((json) => VehicleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<VehicleModel> getVehicleDetails(String workshopId, String vehicleId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/vehicles/$vehicleId/');
      return VehicleModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<List<VehicleModel>> getVehiclesForClient(String workshopId, String clientId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/clients/$clientId/vehicles/');
      return (response.data as List).map((json) => VehicleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

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
      await dio.post(
        '${api_constants.baseUrl}/workshops/$workshopId/clients/$clientId/vehicles/',
        data: {
          'make': make,
          'model': model,
          'year': year,
          'vin': vin,
          'license_plate': licensePlate,
          'mileage': mileage,
        },
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

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
      await dio.put(
        '${api_constants.baseUrl}/workshops/$workshopId/vehicles/$vehicleId/',
        data: {
          'make': make,
          'model': model,
          'year': year,
          'vin': vin,
          'license_plate': licensePlate,
          'mileage': mileage,
        },
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> deleteVehicle(String workshopId, String vehicleId) async {
    try {
      await dio.delete(
        '${api_constants.baseUrl}/workshops/$workshopId/vehicles/$vehicleId/',
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<List<VehicleModel>> searchVehicles(String workshopId, String query) async {
    try {
      final response = await dio.get(
        '${api_constants.baseUrl}/workshops/$workshopId/vehicles/search/',
        queryParameters: {'q': query},
      );
      return (response.data as List).map((json) => VehicleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<List<ServiceRecordModel>> getServiceRecords(String workshopId, String vehicleId) async {
    try {
      final response = await dio.get(
        '${api_constants.baseUrl}/workshops/$workshopId/vehicles/$vehicleId/service-records/',
      );
      return (response.data as List).map((json) => ServiceRecordModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
