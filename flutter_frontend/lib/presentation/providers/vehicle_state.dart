import 'package:flutter_frontend/domain/entities/vehicle.dart';

class VehicleState {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final bool isLoading;
  final String? error;

  const VehicleState({
    this.vehicles = const [],
    this.selectedVehicle,
    this.isLoading = false,
    this.error,
  });

  VehicleState copyWith({
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    bool? isLoading,
    String? error,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}