// lib/providers/visit_provider.dart
import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../services/api_service.dart';

class VisitProvider with ChangeNotifier {
  List<Visit> _visits = [];
  List<Car> _cars = [];
  List<Mechanic> _mechanics = [];
  bool _loading = true;
  String? _error;

  List<Visit> get visits => _visits;
  List<Car> get cars => _cars;
  List<Mechanic> get mechanics => _mechanics;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchVisits() async {
    try {
      _visits = await ApiService.fetchVisits();
      _cars = await ApiService.fetchCars();
      _mechanics = await ApiService.fetchMechanics();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    try {
      await ApiService.updateStatus(id, newStatus);
      _visits = _visits
          .map((visit) => visit.id == id
          ? Visit(
        id: visit.id,
        date: visit.date,
        name: visit.name,
        description: visit.description,
        parts: visit.parts,
        price: visit.price,
        cars: visit.cars,
        mechanics: visit.mechanics,
        status: newStatus,
        strikedLines: visit.strikedLines,
        isActive: visit.isActive,
      )
          : visit)
          .toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateStrikedLines(String id, Map<int, bool> strikedLines) async {
    try {
      await ApiService.updateStrikedLines(id, strikedLines);
      _visits = _visits
          .map((visit) => visit.id == id
          ? Visit(
        id: visit.id,
        date: visit.date,
        name: visit.name,
        description: visit.description,
        parts: visit.parts,
        price: visit.price,
        cars: visit.cars,
        mechanics: visit.mechanics,
        status: visit.status,
        strikedLines: strikedLines,
        isActive: visit.isActive,
      )
          : visit)
          .toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addVisit(String name, String description, String date,
      String status, Car car, Mechanic mechanic) async {
    try {
      final newVisit = Visit(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(), // Example ID generation
        date: date,
        name: name,
        description: description,
        parts: '',
        price: null,
        cars: [car],
        mechanics: [mechanic],
        status: status,
        strikedLines: {},
        isActive: true,
      );
      await ApiService.addVisit({
        'id': newVisit.id,
        'date': newVisit.date,
        'name': newVisit.name,
        'description': newVisit.description,
        'parts': newVisit.parts,
        'price': newVisit.price,
        'cars': [
          {
            'id': car.id,
            'brand': car.brand,
            'model': car.model,
            'year': car.year,
            'vin': car.vin,
            'license_plate': car.licensePlate,
            'client': {
              'id': car.client.id,
              'first_name': car.client.firstName,
              'email': car.client.email,
              'phone': car.client.phone,
            },
            'company': car.company,
          }
        ],
        'mechanics': [
          {
            'id': mechanic.id,
            'first_name': mechanic.firstName,
            'last_name': mechanic.lastName,
          }
        ],
        'status': newVisit.status,
        'striked_lines':
        newVisit.strikedLines.map((k, v) => MapEntry(k.toString(), v)),
        'is_active': newVisit.isActive,
      });
      _visits.add(newVisit);
      notifyListeners();
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to add visit');
    }
  }

  Future<void> editVisit(String id, String name, String description, String date,
      String status, Car car, Mechanic mechanic) async {
    try {
      final updatedVisit = Visit(
        id: id,
        date: date,
        name: name,
        description: description,
        parts: '',
        price: null,
        cars: [car],
        mechanics: [mechanic],
        status: status,
        strikedLines: {},
        isActive: true,
      );
      await ApiService.editVisit(id, {
        'id': updatedVisit.id,
        'date': updatedVisit.date,
        'name': updatedVisit.name,
        'description': updatedVisit.description,
        'parts': updatedVisit.parts,
        'price': updatedVisit.price,
        'cars': [
          {
            'id': car.id,
            'brand': car.brand,
            'model': car.model,
            'year': car.year,
            'vin': car.vin,
            'license_plate': car.licensePlate,
            'client': {
              'id': car.client.id,
              'first_name': car.client.firstName,
              'email': car.client.email,
              'phone': car.client.phone,
            },
            'company': car.company,
          }
        ],
        'mechanics': [
          {
            'id': mechanic.id,
            'first_name': mechanic.firstName,
            'last_name': mechanic.lastName,
          }
        ],
        'status': updatedVisit.status,
        'striked_lines':
        updatedVisit.strikedLines.map((k, v) => MapEntry(k.toString(), v)),
        'is_active': updatedVisit.isActive,
      });
      _visits = _visits.map((visit) => visit.id == id ? updatedVisit : visit).toList();
      notifyListeners();
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to edit visit');
    }
  }

  Future<void> archiveVisit(String id) async {
    try {
      await ApiService.archiveVisit(id);
      _visits = _visits.map((visit) => visit.id == id ? visit.copyWith(isActive: false) : visit).toList();
      notifyListeners();
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to archive visit');
    }
  }
}
