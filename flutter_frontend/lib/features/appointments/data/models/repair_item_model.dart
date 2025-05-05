import 'package:flutter_frontend/features/appointments/domain/entities/repair_item.dart';

class RepairItemModel extends RepairItem {
  RepairItemModel({
    required super.id,
    required super.appointmentId,
    required super.description,
    required super.isCompleted,
    required super.completedBy,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.order,
  });

  factory RepairItemModel.fromJson(Map<String, dynamic> json) {
    return RepairItemModel(
      appointmentId: json['appointment'] as String?,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedBy: json['completed_by'] as String?,
      status: json['status'] as String? ?? 'pending',
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'description': description,
      'is_completed': isCompleted,
      'completed_by': completedBy,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'order': order,
    };
  }

  RepairItem toEntity() {
    return RepairItem(
      id: id,
      appointmentId: appointmentId,
      description: description,
      isCompleted: isCompleted,
      completedBy: completedBy,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      order: order,
    );
  }

  static RepairItemModel fromEntity(RepairItem repairItem) {
    return RepairItemModel(
      id: repairItem.id,
      appointmentId: repairItem.appointmentId,
      description: repairItem.description,
      isCompleted: repairItem.isCompleted,
      completedBy: repairItem.completedBy,
      status: repairItem.status,
      createdAt: repairItem.createdAt,
      updatedAt: repairItem.updatedAt,
      order: repairItem.order,
    );
  }
}