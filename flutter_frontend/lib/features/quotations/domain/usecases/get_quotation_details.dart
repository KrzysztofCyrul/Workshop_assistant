import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';

class GetQuotationDetails {
  final QuotationRepository repository;

  GetQuotationDetails(this.repository);

  Future<Either<Failure, Quotation>> execute(String workshopId, String quotationId) async {
    return await repository.getQuotationDetails(workshopId, quotationId);
  }
}