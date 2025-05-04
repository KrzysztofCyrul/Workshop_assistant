class RepairItem {
  final String id;
  final String? appointmentId;
  final String? description;
  bool isCompleted;
  final String? completedBy;
  String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int order;

  RepairItem({
    this.appointmentId,
    this.description,
    this.isCompleted = false,
    this.completedBy,
    this.status = 'pending',
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });
}
