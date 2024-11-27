import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/client_service.dart';

class ClientProvider with ChangeNotifier {
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchClients(String accessToken, String workshopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clients = await ClientService.getClients(accessToken, workshopId);
    } catch (e) {
      _errorMessage = 'Błąd podczas pobierania listy klientów: $e';
      _clients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
