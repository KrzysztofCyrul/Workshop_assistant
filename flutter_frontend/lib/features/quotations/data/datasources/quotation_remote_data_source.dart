import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/utils/constants.dart' as api_constants;
import 'package:flutter_frontend/core/errors/dio_error_handler.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';
import 'package:flutter_frontend/features/quotations/data/models/quotation_model.dart';
import 'package:flutter_frontend/features/quotations/data/models/quotation_part_model.dart';

class QuotationRemoteDataSource {
  final Dio dio;

  QuotationRemoteDataSource({required this.dio});
  Future<List<Quotation>> getQuotations(String workshopId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/quotations/');
      return (response.data as List).map((json) => QuotationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<Quotation> getQuotationDetails(String workshopId, String quotationId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/quotations/$quotationId/');
      return QuotationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<String> addQuotation({
    required String workshopId,
    required String clientId,
    required String vehicleId,
    double? totalCost,
    String? notes,
    DateTime? date,
  }) async {
    try {
      // Tworzymy dane zapytania zgodne z tym co przyjmuje API
      final data = {
        'client_id': clientId,
        'vehicle_id': vehicleId,
        'total_cost': totalCost,
        'workshop': workshopId, // Wymagane pole workshop
      };

      // Dodajemy opcjonalne pola tylko gdy nie są null
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      if (date != null) {
        data['date'] = date.toIso8601String();
      }

      final response = await dio.post(
        '${api_constants.baseUrl}/workshops/$workshopId/quotations/',
        data: data,
      );
      return response.data['id'];
    } on DioException catch (e) {
      if (e.response != null) {}
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> updateQuotation({
    required String workshopId,
    required String quotationId,
    double? totalCost,
  }) async {
    try {
      await dio.put(
        '${api_constants.baseUrl}/workshops/$workshopId/quotations/$quotationId/',
        data: {
          'total_cost': totalCost,
        },
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> deleteQuotation(String workshopId, String quotationId) async {
    try {
      await dio.delete('${api_constants.baseUrl}/workshops/$workshopId/quotations/$quotationId/');
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<List<QuotationPart>> getQuotationParts({
    required String workshopId,
    required String quotationId,
  }) async {
    try {
      final response = await dio.get(
        '${api_constants.baseUrl}/workshops/$workshopId/quotations/$quotationId/parts/',
      );
      return (response.data as List).map((json) => QuotationPartModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<QuotationPart> addQuotationPart({
    required String workshopId,
    required String quotationId,
    required String name,
    required String? description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  }) async {
    try {
      final response = await dio.post(
        '${api_constants.baseUrl}/workshops/$workshopId/quotations/$quotationId/parts/',
        data: {
          'quotation': quotationId,
          'name': name,
          'description': description ?? "", // Add empty string fallback when description is null
          'quantity': quantity,
          'cost_part': costPart.toString(),
          'cost_service': costService.toString(),
          'buy_cost_part': buyCostPart.toString(),
        },
      );
      return QuotationPartModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<QuotationPart> updateQuotationPart({
    required String workshopId,
    required String quotationId,
    required String partId,
    required String name,
    required String? description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  }) async {
    try {
      final response = await dio.patch(
        '${api_constants.baseUrl}/workshops/$workshopId/quotations/$quotationId/parts/$partId/',
        data: {
          'name': name,
          'description': description ?? "", // Add empty string fallback when description is null
          'quantity': quantity,
          'cost_part': costPart.toString(),
          'cost_service': costService.toString(),
          'buy_cost_part': buyCostPart.toString(),
        },
      );
      return QuotationPartModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> deleteQuotationPart({
    required String workshopId,
    required String quotationId,
    required String partId,
  }) async {
    try {
      await dio.delete(
        '${api_constants.baseUrl}/workshops/$workshopId/quotations/$quotationId/parts/$partId/',
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
