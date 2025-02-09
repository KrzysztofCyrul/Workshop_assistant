import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import '../models/part.dart';
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
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy zleceń: ${response.statusCode}');
    }
  }

  static Future<String> createAppointment({
    required String accessToken,
    required String workshopId,
    required String clientId,
    required String vehicleId,
    required DateTime scheduledTime,
    String? notes,
    required int mileage,
    String? recommendations,
    Duration? estimatedDuration,
    double? totalCost,
    required String status,
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
        'estimated_duration': estimatedDuration?.inMinutes,
        'total_cost': totalCost,
        'status': status,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['id'];
    } else {
      throw Exception('Błąd podczas tworzenia zlecenia: ${response.statusCode}');
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

static Future<void> updateRepairItem(
  String accessToken,
  String workshopId,
  String appointmentId,
  String repairItemId, {
  required String description,
  required String status,
  required double cost,
  required int order,
  Duration? estimatedDuration,
  Duration? actualDuration,
  bool? isCompleted,
}) async {
  final url = Uri.parse(
      '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/');
  final body = {
    'description': description,
    'status': status,
    'cost': cost,
    'order': order,
    if (estimatedDuration != null)
      'estimated_duration': '${estimatedDuration.inHours}:${estimatedDuration.inMinutes.remainder(60)}:00',
    if (actualDuration != null)
      'actual_duration': '${actualDuration.inHours}:${actualDuration.inMinutes.remainder(60)}:00',
    if (isCompleted != null) 'is_completed': isCompleted,
  };
  final response = await http.patch(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: json.encode(body),
  );

  if (response.statusCode != 200) {
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
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
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
      final data = json.decode(utf8.decode(response.bodyBytes));
      return RepairItem.fromJson(data);
    } else {
      throw Exception(
          'Błąd podczas pobierania szczegółów elementu naprawy: ${response.statusCode}');
    }
  }

static Future<void> deleteRepairItem(
  String accessToken,
  String workshopId,
  String appointmentId,
  String repairItemId,
) async {
  final url = Uri.parse(
      '$baseUrl/workshops/$workshopId/appointments/$appointmentId/repair-items/$repairItemId/');
  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Błąd podczas usuwania elementu naprawy: ${response.body}');
  }
}

  // Method to create a part

static Future<void> createPart(
  String accessToken,
  String workshopId,
  String appointmentId,
  String name,
  String description,
  int quantity,
  double costPart,
  double costService,
) async {
  final url = Uri.parse(
      '$baseUrl/workshops/$workshopId/appointments/$appointmentId/parts/');
  final body = {
    'name': name,
    'description': description,
    'quantity': quantity,
    'cost_part': costPart.toString(),
    'cost_service': costService.toString(),
    'appointment': appointmentId,
  };

  print('Wysyłane dane: $body'); // Logowanie wysyłanych danych

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: json.encode(body),
  );

  if (response.statusCode != 201) {
    print('Błąd odpowiedzi backendu: ${response.body}');
    throw Exception('Błąd podczas dodawania części: ${response.body}');
  }
}


  // Method to fetch parts for an appointment
  static Future<List<Part>> getParts(
    String accessToken,
    String workshopId,
    String appointmentId,
  ) async {
    final url = Uri.parse(
        '$baseUrl/workshops/$workshopId/appointments/$appointmentId/parts/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List;

      return data.map((json) => Part.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching parts: ${response.body}');
    }
  }

  static Future<void> updatePart(
  String accessToken,
  String workshopId,
  String appointmentId,
  String partId, {
  required String name,
  required String description,
  required int quantity,
  required double costPart,
  required double costService,
}) async {
  final url = Uri.parse(
      '$baseUrl/workshops/$workshopId/appointments/$appointmentId/parts/$partId/');
  final body = {
    'name': name,
    'description': description,
    'quantity': quantity,
    'cost_part': costPart.toString(),
    'cost_service': costService.toString(),
  };
  final response = await http.patch(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: json.encode(body),
  );

  if (response.statusCode != 200) {
    throw Exception('Błąd podczas aktualizacji części: ${response.body}');
  }
}


  // Method to delete a part
  static Future<void> deletePart(
    String accessToken,
    String workshopId,
    String appointmentId,
    String partId,
  ) async {
    final url = Uri.parse(
        '$baseUrl/workshops/$workshopId/appointments/$appointmentId/parts/$partId/');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error deleting part: ${response.body}');
    }
  }
}
