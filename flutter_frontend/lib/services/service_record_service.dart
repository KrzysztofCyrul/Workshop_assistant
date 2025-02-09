import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_record.dart';
import '../utils/constants.dart';

class ServiceRecordService {
  static Future<List<ServiceRecord>> getServiceRecords(
    String accessToken,
    String workshopId,
    String vehicleId,
  ) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/vehicles/$vehicleId/service-records/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((item) => ServiceRecord.fromJson(item)).toList();
    } else {
      throw Exception('Błąd podczas pobierania rekordów serwisowych: ${response.body}');
    }
  }
}
