import 'package:flutter/material.dart';
import 'package:flutter_frontend/domain/repositories/vehicle_repository.dart';
import '../../domain/entities/vehicle.dart';
import '../../core/errors/exceptions.dart';

class VehicleProvider1 with ChangeNotifier {
  final VehicleRepository repository;
  
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;
  Vehicle? _selectedVehicle;

  VehicleProvider1({required this.repository});

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Vehicle? get selectedVehicle => _selectedVehicle;

  Future<void> fetchVehicles(String accessToken, String workshopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await repository.getVehicles(accessToken, workshopId);
    } on ServerException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 Future<void> fetchVehicleDetails(
    String accessToken,
    String workshopId,
    String vehicleId,
  ) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _selectedVehicle = await repository.getVehicleDetails(
        accessToken,
        workshopId,
        vehicleId,
      );
    } catch (e) {
      _error = e.toString();
      _selectedVehicle = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> updateVehicle({
    required String accessToken,
    required String workshopId,
    required String vehicleId,
    required String make,
    required String model,
    required int year,
    required String vin,
    required String licensePlate,
    required int mileage,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.updateVehicle(
        accessToken: accessToken,
        workshopId: workshopId,
        vehicleId: vehicleId,
        make: make,
        model: model,
        year: year,
        vin: vin,
        licensePlate: licensePlate,
        mileage: mileage,
      );

      await fetchVehicleDetails(accessToken, workshopId, vehicleId);
    } on ServerException catch (e) {
      _error = e.message;
      throw Exception(e.message);
    } catch (e) {
      _error = 'Failed to update vehicle: ${e.toString()}';
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}