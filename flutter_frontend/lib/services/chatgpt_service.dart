import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ChatGPTService {
  static Future<String> generateEmail({
  required String accessToken,
  required String subjectHint,
  required String recipientType,
  String? selectedSegment,
  String? selectedClient,
  required String senderName,
  required String senderPosition,
  required String senderCompany,
}) async {
  final url = Uri.parse('$baseUrl/generate-email/');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'subject_hint': subjectHint,
      'recipient_type': recipientType,
      if (selectedSegment != null) 'selected_segment': selectedSegment,
      if (selectedClient != null) 'selected_client': selectedClient,
      'sender_name': senderName,
      'sender_position': senderPosition,
      'sender_company': senderCompany,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(utf8.decode(response.bodyBytes));
    return data['email_content'] ?? 'Brak treści w odpowiedzi.';
  } else {
    throw Exception(
      'Błąd podczas generowania treści e-maila: ${response.statusCode} - ${response.body}',
    );
  }
}
}
