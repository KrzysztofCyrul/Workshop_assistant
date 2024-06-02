  // lib/services/api_service.dart
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/visit.dart';

  class ApiService {
  static const String baseUrl = "http://192.168.0.101:8000/api";

  static Future<List<Visit>> fetchVisits() async {
    final response = await http.get(Uri.parse('$baseUrl/visits/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load visits');
    }
  }

  static Future<List<Car>> fetchCars() async {
    final response = await http.get(Uri.parse('$baseUrl/cars/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }

  static Future<List<Mechanic>> fetchMechanics() async {
    final response = await http.get(Uri.parse('$baseUrl/mechanics/'));

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
      body: json.encode({'status': newStatus}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  static Future<void> updateStrikedLines(String id, Map<int, bool> strikedLines) async {
    final strikedLinesJson = strikedLines.map((key, value) => MapEntry(key.toString(), value));
    print('Updating striked lines for visit $id with data: $strikedLinesJson');

    final response = await http.post(
      Uri.parse('$baseUrl/visit/update-striked/$id'),
      body: json.encode({'strikedLines': strikedLinesJson}),
      headers: {'Content-Type': 'application/json'},
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
      body: json.encode(visitData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add visit');
    }
  }
  }