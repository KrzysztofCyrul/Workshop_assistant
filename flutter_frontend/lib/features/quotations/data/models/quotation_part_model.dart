import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';

class QuotationPartModel extends QuotationPart {
  QuotationPartModel({
    required super.id,
    required super.quotationId,
    required super.name,
    super.description,
    required super.costPart,
    required super.costService,
    required super.quantity,
    required super.createdAt,
    required super.updatedAt,
    required super.buyCostPart,
  });

  factory QuotationPartModel.fromJson(Map<String, dynamic> json) {
    return QuotationPartModel(
      id: json['id'] as String? ?? '',
      quotationId: json['quotation'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      costPart: double.tryParse(json['cost_part']?.toString() ?? '0.0') ?? 0.0,
      costService: double.tryParse(json['cost_service']?.toString() ?? '0.0') ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      buyCostPart: double.tryParse(json['buy_cost_part']?.toString() ?? '0.0') ?? 0.0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation': quotationId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'cost_part': costPart,
      'cost_service': costService,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'buy_cost_part': buyCostPart,
    };
  }

  QuotationPart toEntity() {
    return QuotationPart(
      id: id,
      quotationId: quotationId,
      name: name,
      description: description,
      quantity: quantity,
      costPart: costPart,
      costService: costService,
      buyCostPart: buyCostPart,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static QuotationPartModel fromEntity(QuotationPart part) {
    return QuotationPartModel(
      id: part.id,
      quotationId: part.quotationId,
      name: part.name,
      description: part.description,
      quantity: part.quantity,
      costPart: part.costPart,
      costService: part.costService,
      buyCostPart: part.buyCostPart,
      createdAt: part.createdAt,
      updatedAt: part.updatedAt,
    );
  }
}
