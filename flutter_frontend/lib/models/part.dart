class Part {
  final String id;
  final String appointmentId;
  final String name;
  final String description;
  final int quantity;
  final double costPart;
  final double costService;
  final double buyCostPart;

  Part({
    required this.id,
    required this.appointmentId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.costPart,
    required this.costService,
    required this.buyCostPart,
  });

  Part copyWith({
    String? id,
    String? appointmentId,
    String? name,
    String? description,
    int? quantity,
    double? costPart,
    double? costService,
    double? buyCostPart,

  }) {
    return Part(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      costPart: costPart ?? this.costPart,
      costService: costService ?? this.costService,
      buyCostPart: buyCostPart ?? this.buyCostPart,
    );
  }

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
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

  // Metoda do serializacji do JSON
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
}
