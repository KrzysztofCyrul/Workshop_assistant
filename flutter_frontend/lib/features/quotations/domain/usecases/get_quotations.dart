import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import '../../domain/repositories/quotation_repository.dart';

class GetQuotations {
  final QuotationRepository repository;

  GetQuotations(this.repository);

  Future<Either<Failure, List<Quotation>>> execute(String workshopId) async {
    return await repository.getQuotations(workshopId);
  }
}