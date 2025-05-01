import '../repositories/client_repository.dart';

class DeleteClient {
  final ClientRepository repository;

  DeleteClient(this.repository);

  Future<void> execute(String workshopId, String clientId) async {
    await repository.deleteClient(workshopId, clientId);
  }
}