import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';

abstract class QuotationRepository {
  Future<Either<Failure, List<Quotation>>> getQuotations(String workshopId);
  Future<Either<Failure, Quotation>> getQuotationDetails(String workshopId, String quotationId);  Future<Either<Failure, String>> addQuotation({
    required String workshopId,
    required String clientId,
    required String vehicleId,
    double? totalCost,
    String? notes,
    DateTime? date,
  });
  Future<Either<Failure, void>> updateQuotation({
    required String workshopId,
    required String quotationId,
    double? totalCost,
  });
  Future<Either<Failure, void>> deleteQuotation(String workshopId, String quotationId);
  Future<Either<Failure, List<QuotationPart>>> getQuotationParts({
    required String workshopId,
    required String quotationId,
  });  Future<Either<Failure, QuotationPart>> addQuotationPart({
    required String workshopId,
    required String quotationId,
    required String name,
    required String? description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  });Future<Either<Failure, QuotationPart>> updateQuotationPart({
    required String workshopId,
    required String quotationId,
    required String partId,
    required String name,
    required String? description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  });
  Future<Either<Failure, void>> deleteQuotationPart({
    required String workshopId,
    required String quotationId,
    required String partId,
  });
}