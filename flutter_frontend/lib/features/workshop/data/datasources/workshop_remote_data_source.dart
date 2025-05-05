import 'package:dio/dio.dart';
import 'package:flutter_frontend/core/errors/dio_error_handler.dart';
import 'package:flutter_frontend/core/utils/constants.dart' as api_constants;
import 'package:flutter_frontend/features/workshop/data/models/employee_model.dart';
import 'package:flutter_frontend/features/workshop/data/models/temporary_code_model.dart';
import 'package:flutter_frontend/features/workshop/data/models/workshop_model.dart';

class WorkshopRemoteDataSource {
  final Dio dio;

  WorkshopRemoteDataSource({required this.dio});

  Future<List<WorkshopModel>> getWorkshops() async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/');
      return (response.data as List).map((json) => WorkshopModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<WorkshopModel> getWorkshopDetails(String workshopId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/');
      return WorkshopModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> addWorkshop({
    required String name,
    required String address,
    required String postCode,
    required String nipNumber,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      await dio.post(
        '${api_constants.baseUrl}/workshops/',
        data: {
          'name': name,
          'address': address,
          'post_code': postCode,
          'nip_number': nipNumber,
          'email': email,
          'phone_number': phoneNumber,
        },
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> updateWorkshop({
    required String workshopId,
    required String name,
    required String address,
    required String postCode,
    required String nipNumber,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      await dio.put(
        '${api_constants.baseUrl}/workshops/$workshopId/',
        data: {
          'name': name,
          'address': address,
          'post_code': postCode,
          'nip_number': nipNumber,
          'email': email,
          'phone_number': phoneNumber,
        },
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> deleteWorkshop(String workshopId) async {
    try {
      await dio.delete('${api_constants.baseUrl}/workshops/$workshopId/');
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<List<EmployeeModel>> getEmployees(String workshopId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/employees/');
      return (response.data as List).map((json) => EmployeeModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<EmployeeModel> getEmployeeDetails(String workshopId, String employeeId) async {
    try {
      final response = await dio.get('${api_constants.baseUrl}/workshops/$workshopId/employees/$employeeId/');
      return EmployeeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> assignCreatorToWorkshop({
    required String workshopId,
    required String userId,
  }) async {
    try {
      await dio.post(
        '${api_constants.baseUrl}/workshops/$workshopId/employees/',
        data: {
          'user_id': userId,
          'position': 'Owner',
        },
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> useTemporaryCode(String code) async {
    try {
      await dio.post(
        '${api_constants.baseUrl}/use-code/',
        data: {'code': code},
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<TemporaryCodeModel> getTemporaryCode(String workshopId) async {
    try {
      final response = await dio.post(
        '${api_constants.baseUrl}/workshops/$workshopId/generate-code/',
      );
      return TemporaryCodeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> removeEmployeeFromWorkshop({
    required String workshopId,
    required String employeeId,
  }) async {
    try {
      await dio.delete(
        '${api_constants.baseUrl}/workshops/$workshopId/employees/$employeeId/',
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
