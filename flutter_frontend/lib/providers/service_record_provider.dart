import 'package:flutter/material.dart';
import '../models/service_record.dart';
import '../services/service_record_service.dart';

class ServiceRecordProvider extends ChangeNotifier {
  List<ServiceRecord> _serviceRecords = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceRecord> get serviceRecords => _serviceRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchServiceRecords(String accessToken, String workshopId, String vehicleId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      _serviceRecords = await ServiceRecordService.getServiceRecords(accessToken, workshopId, vehicleId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
