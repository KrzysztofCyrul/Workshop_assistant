import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/workshop.dart';

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
}
