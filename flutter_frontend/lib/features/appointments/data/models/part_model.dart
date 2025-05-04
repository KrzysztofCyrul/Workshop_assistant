import 'package:flutter_frontend/features/appointments/domain/entities/part.dart';

class PartModel extends Part {
  PartModel({
    required super.id,
    required super.appointmentId,
    required super.name,
    required super.description,
    required super.quantity,
    required super.costPart,
    required super.costService,
    required super.buyCostPart,
  });
  
  factory PartModel.fromJson(Map<String, dynamic> json) {
    return PartModel(
      id: json['id'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      costPart: double.tryParse(json['cost_part']?.toString() ?? '0.0') ?? 0.0,
      costService: double.tryParse(json['cost_service']?.toString() ?? '0.0') ?? 0.0,
      buyCostPart: double.tryParse(json['buy_cost_part']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'cost_part': costPart,
      'cost_service': costService,
      'buy_cost_part': buyCostPart,
    };
  }

  Part toEntity() {
    return Part(
      id: id,
      appointmentId: appointmentId,
      name: name,
      description: description,
      quantity: quantity,
      costPart: costPart,
      costService: costService,
      buyCostPart: buyCostPart,
    );
  }

  static PartModel fromEntity(Part part) {
    return PartModel(
      id: part.id,
      appointmentId: part.appointmentId,
      name: part.name,
      description: part.description,
      quantity: part.quantity,
      costPart: part.costPart,
      costService: part.costService,
      buyCostPart: part.buyCostPart,
    );
  }
}