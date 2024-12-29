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

  Future<Client> addClient(
    String accessToken,
    String workshopId, {
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
      final newClient = await ClientService.createClient(
        accessToken: accessToken,
        workshopId: workshopId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        segment: segment,
      );
      _clients.add(newClient);
      notifyListeners();
      return newClient;
    } catch (e) {
      _errorMessage = 'Błąd podczas dodawania klienta: $e';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<void> deleteClient(String accessToken, String workshopId, String clientId) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    await ClientService.deleteClient(accessToken, workshopId, clientId);
    _clients.removeWhere((client) => client.id == clientId);
    notifyListeners();
  } catch (e) {
    _errorMessage = 'Błąd podczas usuwania klienta: $e';
    notifyListeners();
    throw e;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
Future<void> updateClient(
  String accessToken,
  String workshopId, {
  required String clientId,
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
    await ClientService.updateClient(
      accessToken: accessToken,
      workshopId: workshopId,
      clientId: clientId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      segment: segment,
    );
    // Update the client in the local list
    final clientIndex = _clients.indexWhere((client) => client.id == clientId);
    if (clientIndex != -1) {
      _clients[clientIndex] = Client(
        id: clientId,
        workshopId: workshopId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        segment: segment,
        createdAt: _clients[clientIndex].createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  } catch (e) {
    _errorMessage = 'Błąd podczas aktualizacji klienta: $e';
    notifyListeners();
    throw e;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

}
