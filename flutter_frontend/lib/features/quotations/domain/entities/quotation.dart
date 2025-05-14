import 'package:equatable/equatable.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';

class Quotation extends Equatable {
  final String id;
  final Client client;
  final Vehicle vehicle;
  final String workshopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? totalCost;
  final String? notes;
  final List<QuotationPart> parts;

  const Quotation({
    required this.id,
    required this.client,
    required this.vehicle,
    required this.workshopId,
    required this.createdAt,
    required this.updatedAt,
    this.totalCost,
    this.notes,
    this.parts = const [],
  });

  @override
  List<Object?> get props => [
        id,
        client,
        vehicle,
        workshopId,
        createdAt,
        updatedAt,
        totalCost,
        notes,
        parts,
      ];
}