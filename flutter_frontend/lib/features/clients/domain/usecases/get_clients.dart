import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClients {
  final ClientRepository repository;

  GetClients(this.repository);

  Future<List<Client>> execute(String workshopId) async {
    return await repository.getClients(workshopId);
  }
}