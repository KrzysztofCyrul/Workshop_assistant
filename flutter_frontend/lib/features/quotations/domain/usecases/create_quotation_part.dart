import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';
import '../../domain/repositories/quotation_repository.dart';
class CreateQuotationPart {
  final QuotationRepository repository;

  CreateQuotationPart(this.repository);

  Future<Either<Failure, QuotationPart>> execute({
    required String workshopId,
    required String quotationId,
    required String name,
    required String description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  }) async {
    return await repository.addQuotationPart(
      workshopId: workshopId,
      quotationId: quotationId,
      name: name,
      description: description,
      quantity: quantity,
      costPart: costPart,
      costService: costService,
      buyCostPart: buyCostPart,
    );
  }
}