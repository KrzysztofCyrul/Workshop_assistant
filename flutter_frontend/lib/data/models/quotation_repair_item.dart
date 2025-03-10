class QuotationRepairItem {
  final String id;
  final String quotationId;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double cost;
  final int order;

  QuotationRepairItem({
    required this.id,
    required this.quotationId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.cost,
    required this.order,
  });

  QuotationRepairItem copyWith({
    String? id,
    String? quotationId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? cost,
    int? order,
  }) {
    return QuotationRepairItem(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cost: cost ?? this.cost,
      order: order ?? this.order,
    );
  }

  factory QuotationRepairItem.fromJson(Map<String, dynamic> json) {
    return QuotationRepairItem(
      id: json['id'] as String? ?? '',
      quotationId: json['quotation'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      cost: double.tryParse(json['cost']?.toString() ?? '0.0') ?? 0.0,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation': quotationId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cost': cost,
      'order': order,
    };
  }
}