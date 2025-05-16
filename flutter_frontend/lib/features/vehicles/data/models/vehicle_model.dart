import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  VehicleModel({
    required super.id,
    required super.clientId,
    required super.make,
    required super.model,
    required super.year,
    required super.vin,
    required super.licensePlate,
    required super.mileage,
    required super.createdAt,
    required super.updatedAt,
  });
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      clientId: json['client'] is Map ? json['client']['id'] : (json['client_id'] ?? json['client'] ?? ''),
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      vin: json['vin'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      mileage: json['mileage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': clientId,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'license_plate': licensePlate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'mileage': mileage,
    };
  }

  Vehicle toEntity() {
    return Vehicle(
      id: id,
      clientId: clientId,
      make: make,
      model: model,
      year: year,
      vin: vin,
      licensePlate: licensePlate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      mileage: mileage,
    );
  }

  static VehicleModel fromEntity(Vehicle entity) {
    return VehicleModel(
      id: entity.id,
      clientId: entity.clientId,
      make: entity.make,
      model: entity.model,
      year: entity.year,
      vin: entity.vin,
      licensePlate: entity.licensePlate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      mileage: entity.mileage,
    );
  }
}
