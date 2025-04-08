
import 'package:flutter_frontend/features/vehicles/data/models/vehicle_model.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/vehicle.dart';

class VehicleMapper {
  static Vehicle toEntity(VehicleModel model) {
    return Vehicle(
      id: model.id,
      clientId: model.clientId,
      make: model.make,
      model: model.model,
      year: model.year,
      vin: model.vin,
      licensePlate: model.licensePlate,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      mileage: model.mileage,
    );
  }

  static VehicleModel toModel(Vehicle entity) {
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