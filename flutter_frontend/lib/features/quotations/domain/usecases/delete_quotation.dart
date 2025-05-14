import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import '../../domain/repositories/quotation_repository.dart';

class DeleteQuotation {
  final QuotationRepository repository;

  DeleteQuotation(this.repository);

  Future<Either<Failure, void>> execute(String workshopId, String quotationId) async {
    return await repository.deleteQuotation(workshopId, quotationId);
  }
}