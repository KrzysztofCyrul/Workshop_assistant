import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClientDetails {
  final ClientRepository repository;

  GetClientDetails(this.repository);

  Future<Client> execute(String workshopId, String clientId) async {
    return await repository.getClientDetails(workshopId, clientId);
  }
}