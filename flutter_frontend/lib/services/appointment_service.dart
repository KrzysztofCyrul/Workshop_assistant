import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import '../models/repair_item.dart';
import '../utils/constants.dart';

class AppointmentService {
  static Future<List<Appointment>> getAppointments(
      String accessToken, String workshopId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/appointments/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy zleceń: ${response.statusCode}');
    }
  }

  static Future<void> createAppointment({
    required String accessToken,
    required String workshopId,
    required String clientId,
    required String vehicleId,
    required DateTime scheduledTime,
    String? notes,
    int mileage = 0,
    String? recommendations,
    Duration? estimatedDuration,
    double? totalCost,
    // List<String>? assignedMechanicIds,
    String status = 'scheduled',
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/appointments/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'client_id': clientId,
        'vehicle_id': vehicleId,
        'scheduled_time': scheduledTime.toIso8601String(),
        'notes': notes,
        'mileage': mileage,
        'recommendations': recommendations,
        'estimated_duration': estimatedDuration != null
            ? estimatedDuration.inMinutes
            : null,
        'total_cost': totalCost,
        // 'assigned_mechanics': assignedMechanicIds,
        'status': status,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Błąd podczas tworzenia zlecenia: ${response.body}');
    }
  }

static Future<void> updateAppointmentStatus({
    required String accessToken,
    required String workshopId,
    required String appointmentId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/appointments/$appointmentId/');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Błąd podczas aktualizacji statusu: ${response.body}');
    }
  }



  static Future<void> createRepairItem(
    String accessToken,
    String workshopId,
    String appointmentId,
    String description,
    String status,
    int order,
    double cost,
  ) async {
    final url = Uri.parse(
        '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/');
    final body = {
      'description': description,
      'status': status,
      'order': order,
      'cost': cost.toString(),
    };
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Błąd podczas tworzenia elementu naprawy: ${response.body}');
    }
  }

// Funkcja pomocnicza do konwersji Duration na String w formacie HH:MM:SS
static String _durationToString(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String hours = twoDigits(duration.inHours);
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$hours:$minutes:$seconds';
}

// Metoda aktualizująca element naprawy
  static Future<void> updateRepairItem(
    String accessToken,
    String workshopId,
    String appointmentId,
    String repairItemId, {
    String? status,
    bool? isCompleted,
    String? actualDuration,
    String? completedBy,
  }) async {
    final url = Uri.parse(
        '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/');
    final Map<String, dynamic> body = {};
    if (status != null) body['status'] = status;
    if (isCompleted != null) body['is_completed'] = isCompleted;
    if (actualDuration != null) body['actual_duration'] = actualDuration;
    if (completedBy != null) body['completed_by'] = completedBy;

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Błąd podczas aktualizacji elementu naprawy: ${response.body}');
    }
  }

  // Metoda pobierająca szczegóły zlecenia
  static Future<Appointment> getAppointmentDetails(
      String accessToken, String workshopId, String appointmentId) async {
    final url =
        Uri.parse('$baseUrl/workshops/$workshopId/appointments/$appointmentId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Appointment.fromJson(data);
    } else {
      throw Exception(
          'Błąd podczas pobierania szczegółów zlecenia: ${response.statusCode}');
    }
  }


  // Metoda aktualizująca status elementu naprawy
  static Future<void> updateRepairItemStatus(
    String accessToken,
    String workshopId,
    String appointmentId,
    String repairItemId,
    bool isCompleted,
  ) async {
    final url = Uri.parse(
        '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/');


    final existingRepairItem = await getRepairItemDetails(
      accessToken,
      workshopId,
      appointmentId,
      repairItemId,
    );

    // Aktualizujemy pole is_completed
    final updatedRepairItemData = {
      'description': existingRepairItem.description,
      'is_completed': isCompleted,
      'status': existingRepairItem.status,
      'order': existingRepairItem.order,
      // Dodaj inne wymagane pola, jeśli są
    };

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedRepairItemData),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Błąd podczas aktualizacji statusu elementu naprawy: ${response.body}');
    }
  }

  // Metoda pobierająca szczegóły elementu naprawy
  static Future<RepairItem> getRepairItemDetails(
    String accessToken,
    String workshopId,
    String appointmentId,
    String repairItemId,
  ) async {
    final url = Uri.parse(
        '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return RepairItem.fromJson(data);
    } else {
      throw Exception(
          'Błąd podczas pobierania szczegółów elementu naprawy: ${response.statusCode}');
    }
  }
}
