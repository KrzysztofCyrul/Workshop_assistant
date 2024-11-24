import 'vehicle.dart';
import 'client.dart';
import 'repair_item.dart';

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
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      workshopId: json['workshop'],
      client: Client.fromJson(json['client']),
      vehicle: Vehicle.fromJson(json['vehicle']),
      assignedMechanics: List<String>.from(json['assigned_mechanics'] ?? []),
      mileage: json['mileage'] ?? 0,
      scheduledTime: DateTime.parse(json['scheduled_time']),
      status: json['status'] ?? '',
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      repairItems: (json['repair_items'] as List<dynamic>?)
              ?.map((e) => RepairItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}
