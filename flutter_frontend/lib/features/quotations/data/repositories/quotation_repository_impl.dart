import 'package:dartz/dartz.dart';
import 'package:flutter_frontend/core/errors/failure.dart';
import 'package:flutter_frontend/features/quotations/data/datasources/quotation_remote_data_source.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';
import 'package:flutter_frontend/features/quotations/domain/repositories/quotation_repository.dart';

class QuotationRepositoryImpl implements QuotationRepository {
  final QuotationRemoteDataSource remoteDataSource;

  QuotationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Quotation>>> getQuotations(String workshopId) async {
    try {
      final quotations = await remoteDataSource.getQuotations(workshopId);
      return Right(quotations);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Quotation>> getQuotationDetails(String workshopId, String quotationId) async {
    try {
      final quotation = await remoteDataSource.getQuotationDetails(workshopId, quotationId);
      return Right(quotation);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
  @override
  Future<Either<Failure, String>> addQuotation({
    required String workshopId,
    required String clientId,
    required String vehicleId,
    double? totalCost,
    String? notes,
    DateTime? date,
  }) async {
    try {
      final quotationId = await remoteDataSource.addQuotation(
        workshopId: workshopId,
        clientId: clientId,
        vehicleId: vehicleId,
        totalCost: totalCost,
        notes: notes,
        date: date,
      );
      return Right(quotationId);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuotation({
    required String workshopId,
    required String quotationId,
    double? totalCost,
  }) async {
    try {
      await remoteDataSource.updateQuotation(
        workshopId: workshopId,
        quotationId: quotationId,
        totalCost: totalCost,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuotation(String workshopId, String quotationId) async {
    try {
      await remoteDataSource.deleteQuotation(workshopId, quotationId);
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuotationPart>>> getQuotationParts({
    required String workshopId,
    required String quotationId,
  }) async {
    try {
      final parts = await remoteDataSource.getQuotationParts(
        workshopId: workshopId,
        quotationId: quotationId,
      );
      return Right(parts);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override  Future<Either<Failure, QuotationPart>> addQuotationPart({
    required String workshopId,
    required String quotationId,
    required String name,
    required String? description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  }) async {
    try {
      final part = await remoteDataSource.addQuotationPart(
        workshopId: workshopId,
        quotationId: quotationId,
        name: name,
        description: description,
        quantity: quantity,
        costPart: costPart,
        costService: costService,
        buyCostPart: buyCostPart,
      );
      return Right(part);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override  Future<Either<Failure, QuotationPart>> updateQuotationPart({
    required String workshopId,
    required String quotationId,
    required String partId,
    required String name,
    required String? description,
    required int quantity,
    required double costPart,
    required double costService,
    required double buyCostPart,
  }) async {
    try {
      final part = await remoteDataSource.updateQuotationPart(
        workshopId: workshopId,
        quotationId: quotationId,
        partId: partId,
        name: name,
        description: description,
        quantity: quantity,
        costPart: costPart,
        costService: costService,
        buyCostPart: buyCostPart,
      );
      return Right(part);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuotationPart({
    required String workshopId,
    required String quotationId,
    required String partId,
  }) async {
    try {
      await remoteDataSource.deleteQuotationPart(
        workshopId: workshopId,
        quotationId: quotationId,
        partId: partId,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}