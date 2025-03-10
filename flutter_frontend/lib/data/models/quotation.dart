import 'package:flutter_frontend/data/models/vehicle_model.dart';

import 'client.dart';
import 'quotation_repair_item.dart';
import 'quotation_part.dart';

class Quotation {
  final String id;
  final Client client;
  final VehicleModel vehicle;
  final String workshopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? totalCost;
  final String quotationNumber;
  final List<QuotationRepairItem> repairItems;
  final List<QuotationPart> parts;

  Quotation({
    required this.id,
    required this.client,
    required this.vehicle,
    required this.workshopId,
    required this.createdAt,
    required this.updatedAt,
    this.totalCost,
    required this.quotationNumber,
    required this.repairItems,
    required this.parts,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'] as String? ?? '',
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
      vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      workshopId: json['workshop'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      totalCost: double.tryParse(json['total_cost']?.toString() ?? '0.0'),
      quotationNumber: json['quotation_number'] as String? ?? '',
      repairItems: (json['quotation_repair_items'] as List<dynamic>?)
              ?.map((item) => QuotationRepairItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      parts: (json['quotation_parts'] as List<dynamic>?)
              ?.map((item) => QuotationPart.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': client.toJson(),
      'vehicle': vehicle.toJson(),
      'workshop': workshopId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_cost': totalCost,
      'quotation_number': quotationNumber,
      'quotation_repair_items': repairItems.map((item) => item.toJson()).toList(),
      'quotation_parts': parts.map((part) => part.toJson()).toList(),
    };
  }
}