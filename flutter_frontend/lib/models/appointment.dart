import '../features/vehicles/data/models/vehicle_model.dart';
import 'client.dart';
import 'repair_item.dart';
import 'part.dart';

class Appointment {
  final String id;
  final String workshopId;
  final Client client;
  final VehicleModel vehicle;
  final List<String> assignedMechanics; // List of mechanic IDs
  final int mileage;
  final DateTime scheduledTime;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RepairItem> repairItems;
  final List<Part> parts; // Nowe pole dla części
  final String recommendations;
  final Duration? estimatedDuration;
  final double? totalCost;

  Appointment({
    required this.id,
    required this.workshopId,
    required this.client,
    required this.vehicle,
    required this.assignedMechanics,
    required this.mileage,
    required this.scheduledTime,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.repairItems,
    required this.parts, // Nowe pole
    required this.recommendations,
    this.estimatedDuration,
    this.totalCost,
  });

  Appointment copyWith({
    String? id,
    String? workshopId,
    Client? client,
    VehicleModel? vehicle,
    List<String>? assignedMechanics,
    int? mileage,
    DateTime? scheduledTime,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RepairItem>? repairItems,
    List<Part>? parts,
    String? recommendations,
    Duration? estimatedDuration,
    double? totalCost,
  }) {
    return Appointment(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      client: client ?? this.client,
      vehicle: vehicle ?? this.vehicle,
      assignedMechanics: assignedMechanics ?? this.assignedMechanics,
      mileage: mileage ?? this.mileage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      repairItems: repairItems ?? this.repairItems,
      parts: parts ?? this.parts,
      recommendations: recommendations ?? this.recommendations,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      totalCost: totalCost ?? this.totalCost,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String? ?? '',
      workshopId: json['workshop'] as String? ?? '',
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
      vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      assignedMechanics: (json['assigned_mechanics'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      repairItems: (json['repair_items'] as List<dynamic>?)
              ?.map((item) => RepairItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      parts: (json['parts'] as List<dynamic>?)
              ?.map((item) => Part.fromJson(item as Map<String, dynamic>))
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
      'workshop': workshopId,
      'client': client.toJson(),
      'vehicle': vehicle.toJson(),
      'assigned_mechanics': assignedMechanics,
      'mileage': mileage,
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'repair_items': repairItems.map((item) => item.toJson()).toList(),
      'parts': parts.map((part) => part.toJson()).toList(),
      'recommendations': recommendations,
      'estimated_duration': estimatedDuration?.toString(),
      'total_cost': totalCost,
    };
  }
}
