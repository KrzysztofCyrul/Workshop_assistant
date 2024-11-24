class RepairItem {
  final String id;
  final String appointmentId;
  final String description;
  final bool isCompleted;
  final String? completedById;
  final String status;
  final Duration? estimatedDuration;
  final Duration? actualDuration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double cost;
  final int order;

  RepairItem({
    required this.id,
    required this.appointmentId,
    required this.description,
    required this.isCompleted,
    this.completedById,
    required this.status,
    this.estimatedDuration,
    this.actualDuration,
    required this.createdAt,
    required this.updatedAt,
    required this.cost,
    required this.order,
  });

  factory RepairItem.fromJson(Map<String, dynamic> json) {
    return RepairItem(
      id: json['id'],
      appointmentId: json['appointment'],
      description: json['description'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      completedById: json['completed_by'],
      status: json['status'] ?? 'pending',
      estimatedDuration: json['estimated_duration'] != null
          ? Duration(seconds: json['estimated_duration'])
          : null,
      actualDuration: json['actual_duration'] != null
          ? Duration(seconds: json['actual_duration'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      cost: (json['cost'] != null) ? double.parse(json['cost'].toString()) : 0.0,
      order: json['order'] ?? 0,
    );
  }
}
