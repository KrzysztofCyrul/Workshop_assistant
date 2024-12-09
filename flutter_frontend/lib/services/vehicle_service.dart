import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import '../utils/constants.dart';

class VehicleService {
  static Future<List<Vehicle>> getVehicles(String accessToken, String workshopId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/vehicles/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy pojazdów: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<List<Vehicle>> getVehiclesForClient(String accessToken, String workshopId, String clientId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/clients/$clientId/vehicles/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy pojazdów klienta: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Vehicle> getVehicleDetails(String accessToken, String workshopId, String vehicleId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/vehicles/$vehicleId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Vehicle.fromJson(data);
    } else {
      throw Exception('Błąd podczas pobierania szczegółów pojazdu: ${response.statusCode} - ${response.body}');
    }
  }
}