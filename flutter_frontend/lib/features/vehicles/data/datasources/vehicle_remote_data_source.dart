import 'dart:convert';
import 'package:flutter_frontend/core/errors/exceptions.dart';
import 'package:flutter_frontend/features/vehicles/data/models/vehicle_model.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';

class VehicleRemoteDataSource {
  final http.Client client;

  VehicleRemoteDataSource({required this.client});

  Future<List<VehicleModel>> getVehicles(String accessToken, String workshopId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/workshops/$workshopId/vehicles/'),
      headers: _buildHeaders(accessToken),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List;
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    }
    throw ServerException(message: 'Failed to load vehicles');
  }

   Future<VehicleModel> getVehicleDetails(String accessToken, String workshopId, String vehicleId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/workshops/$workshopId/vehicles/$vehicleId/'),
      headers: _buildHeaders(accessToken),
    );

    if (response.statusCode == 200) {
      return VehicleModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    }
    throw ServerException(message: 'Failed to load vehicle details');
  }

  Future<List<VehicleModel>> getVehiclesForClient(String accessToken, String workshopId, String clientId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/workshops/$workshopId/clients/$clientId/vehicles/'),
      headers: _buildHeaders(accessToken),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List;
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    }
    throw ServerException(message: 'Failed to load client vehicles');
  }

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
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/workshops/$workshopId/clients/$clientId/vehicles/'),
      headers: _buildHeaders(accessToken),
      body: json.encode({
        'make': make,
        'model': model,
        'year': year,
        'vin': vin,
        'license_plate': licensePlate,
        'mileage': mileage,
      }),
    );

    if (response.statusCode != 201) {
      throw ServerException(message: 'Failed to add vehicle');
    }
  }
  
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
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/workshops/$workshopId/vehicles/$vehicleId/'),
      headers: _buildHeaders(accessToken),
      body: json.encode({
        'make': make,
        'model': model,
        'year': year,
        'vin': vin,
        'license_plate': licensePlate,
        'mileage': mileage,
      }),
    );

    if (response.statusCode != 200) {
      throw ServerException(message: 'Failed to update vehicle');
    }
  }

Future<void> deleteVehicle(String accessToken, String workshopId, String vehicleId) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/workshops/$workshopId/vehicles/$vehicleId/'),
      headers: _buildHeaders(accessToken),
    );

    if (response.statusCode != 204) {
      throw ServerException(message: 'Failed to delete vehicle');
    }
  }

}

  Map<String, String> _buildHeaders(String accessToken) => {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };
