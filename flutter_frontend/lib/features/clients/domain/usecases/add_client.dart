import '../repositories/client_repository.dart';

class AddClient {
  final ClientRepository repository;

  AddClient(this.repository);

  Future<void> execute({
    required String workshopId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? segment,
  }) async {
    await repository.addClient(
      workshopId: workshopId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      segment: segment,
    );
  }
}