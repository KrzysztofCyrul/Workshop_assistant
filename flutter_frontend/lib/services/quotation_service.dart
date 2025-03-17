import 'dart:convert';
import 'package:flutter_frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import '../data/models/quotation.dart';
import '../data/models/quotation_part.dart';
import '../core/utils/constants.dart';

class QuotationService {
  static Future<List<Quotation>> getQuotations(String accessToken, String workshopId) async {
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
    } else if (response.statusCode == 401) {
      await AuthService.refreshToken();
      final newAccessToken = await AuthService.getAccessToken();
      if (newAccessToken != null) {
        return getQuotations(newAccessToken, workshopId);
      } else {
        throw Exception('Błąd odświeżania tokena');
      }
    } else {
      throw Exception('Błąd podczas pobierania listy wycen: ${response.statusCode}');
    }
  }

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
    } else if (response.statusCode == 401) {
      await AuthService.refreshToken();
      final newAccessToken = await AuthService.getAccessToken();
      if (newAccessToken != null) {
        return createQuotation(
          accessToken: newAccessToken,
          workshopId: workshopId,
          clientId: clientId,
          vehicleId: vehicleId,
          totalCost: totalCost,
        );
      } else {
        throw Exception('Błąd odświeżania tokena');
      }
    } else {
      throw Exception('Błąd podczas tworzenia wyceny: ${response.statusCode}');
    }
  }

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
      if (response.statusCode == 401) {
        await AuthService.refreshToken();
        final newAccessToken = await AuthService.getAccessToken();
        if (newAccessToken != null) {
          return updateQuotation(
            accessToken: newAccessToken,
            workshopId: workshopId,
            quotationId: quotationId,
            totalCost: totalCost,
          );
        } else {
          throw Exception('Błąd odświeżania tokena');
        }
      } else {
        throw Exception('Błąd podczas aktualizacji wyceny: ${response.body}');
      }
    }
  }

  static Future<Quotation> getQuotationDetails(String accessToken, String workshopId, String quotationId) async {
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
    } else if (response.statusCode == 401) {
      await AuthService.refreshToken();
      final newAccessToken = await AuthService.getAccessToken();
      if (newAccessToken != null) {
        return getQuotationDetails(newAccessToken, workshopId, quotationId);
      } else {
        throw Exception('Błąd odświeżania tokena');
      }
    } else {
      throw Exception('Błąd podczas pobierania szczegółów wyceny: ${response.statusCode}');
    }
  }

  static Future<void> deleteQuotation(String accessToken, String workshopId, String quotationId) async {
    final url = Uri.parse('$baseUrl/workshops/$workshopId/quotations/$quotationId/');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      if (response.statusCode == 401) {
        await AuthService.refreshToken();
        final newAccessToken = await AuthService.getAccessToken();
        if (newAccessToken != null) {
          return deleteQuotation(newAccessToken, workshopId, quotationId);
        } else {
          throw Exception('Błąd odświeżania tokena');
        }
      } else {
        throw Exception('Błąd podczas usuwania wyceny: ${response.body}');
      }
    }
  }

  static Future<List<QuotationPart>> getQuotationParts(String accessToken, String workshopId, String quotationId) async {
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
    } else if (response.statusCode == 401) {
      await AuthService.refreshToken();
      final newAccessToken = await AuthService.getAccessToken();
      if (newAccessToken != null) {
        return getQuotationParts(newAccessToken, workshopId, quotationId);
      } else {
        throw Exception('Błąd odświeżania tokena');
      }
    } else {
      throw Exception('Błąd podczas pobierania części: ${response.statusCode}');
    }
  }

  static Future<void> createQuotationPart({
    required String accessToken,
    required String workshopId,
    required String quotationId,
    required String name,
    String? description,
    required double costPart,
    required int quantity,
    required double buyCostPart,
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
        'buy_cost_part': buyCostPart,
      }),
    );

    if (response.statusCode != 201) {
      if (response.statusCode == 401) {
        await AuthService.refreshToken();
        final newAccessToken = await AuthService.getAccessToken();
        if (newAccessToken != null) {
          return createQuotationPart(
            accessToken: newAccessToken,
            workshopId: workshopId,
            quotationId: quotationId,
            name: name,
            description: description,
            costPart: costPart,
            quantity: quantity,
            buyCostPart: buyCostPart,
          );
        } else {
          throw Exception('Błąd odświeżania tokena');
        }
      } else {
        throw Exception('Błąd podczas tworzenia części: ${response.body}');
      }
    }
  }

  static Future<void> updateQuotationPart({
    required String accessToken,
    required String workshopId,
    required String quotationId,
    required String partId,
    String? name,
    String? description,
    double? costPart,
    double? costService,
    int? quantity,
    double? buyCostPart,
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
        'cost_service': costService,
        'quantity': quantity,
        'buy_cost_part': buyCostPart,
      }),
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        // Token wygasł, odśwież token
        await AuthService.refreshToken();
        final newAccessToken = await AuthService.getAccessToken();
        if (newAccessToken != null) {
          return updateQuotationPart(
            accessToken: newAccessToken,
            workshopId: workshopId,
            quotationId: quotationId,
            partId: partId,
            name: name,
            description: description,
            costPart: costPart,
            costService: costService,
            quantity: quantity,
            buyCostPart: buyCostPart,
          );
        } else {
          throw Exception('Błąd odświeżania tokena');
        }
      } else {
        throw Exception('Błąd podczas aktualizacji części: ${response.body}');
      }
    }
  }

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
      if (response.statusCode == 401) {
        await AuthService.refreshToken();
        final newAccessToken = await AuthService.getAccessToken();
        if (newAccessToken != null) {
          return deleteQuotationPart(
            accessToken: newAccessToken,
            workshopId: workshopId,
            quotationId: quotationId,
            partId: partId,
          );
        } else {
          throw Exception('Błąd odświeżania tokena');
        }
      } else {
        throw Exception('Błąd podczas usuwania części: ${response.body}');
      }
    }
  }
}
