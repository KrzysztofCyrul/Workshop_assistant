class QuotationPart {
  final String id;
  final String quotationId;
  final String name;
  final String? description;
  final double costPart;
  final double costService;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double buyCostPart;


  QuotationPart({
    required this.id,
    required this.quotationId,
    required this.name,
    this.description,
    required this.costPart,
    required this.costService,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.buyCostPart,
  });

  QuotationPart copyWith({
    String? id,
    String? quotationId,
    String? name,
    String? description,
    double? costPart,
    double? costService,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? buyCostPart,

  }) {
    return QuotationPart(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      name: name ?? this.name,
      description: description ?? this.description,
      costPart: costPart ?? this.costPart,
      costService: costService ?? this.costService,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      buyCostPart: buyCostPart ?? this.buyCostPart,
    );
  }

  factory QuotationPart.fromJson(Map<String, dynamic> json) {
    return QuotationPart(
      id: json['id'] as String? ?? '',
      quotationId: json['quotation'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      costPart: double.tryParse(json['cost_part']?.toString() ?? '0.0') ?? 0.0,
      costService: double.tryParse(json['cost_service']?.toString() ?? '0.0') ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      buyCostPart: double.tryParse(json['buy_cost_part']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation': quotationId,
      'name': name,
      'description': description,
      'cost_part': costPart,
      'cost_service': costService,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'buy_cost_part': buyCostPart,
    };
  }

  double get totalCost => costPart * quantity;
}