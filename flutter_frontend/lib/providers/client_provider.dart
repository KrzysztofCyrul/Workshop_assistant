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

Future<void> addClient(String accessToken, String workshopId, {
  required String firstName,
  required String lastName,
  required String email,
  String? phone,
  String? address,
  String? segment,
}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    await ClientService.createClient(
      accessToken: accessToken,
      workshopId: workshopId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      segment: segment,
    );
    notifyListeners();
  } catch (e) {
    _errorMessage = 'Błąd podczas dodawania klienta: $e';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

}
