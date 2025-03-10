import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/constants.dart';
import '../data/models/workshop.dart';

class WorkshopService {
  static Future<List<Workshop>> getWorkshops(String accessToken) async {
    final url = Uri.parse('$baseUrl/workshops/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Iterable json = jsonDecode(response.body);
      return List<Workshop>.from(json.map((model) => Workshop.fromJson(model)));
    } else {
      throw Exception('Błąd pobierania listy warsztatów');
    }
  }

  static Future<void> requestAssignment(String workshopId, String accessToken) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/request-assignment/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Błąd wysyłania prośby o dołączenie');
    }
  }
static Future<Map<String, dynamic>> createWorkshop({
    required String accessToken,
    required String name,
    required String address,
    required String postCode,
    required String nipNumber,
    required String email,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'address': address,
        'post_code': postCode,
        'nip_number': nipNumber,
        'email': email,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Błąd podczas tworzenia warsztatu: ${response.body}');
    }
  }

  static Future<void> assignCreatorToWorkshop({
    required String accessToken,
    required String workshopId,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/employees/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'position': 'Owner',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Błąd przypisywania użytkownika do warsztatu: ${response.body}');
    }
  }
}