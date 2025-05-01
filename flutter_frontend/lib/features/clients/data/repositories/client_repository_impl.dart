import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/clients/domain/repositories/client_repository.dart';
import 'package:flutter_frontend/features/clients/data/datasources/client_remote_data_source.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;

  ClientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Client>> getClients(String workshopId) async {
    try {
      final models = await remoteDataSource.getClients(workshopId);
      return models.map((model) => model.toEntity()).toList();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<Client> getClientDetails(String workshopId, String clientId) async {
    try {
      final model = await remoteDataSource.getClientDetails(workshopId, clientId);
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> addClient({
    required String workshopId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? segment,
  }) async {
    try {
      await remoteDataSource.addClient(
        workshopId: workshopId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        segment: segment,
      );
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> updateClient({
    required String workshopId,
    required String clientId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? segment,
  }) async {
    try {
      await remoteDataSource.updateClient(
        workshopId: workshopId,
        clientId: clientId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        segment: segment,
      );
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> deleteClient(String workshopId, String clientId) async {
    try {
      await remoteDataSource.deleteClient(workshopId, clientId);
    } on Exception {
      rethrow;
    }
  }
}
