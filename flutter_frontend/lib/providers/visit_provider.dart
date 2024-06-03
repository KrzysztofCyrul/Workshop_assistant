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

  Future<void> fetchArchivedVisits() async {
    try {
      _loading = true;
      _visits = await ApiService.fetchVisits();
      _visits = _visits.where((visit) => visit.status == 'archived').toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addCar(Car car) async {
    try {
      await ApiService.addCar(car.toJson());
      _cars.add(car);
      notifyListeners();
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to add car');
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

  Future<void> updateStrikedLines(
      String id, Map<int, bool> strikedLines) async {
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
      });
      _visits.add(newVisit);
      notifyListeners();
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to add visit');
    }
  }

  Future<void> confirmArchiveVisit(
      BuildContext context,
      String id,
      String name,
      String description,
      String date,
      String status,
      Car car,
      Mechanic mechanic) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Archive'),
          content: Text('Are you sure you want to archive this visit?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm) {
      await editVisit(id, name, description, date, 'archived', car, mechanic);
    }
  }

  Future<void> editVisit(String id, String name, String description,
      String date, String status, Car car, Mechanic mechanic) async {
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

      final visitData = {
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
      };

      // // Logowanie danych wysyłanych do API
      // print('Sending data to API: $visitData');

      await ApiService.editVisit(id, visitData);

      _visits = _visits
          .map((visit) => visit.id == id ? updatedVisit : visit)
          .toList();
      notifyListeners();
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to edit visit');
    }
  }

  Future<void> archiveVisit(String id) async {
    try {
      await ApiService.archiveVisit(id);
      _visits = _visits
          .map((visit) =>
      visit.id == id ? visit.copyWith(isActive: false) : visit)
          .toList();
      notifyListeners();
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to archive visit');
    }
  }

  Future<void> deleteVisit(String id) async {
    try {
      await ApiService.deleteVisit(id);
      _visits.removeWhere((visit) => visit.id == id);
      notifyListeners();
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to delete visit');
    }
  }

  Future<void> goToArchive(BuildContext context) async {
    Navigator.of(context).pushNamed('/archive');
  }
}
