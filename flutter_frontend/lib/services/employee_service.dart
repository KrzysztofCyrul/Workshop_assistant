import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';
import '../utils/constants.dart';

class EmployeeService {
  static Future<List<Employee>> getMechanics(String accessToken, String workshopId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/employees/?role=mechanic');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => Employee.fromJson(item)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy mechaników: ${response.body}');
    }
  }

  static Future<Employee> getEmployeeDetails(String accessToken, String workshopId, String employeeId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/employees/$employeeId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Employee.fromJson(data);
    } else {
      throw Exception('Błąd podczas pobierania szczegółów pracownika: ${response.statusCode}');
    }
  }

  static Future<void> updateEmployeeStatus(String accessToken, String workshopId, String employeeId, String status) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/employees/$employeeId/');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Błąd podczas aktualizacji statusu pracownika: ${response.body}');
    }
  }

  static Future<List<Employee>> getPendingMechanics(String accessToken, String workshopId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/request-assignment/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => Employee.fromJson(item)).toList();
    } else {
      throw Exception('Błąd podczas pobierania oczekujących mechaników: ${response.body}');
    }
  }
}
