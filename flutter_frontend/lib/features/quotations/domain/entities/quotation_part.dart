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

  const QuotationPart({
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

  double get totalCost => costPart * quantity;
  
  double get margin => costPart > 0 ? ((costPart - buyCostPart) / costPart) * 100 : 0;
}
