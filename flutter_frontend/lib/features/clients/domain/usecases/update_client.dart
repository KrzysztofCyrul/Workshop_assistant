import '../repositories/client_repository.dart';

class UpdateClient {
  final ClientRepository repository;

  UpdateClient(this.repository);

  Future<void> execute({
    required String workshopId,
    required String clientId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? segment,
  }) async {
    await repository.updateClient(
      workshopId: workshopId,
      clientId: clientId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      segment: segment,
    );
  }
}