// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/visit.dart';

class ApiService {
  static const String baseUrl = "http://192.168.0.101:8000/api";

  static Future<List<Visit>> fetchVisits() async {
    final response = await http.get(
      Uri.parse('$baseUrl/visits/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load visits');
    }
  }

  static Future<List<Car>> fetchCars() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cars/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }

  static Future<List<Mechanic>> fetchMechanics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/mechanics/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Mechanic.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load mechanics');
    }
  }

  static Future<void> updateStatus(String id, String newStatus) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visit/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': newStatus}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  static Future<void> updateStrikedLines(
      String id, Map<int, bool> strikedLines) async {
    final strikedLinesJson =
        strikedLines.map((key, value) => MapEntry(key.toString(), value));
    print('Updating striked lines for visit $id with data: $strikedLinesJson');

    final response = await http.post(
      Uri.parse('$baseUrl/visit/update-striked/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'strikedLines': strikedLinesJson}),
    );

    if (response.statusCode != 200) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update striked lines');
    }
  }

  static Future<void> addVisit(Map<String, dynamic> visitData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visits/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(visitData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add visit');
    }
  }

  static Future<void> editVisit(
      String id, Map<String, dynamic> visitData) async {
    final url = '$baseUrl/visit/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(visitData),
    );

    if (response.statusCode != 200) {
      print('Failed to edit visit. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to edit visit');
    }
  }

  static Future<void> deleteVisit(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/visit/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete visit');
    }
  }

  static Future<void> archiveVisit(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/visit/$id'),
      body: json.encode({'is_active': false}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to archive visit');
    }
  }

  static Future<void> addCar(Map<String, dynamic> carData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cars/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(carData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add car');
    }
  }
}
