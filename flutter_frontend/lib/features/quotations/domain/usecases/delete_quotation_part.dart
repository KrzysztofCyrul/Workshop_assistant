import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import '../../domain/repositories/quotation_repository.dart';

class DeleteQuotationPart {
  final QuotationRepository repository;

  DeleteQuotationPart(this.repository);

  Future<Either<Failure, void>> execute({
    required String workshopId,
    required String quotationId,
    required String partId,
  }) async {
    return await repository.deleteQuotationPart(
      workshopId: workshopId,
      quotationId: quotationId,
      partId: partId,
    );
  }
}