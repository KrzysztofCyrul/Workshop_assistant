import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';

class Quotation {  final String id;
  final String quotationNumber; // Quotation number is now non-nullable in backend
  final Client client;
  final Vehicle vehicle;
  final String workshopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? totalCost;
  final String? notes;
  final List<QuotationPart> parts;
  Quotation({
    required this.id,
    required this.quotationNumber, // No longer optional
    required this.client,
    required this.vehicle,
    required this.workshopId,
    required this.createdAt,
    required this.updatedAt,
    this.totalCost,
    this.notes,
    this.parts = const [],
  });

  Quotation copyWith({
    String? id,
    String? quotationNumber,
    Client? client,
    Vehicle? vehicle,
    String? workshopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalCost,
    String? notes,
    List<QuotationPart>? parts,
  }) {
    return Quotation(
      id: id ?? this.id,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      client: client ?? this.client,
      vehicle: vehicle ?? this.vehicle,
      workshopId: workshopId ?? this.workshopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
      parts: parts ?? this.parts,
    );
  }
}
