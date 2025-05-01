import '../entities/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients(String workshopId);
  Future<Client> getClientDetails(String workshopId, String clientId);
  Future<void> addClient({
    required String workshopId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? segment,
  });
  Future<void> updateClient({
    required String workshopId,
    required String clientId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? segment,
  });
  Future<void> deleteClient(String workshopId, String clientId);
}
