import 'package:flutter/material.dart';
import '../services/workshop_service.dart';
import '../models/workshop.dart';

class WorkshopProvider with ChangeNotifier {
  List<Workshop> _workshops = [];
  List<Workshop> get workshops => _workshops;

  Future<void> fetchWorkshops(String accessToken) async {
    _workshops = await WorkshopService.getWorkshops(accessToken);
    notifyListeners();
  }
}
