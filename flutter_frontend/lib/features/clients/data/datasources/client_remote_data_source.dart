import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/errors/dio_error_handler.dart';
import 'package:flutter_frontend/core/utils/constants.dart' as api_constants;
import 'package:flutter_frontend/features/clients/data/models/client_model.dart';

class ClientRemoteDataSource {
  final Dio dio;

  ClientRemoteDataSource({required this.dio});

  Future<List<ClientModel>> getClients(String workshopId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/clients/');
      return (response.data as List).map((json) => ClientModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<ClientModel> getClientDetails(String workshopId, String clientId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/clients/$clientId/');
      return ClientModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

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
      await dio.post(
        '${api_constants.baseUrl}/workshops/$workshopId/clients/',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'address': address,
          'segment': segment,
        },
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

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
      await dio.put(
        '${api_constants.baseUrl}/workshops/$workshopId/clients/$clientId/',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'address': address,
          'segment': segment,
        },
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> deleteClient(String workshopId, String clientId) async {
    try {
      await dio.delete('${api_constants.baseUrl}/workshops/$workshopId/clients/$clientId/');
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
