import 'package:flutter_frontend/features/appointments/data/models/part_model.dart';
import 'package:flutter_frontend/features/appointments/data/models/repair_item_model.dart';
import 'package:flutter_frontend/features/appointments/domain/entities/appointment.dart';
import 'package:flutter_frontend/features/vehicles/data/models/vehicle_model.dart';
import 'package:flutter_frontend/features/clients/data/models/client_model.dart';

class AppointmentModel extends Appointment {
  AppointmentModel({
    required super.id,
    required super.workshopId,
    required super.client,
    required super.vehicle,
    required super.assignedMechanics,
    required super.mileage,
    required super.scheduledTime,
    required super.status,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    required super.repairItems,
    required super.parts,
    required super.recommendations,
    super.estimatedDuration,
    super.totalCost,
  });

factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      workshopId: json['workshop'] as String? ?? '',
      client: ClientModel.fromJson(json['client'] as Map<String, dynamic>),
      vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      assignedMechanics: (json['assigned_mechanics'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      repairItems: (json['repair_items'] as List<dynamic>?)
              ?.map((item) => RepairItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      parts: (json['parts'] as List<dynamic>?)
              ?.map((item) => PartModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      status: json['status'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      mileage: json['mileage'] as int? ?? 0,
      recommendations: json['recommendations'] as String? ?? '',
      estimatedDuration: json['estimated_duration'] != null
          ? Duration(hours: int.parse(json['estimated_duration'].split(':')[0]))
          : null,
      totalCost: double.tryParse(json['total_cost']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshop_id': workshopId,
      'client': (client as ClientModel).toJson(),
      'vehicle': (vehicle as VehicleModel).toJson(),
      'assigned_mechanics': assignedMechanics,
      'mileage': mileage,
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'repair_items': repairItems.map((item) => (item as RepairItemModel).toJson()).toList(),
      'parts': parts.map((item) => (item as PartModel).toJson()).toList(),
      'recommendations': recommendations,
      'estimated_duration': estimatedDuration?.inSeconds,
      'total_cost': totalCost,
    };
  }

  Appointment toEntity() {
    return Appointment(
      id: id,
      workshopId: workshopId,
      client: (client as ClientModel).toEntity(),
      vehicle: (vehicle as VehicleModel).toEntity(),
      assignedMechanics: assignedMechanics,
      mileage: mileage,
      scheduledTime: scheduledTime,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      repairItems: repairItems.map((item) => (item as RepairItemModel).toEntity()).toList(),
      parts: parts.map((item) => (item as PartModel).toEntity()).toList(),
      recommendations: recommendations,
      estimatedDuration: estimatedDuration,
      totalCost: totalCost,
    );
  }

  static AppointmentModel fromEntity(Appointment appointment) {
    return AppointmentModel(
      id: appointment.id,
      workshopId: appointment.workshopId,
      client: ClientModel.fromEntity(appointment.client),
      vehicle: VehicleModel.fromEntity(appointment.vehicle),
      assignedMechanics: appointment.assignedMechanics,
      mileage: appointment.mileage,
      scheduledTime: appointment.scheduledTime,
      status: appointment.status,
      notes: appointment.notes,
      createdAt: appointment.createdAt,
      updatedAt: appointment.updatedAt,
      repairItems: appointment.repairItems.map((item) => RepairItemModel.fromEntity(item)).toList(),
      parts: appointment.parts.map((item) => PartModel.fromEntity(item)).toList(),
      recommendations: appointment.recommendations,
      estimatedDuration: appointment.estimatedDuration,
      totalCost: appointment.totalCost,
    );
  }
}