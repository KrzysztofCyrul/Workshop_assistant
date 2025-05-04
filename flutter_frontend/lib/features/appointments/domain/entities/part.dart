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
}
