import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import '../../domain/repositories/quotation_repository.dart';
import 'package:flutter_frontend/models/quotation_part.dart';

class GetQuotationParts {
  final QuotationRepository repository;

  GetQuotationParts(this.repository);

  Future<Either<Failure, List<QuotationPart>>> execute({
    required String workshopId,
    required String quotationId,
  }) async {
    return await repository.getQuotationParts(
      workshopId: workshopId,
      quotationId: quotationId,
    );
  }
}