import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import '../../domain/repositories/quotation_repository.dart';

class UpdateQuotation {
  final QuotationRepository repository;

  UpdateQuotation(this.repository);

  Future<Either<Failure, void>> execute({
    required String workshopId,
    required String quotationId,
    double? totalCost,
  }) async {
    return await repository.updateQuotation(
      workshopId: workshopId,
      quotationId: quotationId,
      totalCost: totalCost,
    );
  }
}