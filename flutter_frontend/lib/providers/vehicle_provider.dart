// lib/providers/vehicle_provider.dart

import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVehicles(String accessToken, String workshopId, String clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicles = await VehicleService.getVehiclesForClient(accessToken, workshopId, clientId);
    } catch (e) {
      _errorMessage = 'Błąd podczas pobierania listy pojazdów: $e';
      _vehicles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
