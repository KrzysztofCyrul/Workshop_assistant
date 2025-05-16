import 'package:flutter_frontend/features/clients/data/models/client_model.dart';
import 'package:flutter_frontend/features/quotations/data/models/quotation_part_model.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import 'package:flutter_frontend/features/vehicles/data/models/vehicle_model.dart';

class QuotationModel extends Quotation {
  QuotationModel({
    required super.id,
    required super.quotationNumber,
    required super.client,
    required super.vehicle,
    required super.workshopId,
    required super.createdAt,
    required super.updatedAt,
    super.totalCost,
    super.notes,
    super.parts = const [],
  });
  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      id: json['id'] as String? ?? '',
      quotationNumber: json['quotation_number'] as String? ?? '',
      client: ClientModel.fromJson(json['client'] as Map<String, dynamic>),
      vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      workshopId: json['workshop'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      totalCost: double.tryParse(json['total_cost']?.toString() ?? '0.0'),
      notes: json['notes'] as String?,
      parts: (json['quotation_parts'] as List<dynamic>?)
              ?.map((item) => QuotationPartModel.fromJson(item as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_number': quotationNumber,
      'client': (client as ClientModel).toJson(),
      'vehicle': (vehicle as VehicleModel).toJson(),
      'workshop': workshopId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_cost': totalCost,
      'notes': notes,
      'quotation_parts': parts.map((item) => (item as QuotationPartModel).toJson()).toList(),
    };
  }

  Quotation toEntity() {
    return Quotation(
      id: id,
      quotationNumber: quotationNumber,
      client: client,
      vehicle: vehicle,
      workshopId: workshopId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      totalCost: totalCost,
      notes: notes,
      parts: parts,
    );
  }

  static QuotationModel fromEntity(Quotation quotation) {
    return QuotationModel(
      id: quotation.id,
      quotationNumber: quotation.quotationNumber,
      client: ClientModel.fromEntity(quotation.client),
      vehicle: VehicleModel.fromEntity(quotation.vehicle),
      workshopId: quotation.workshopId,
      createdAt: quotation.createdAt,
      updatedAt: quotation.updatedAt,
      totalCost: quotation.totalCost,
      notes: quotation.notes,
      parts: quotation.parts.map((part) => QuotationPartModel.fromEntity(part)).toList(),
    );
  }
}
