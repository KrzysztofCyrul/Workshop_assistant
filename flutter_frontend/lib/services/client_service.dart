import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';
import '../utils/constants.dart';

class ClientService {
  static Future<List<Client>> getClients(String accessToken, String workshopId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/clients/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy klientów: ${response.statusCode} - ${response.body}');
    }
  }

static Future<void> createClient({
  required String accessToken,
  required String workshopId,
  required String firstName,
  required String lastName,
  required String email,
  String? phone,
  String? address,
  String? segment,
}) async {
  final url = Uri.parse('$baseUrl/workshops/$workshopId/clients/');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'segment': segment,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Błąd podczas dodawania klienta: ${response.body}');
  }
}

}
