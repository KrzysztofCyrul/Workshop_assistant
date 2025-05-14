import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import '../../domain/repositories/quotation_repository.dart';
import 'package:flutter_frontend/models/quotation.dart';

class GetQuotations {
  final QuotationRepository repository;

  GetQuotations(this.repository);

  Future<Either<Failure, List<Quotation>>> execute(String workshopId) async {
    return await repository.getQuotations(workshopId);
  }
}