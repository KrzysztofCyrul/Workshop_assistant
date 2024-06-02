// lib/providers/visit_provider.dart
import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../services/api_service.dart';

class VisitProvider with ChangeNotifier {
  List<Visit> _visits = [];
  bool _loading = true;
  String? _error;

  List<Visit> get visits => _visits;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchVisits() async {
    try {
      _visits = await ApiService.fetchVisits();
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
      _visits = _visits.map((visit) => visit.id == id ? Visit(
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
      ) : visit).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateStrikedLines(String id, Map<int, bool> strikedLines) async {
    try {
      await ApiService.updateStrikedLines(id, strikedLines);
      _visits = _visits.map((visit) => visit.id == id ? Visit(
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
      ) : visit).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
