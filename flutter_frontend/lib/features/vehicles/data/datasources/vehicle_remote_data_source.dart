import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/core/utils/constants.dart' as api_constants;
import 'package:flutter_frontend/features/vehicles/data/models/vehicle_model.dart';

class VehicleRemoteDataSource {
  final Dio dio;

  VehicleRemoteDataSource({required this.dio});

  Future<List<VehicleModel>> getVehicles(String workshopId) async {
    try {
      final response = await dio.get(
        '${api_constants.baseUrl}/workshops/$workshopId/vehicles/'
      );
      return (response.data as List)
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<VehicleModel> getVehicleDetails(String workshopId, String vehicleId) async {
    try {
      final response = await dio.get(
        '${api_constants.baseUrl}/workshops/$workshopId/vehicles/$vehicleId/'
      );
      return VehicleModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<VehicleModel>> getVehiclesForClient(String workshopId, String clientId) async {
    try {
      final response = await dio.get(
        '${api_constants.baseUrl}/workshops/$workshopId/clients/$clientId/vehicles/'
      );
      return (response.data as List)
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
    }
  }

  Future<void> deleteVehicle(String workshopId, String vehicleId) async {
    try {
      await dio.delete(
        '${api_constants.baseUrl}/workshops/$workshopId/vehicles/$vehicleId/',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<VehicleModel>> searchVehicles(String workshopId, String query) async {
    try {
      final response = await dio.get(
        '${api_constants.baseUrl}/workshops/$workshopId/vehicles/search/',
        queryParameters: {'q': query},
      );
      return (response.data as List)
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {  // Zmieniony typ zwracany na Exception
    if (e.response?.statusCode == 401) {
      return AuthException(message: 'Session expired');
    } else if (e.response?.statusCode == 404) {
      return ServerException(message: 'Resource not found');  // Uproszczone do ServerException
    } else if (e.response?.statusCode == 400) {
      return ServerException(
        message: e.response?.data['message'] ?? 'Invalid request'
      );
    } else if (e.response?.statusCode == 403) {
      return ServerException(message: 'Access denied');
    } else if (e.response?.statusCode == 500) {
      return ServerException(message: 'Internal server error');
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout ||
               e.type == DioExceptionType.sendTimeout) {
      return ServerException(message: 'Connection timeout');
    } else if (e.type == DioExceptionType.connectionError) {
      return ServerException(message: 'No internet connection');
    }
    return ServerException(message: 'Unknown error occurred');
  }
}