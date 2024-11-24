import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import '../utils/constants.dart';

class AppointmentService {
  static Future<List<Appointment>> getAppointments(
      String accessToken, String workshopId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/appointments/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Iterable json = jsonDecode(response.body);
      return List<Appointment>.from(
          json.map((model) => Appointment.fromJson(model)));
    } else {
      throw Exception('Błąd pobierania zleceń');
    }
  }

  static Future<Appointment> getAppointmentDetails(
      String accessToken, String workshopId, String appointmentId) async {
    final url = Uri.parse(
        '$baseUrl/workshops/$workshopId/appointments/$appointmentId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Appointment.fromJson(data);
    } else {
      throw Exception('Błąd podczas pobierania szczegółów zlecenia');
    }
  }
}
