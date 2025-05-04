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
}
