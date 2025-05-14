import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';

class QuotationPartModel extends QuotationPart {
  const QuotationPartModel({
    required String id,
    required String quotationId,
    required String name,
    required String? description,
    required double costPart,
    required double costService,
    required int quantity,
    required double buyCostPart,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          quotationId: quotationId,
          name: name,
          description: description,
          costPart: costPart,
          costService: costService,
          quantity: quantity,
          buyCostPart: buyCostPart,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory QuotationPartModel.fromJson(Map<String, dynamic> json) {
    return QuotationPartModel(
      id: json['id'],
      quotationId: json['quotation_id'],
      name: json['name'],
      description: json['description'],
      costPart: (json['cost_part'] as num).toDouble(),
      costService: (json['cost_service'] as num).toDouble(),
      quantity: json['quantity'],
      buyCostPart: (json['buy_cost_part'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_id': quotationId,
      'name': name,
      'description': description,
      'cost_part': costPart,
      'cost_service': costService,
      'quantity': quantity,
      'buy_cost_part': buyCostPart,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  QuotationPartModel copyWith({
    String? id,
    String? quotationId,
    String? name,
    String? description,
    double? costPart,
    double? costService,
    int? quantity,
    double? buyCostPart,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuotationPartModel(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      name: name ?? this.name,
      description: description ?? this.description,
      costPart: costPart ?? this.costPart,
      costService: costService ?? this.costService,
      quantity: quantity ?? this.quantity,
      buyCostPart: buyCostPart ?? this.buyCostPart,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}