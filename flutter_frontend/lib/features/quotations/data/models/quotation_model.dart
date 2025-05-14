import 'package:flutter_frontend/features/clients/data/models/client_model.dart';
import 'package:flutter_frontend/features/quotations/data/models/quotation_part_model.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import 'package:flutter_frontend/features/vehicles/data/models/vehicle_model.dart';

class QuotationModel extends Quotation {
  const QuotationModel({
    required String id,
    required ClientModel client,
    required VehicleModel vehicle,
    required String workshopId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required double? totalCost,
    required String? notes,
    required List<QuotationPartModel> parts,
  }) : super(
          id: id,
          client: client,
          vehicle: vehicle,
          workshopId: workshopId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          totalCost: totalCost,
          notes: notes,
          parts: parts,
        );

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      id: json['id'],
      client: ClientModel.fromJson(json['client']),
      vehicle: VehicleModel.fromJson(json['vehicle']),
      workshopId: json['workshop_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      totalCost: json['total_cost'] != null ? (json['total_cost'] as num).toDouble() : null,
      notes: json['notes'],
      parts: json['parts'] != null
          ? (json['parts'] as List).map((part) => QuotationPartModel.fromJson(part)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': (client as ClientModel).toJson(),
      'vehicle': (vehicle as VehicleModel).toJson(),
      'workshop_id': workshopId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_cost': totalCost,
      'notes': notes,
      'parts': parts.map((part) => (part as QuotationPartModel).toJson()).toList(),
    };
  }

  QuotationModel copyWith({
    String? id,
    ClientModel? client,
    VehicleModel? vehicle,
    String? workshopId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalCost,
    String? notes,
    List<QuotationPartModel>? parts,
  }) {
    return QuotationModel(
      id: id ?? this.id,
      client: client ?? (this.client as ClientModel),
      vehicle: vehicle ?? (this.vehicle as VehicleModel),
      workshopId: workshopId ?? this.workshopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
      parts: parts ?? (this.parts as List<QuotationPartModel>),
    );
  }
}