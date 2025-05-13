import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';
import 'package:flutter_frontend/features/appointments/domain/entities/repair_item.dart';
import 'package:flutter_frontend/features/appointments/domain/entities/part.dart';

class Appointment {
  final String id;
  final String workshopId;
  final Client client;
  final Vehicle vehicle;
  final List<String> assignedMechanics;
  final int mileage;
  final DateTime scheduledTime;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RepairItem> repairItems;
  final List<Part> parts;
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
    Vehicle? vehicle,
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
}
