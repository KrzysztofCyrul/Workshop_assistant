part of 'vehicle_bloc.dart';

sealed class VehicleEvent {
  const VehicleEvent();
}

class LoadVehiclesEvent extends VehicleEvent {
  final String accessToken;
  final String workshopId;
  
  const LoadVehiclesEvent({
    required this.accessToken,
    required this.workshopId,
  });
}

class LoadVehicleDetailsEvent extends VehicleEvent {
  final String accessToken;
  final String workshopId;
  final String vehicleId;
  
  const LoadVehicleDetailsEvent({
    required this.accessToken,
    required this.workshopId,
    required this.vehicleId,
  });
}

class AddVehicleEvent extends VehicleEvent {
  final String accessToken;
  final String workshopId;
  final String clientId;
  final String make;
  final String model;
  final int year;
  final String vin;
  final String licensePlate;
  final int mileage;
  
  const AddVehicleEvent({
    required this.accessToken,
    required this.workshopId,
    required this.clientId,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.licensePlate,
    required this.mileage,
  });
}

class UpdateVehicleEvent extends VehicleEvent {
  final String accessToken;
  final String workshopId;
  final String vehicleId;
  final String make;
  final String model;
  final int year;
  final String vin;
  final String licensePlate;
  final int mileage;
  
  const UpdateVehicleEvent({
    required this.accessToken,
    required this.workshopId,
    required this.vehicleId,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.licensePlate,
    required this.mileage,
  });
}

class DeleteVehicleEvent extends VehicleEvent {
  final String accessToken;
  final String workshopId;
  final String vehicleId;
  
  const DeleteVehicleEvent({
    required this.accessToken,
    required this.workshopId,
    required this.vehicleId,
  });
}

class SearchVehiclesEvent extends VehicleEvent {
  final String accessToken;
  final String workshopId;
  final String query;
  
  const SearchVehiclesEvent({
    required this.accessToken,
    required this.workshopId,
    required this.query,
  });
}

class LoadVehiclesForClientEvent extends VehicleEvent {
  final String accessToken;
  final String workshopId;
  final String clientId;
  
  const LoadVehiclesForClientEvent({
    required this.accessToken,
    required this.workshopId,
    required this.clientId,
  });
}

class ResetVehicleStateEvent extends VehicleEvent {}
