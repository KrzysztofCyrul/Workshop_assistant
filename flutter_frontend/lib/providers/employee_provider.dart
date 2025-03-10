import 'package:flutter/material.dart';
import '../data/models/employee.dart';
import '../services/employee_service.dart';

class EmployeeProvider with ChangeNotifier {
  Employee? _employee;
  bool _isLoading = false;
  String? _errorMessage;
  List<Employee> _pendingMechanics = [];
  bool _isLoadingPending = false;

  Employee? get employee => _employee;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Employee> get pendingMechanics => _pendingMechanics;
  bool get isLoadingPending => _isLoadingPending;

  Future<void> fetchPendingMechanics(String accessToken, String workshopId) async {
  _isLoadingPending = true;
  _errorMessage = null;
  notifyListeners();

  try {
    _pendingMechanics = await EmployeeService.getPendingMechanics(accessToken, workshopId);
  } catch (e) {
    _errorMessage = 'Błąd podczas pobierania oczekujących mechaników: $e';
    _pendingMechanics = [];
  } finally {
    _isLoadingPending = false;
    notifyListeners();
  }
}

  Future<void> fetchEmployeeDetails(String accessToken, String workshopId, String employeeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employee = await EmployeeService.getEmployeeDetails(accessToken, workshopId, employeeId);
    } catch (e) {
      _errorMessage = 'Błąd podczas pobierania szczegółów pracownika: $e';
      _employee = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEmployeeStatus(String accessToken, String workshopId, String employeeId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await EmployeeService.updateEmployeeStatus(accessToken, workshopId, employeeId, status);
      _employee = await EmployeeService.getEmployeeDetails(accessToken, workshopId, employeeId);
    } catch (e) {
      _errorMessage = 'Błąd podczas aktualizacji statusu pracownika: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
}