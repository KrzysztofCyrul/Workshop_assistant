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
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy klientów: ${response.statusCode} - ${response.body}');
    }
  }
}
