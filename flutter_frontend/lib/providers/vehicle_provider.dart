import 'package:flutter/material.dart';
import '../data/models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class VehicleProvider with ChangeNotifier {
  List<VehicleModel> _vehicles = [];
  VehicleModel? _vehicle;
  bool _isLoading = false;
  String? _errorMessage;

  List<VehicleModel> get vehicles => _vehicles;
  VehicleModel? get vehicle => _vehicle;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVehicles(String accessToken, String workshopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicles = await VehicleService.getVehicles(accessToken, workshopId);
    } catch (e) {
      _errorMessage = 'Błąd podczas pobierania listy pojazdów: $e';
      _vehicles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVehiclesForClient(String accessToken, String workshopId, String clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicles = await VehicleService.getVehiclesForClient(accessToken, workshopId, clientId);
    } catch (e) {
      _errorMessage = 'Błąd podczas pobierania listy pojazdów klienta: $e';
      _vehicles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVehicleDetails(String accessToken, String workshopId, String vehicleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicle = await VehicleService.getVehicleDetails(accessToken, workshopId, vehicleId);
    } catch (e) {
      _errorMessage = 'Błąd podczas pobierania szczegółów pojazdu: $e';
      _vehicle = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 Future<void> addVehicle(
  String accessToken,
  String workshopId, {
  required String clientId,
  required String make,
  required String model,
  required int year,
  required String vin,
  required String licensePlate,
  required int mileage,
}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    await VehicleService.createVehicle(
      accessToken: accessToken,
      workshopId: workshopId,
      clientId: clientId,
      make: make,
      model: model,
      year: year,
      vin: vin,
      licensePlate: licensePlate,
      mileage: mileage,
    );
    notifyListeners();
  } catch (e) {
    _errorMessage = 'Błąd podczas dodawania pojazdu: $e';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


}