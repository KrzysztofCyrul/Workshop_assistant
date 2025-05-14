import 'package:equatable/equatable.dart';

class QuotationPart extends Equatable {
  final String id;
  final String quotationId;
  final String name;
  final String? description;
  final double costPart;
  final double costService;
  final int quantity;
  final double buyCostPart;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuotationPart({
    required this.id,
    required this.quotationId,
    required this.name,
    required this.description,
    required this.costPart,
    required this.costService,
    required this.quantity,
    required this.buyCostPart,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalCost => (costPart + costService) * quantity;
  
  double get margin => costPart > 0 ? ((costPart - buyCostPart) / costPart) * 100 : 0;

  @override
  List<Object?> get props => [
        id,
        quotationId,
        name,
        description,
        costPart,
        costService,
        quantity,
        buyCostPart,
        createdAt,
        updatedAt,
      ];
}