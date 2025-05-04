part of 'vehicle_bloc.dart';

sealed class VehicleState {
  const VehicleState();
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehiclesLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  const VehiclesLoaded({required this.vehicles});
}

class VehicleDetailsLoaded extends VehicleState {
  final Vehicle vehicle;

  const VehicleDetailsLoaded({required this.vehicle});
}

class VehicleDetailsWithRecordsLoaded extends VehicleDetailsLoaded {
  final List<ServiceRecord> serviceRecords;

  const VehicleDetailsWithRecordsLoaded({
    required super.vehicle,
    required this.serviceRecords,
  });
}

class VehicleOperationSuccess extends VehicleState {
  final String message;

  const VehicleOperationSuccess({required this.message});
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError({required this.message});
}

class VehicleUnauthenticated extends VehicleState {
  final String message;

  const VehicleUnauthenticated({
    this.message = 'Session expired. Please log in again.',
  });
}

class ServiceRecordsLoaded extends VehicleState {
  final List<ServiceRecord> serviceRecords;

  const ServiceRecordsLoaded({required this.serviceRecords});
}