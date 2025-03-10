import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/quotation.dart';
import '../data/models/quotation_repair_item.dart';
import '../data/models/quotation_part.dart';
import '../core/utils/constants.dart';

class QuotationService {
  // Pobieranie listy wycen dla danego warsztatu
  static Future<List<Quotation>> getQuotations(
      String accessToken, String workshopId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((json) => Quotation.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania listy wycen: ${response.statusCode}');
    }
  }

  // Tworzenie nowej wyceny
  static Future<String> createQuotation({
    required String accessToken,
    required String workshopId,
    required String clientId,
    required String vehicleId,
    double? totalCost,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/');
    final body = json.encode({
      'client_id': clientId,
      'vehicle_id': vehicleId,
      'total_cost': totalCost,
      'workshop': workshopId,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['id'];
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Request body: $body');
      throw Exception('Błąd podczas tworzenia wyceny: ${response.statusCode}');
    }
  }

  // Aktualizacja wyceny
  static Future<void> updateQuotation({
    required String accessToken,
    required String workshopId,
    required String quotationId,
    double? totalCost,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'total_cost': totalCost,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Błąd podczas aktualizacji wyceny: ${response.body}');
    }
  }

  // Pobieranie szczegółów wyceny
  static Future<Quotation> getQuotationDetails(
      String accessToken, String workshopId, String quotationId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return Quotation.fromJson(data);
    } else {
      throw Exception('Błąd podczas pobierania szczegółów wyceny: ${response.statusCode}');
    }
  }

  // Usuwanie wyceny
  static Future<void> deleteQuotation(
      String accessToken, String workshopId, String quotationId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Błąd podczas usuwania wyceny: ${response.body}');
    }
  }

  // Pobieranie listy elementów naprawy dla wyceny
  static Future<List<QuotationRepairItem>> getQuotationRepairItems(
      String accessToken, String workshopId, String quotationId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/repair-items/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((json) => QuotationRepairItem.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania elementów naprawy: ${response.statusCode}');
    }
  }

  // Tworzenie nowego elementu naprawy dla wyceny
  static Future<void> createQuotationRepairItem({
    required String accessToken,
    required String workshopId,
    required String quotationId,
    required String description,
    required double cost,
    required int order,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/repair-items/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'description': description,
        'cost': cost,
        'order': order,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Błąd podczas tworzenia elementu naprawy: ${response.body}');
    }
  }

  // Aktualizacja elementu naprawy
  static Future<void> updateQuotationRepairItem({
    required String accessToken,
    required String workshopId,
    required String quotationId,
    required String repairItemId,
    String? description,
    double? cost,
    int? order,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/repair-items/$repairItemId/');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'description': description,
        'cost': cost,
        'order': order,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Błąd podczas aktualizacji elementu naprawy: ${response.body}');
    }
  }

  // Usuwanie elementu naprawy
  static Future<void> deleteQuotationRepairItem({
    required String accessToken,
    required String workshopId,
    required String quotationId,
    required String repairItemId,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/repair-items/$repairItemId/');
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

  // Pobieranie listy części dla wyceny
  static Future<List<QuotationPart>> getQuotationParts(
      String accessToken, String workshopId, String quotationId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/parts/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.map((json) => QuotationPart.fromJson(json)).toList();
    } else {
      throw Exception('Błąd podczas pobierania części: ${response.statusCode}');
    }
  }

  // Tworzenie nowej części dla wyceny
  static Future<void> createQuotationPart({
    required String accessToken,
    required String workshopId,
    required String quotationId,
    required String name,
    String? description,
    required double costPart,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/parts/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'description': description,
        'cost_part': costPart,
        'quantity': quantity,
        'quotation': quotationId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Błąd podczas tworzenia części: ${response.body}');
    }
  }

  // Aktualizacja części
  static Future<void> updateQuotationPart({
    required String accessToken,
    required String workshopId,
    required String quotationId,
    required String partId,
    String? name,
    String? description,
    double? costPart,
    int? quantity,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/parts/$partId/');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'description': description,
        'cost_part': costPart,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Błąd podczas aktualizacji części: ${response.body}');
    }
  }

  // Usuwanie części
  static Future<void> deleteQuotationPart({
    required String accessToken,
    required String workshopId,
    required String quotationId,
    required String partId,
  }) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/parts/$partId/');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Błąd podczas usuwania części: ${response.body}');
    }
  }
}