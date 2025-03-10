import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/constants.dart';

class TemporaryCodeService {
  // Nie definiujemy baseUrl tutaj, korzystamy z Config.baseUrl
  Future<Map<String, dynamic>> useCode(String code, String accessToken) async {
    final url = Uri.parse('$baseUrl/use-code/'); // Używamy Config.baseUrl
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Pomyślnie dodano do warsztatu'};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['detail']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Wystąpił błąd. Spróbuj ponownie.'};
    }
  }

  Future<Map<String, dynamic>> generateCode(String workshopId, String accessToken) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/generate-code/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'code': data['code'],
          'expiresAt': DateTime.parse(data['expires_at']),
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['detail']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Wystąpił błąd. Spróbuj ponownie.'};
    }
  }
}
