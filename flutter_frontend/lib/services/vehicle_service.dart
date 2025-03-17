import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/vehicle_model.dart';
import '../core/utils/constants.dart';

class VehicleService {
  static Future<List<VehicleModel>> getVehicles(String accessToken, String workshopId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/vehicles/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy pojazdów: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<List<VehicleModel>> getVehiclesForClient(String accessToken, String workshopId, String clientId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/clients/$clientId/vehicles/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy pojazdów klienta: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<VehicleModel> getVehicleDetails(String accessToken, String workshopId, String vehicleId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/vehicles/$vehicleId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return VehicleModel.fromJson(data);
    } else {
      throw Exception('Błąd podczas pobierania szczegółów pojazdu: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createVehicle({
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
    final url = Uri.parse('$baseUrl/workshops/$workshopId/clients/$clientId/vehicles/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
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
      throw Exception('Błąd podczas dodawania pojazdu: ${response.body}');
    }
  }

  static Future<void> updateVehicle({
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
    final url = Uri.parse('$baseUrl/workshops/$workshopId/vehicles/$vehicleId/');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
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
      throw Exception('Błąd podczas aktualizacji pojazdu: ${response.body}');
    }
  }
}
