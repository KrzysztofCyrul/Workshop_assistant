import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import '../../domain/repositories/quotation_repository.dart';

class CreateQuotation {
  final QuotationRepository repository;

  CreateQuotation(this.repository);
  Future<Either<Failure, String>> execute({
    required String workshopId,
    required String clientId,
    required String vehicleId,
    double? totalCost,
    String? notes,
    DateTime? date,
  }) async {
    return await repository.addQuotation(
      workshopId: workshopId,
      clientId: clientId,
      vehicleId: vehicleId,
      totalCost: totalCost,
      notes: notes,
      date: date,
    );
  }
}