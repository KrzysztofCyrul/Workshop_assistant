import 'package:flutter_frontend/features/workshop/data/datasources/workshop_remote_data_source.dart';
import 'package:flutter_frontend/features/workshop/domain/entities/workshop.dart';
import 'package:flutter_frontend/features/workshop/domain/entities/employee.dart';
import 'package:flutter_frontend/features/workshop/domain/entities/temporary_code.dart';
import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class WorkshopRepositoryImpl implements WorkshopRepository {
  final WorkshopRemoteDataSource remoteDataSource;

  WorkshopRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Workshop>> getWorkshops() async {
    try {
      final models = await remoteDataSource.getWorkshops();
      return models.map((model) => model.toEntity()).toList();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<Workshop> getWorkshopDetails(String workshopId) async {
    try {
      final model = await remoteDataSource.getWorkshopDetails(workshopId);
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> addWorkshop({
    required String name,
    required String address,
    required String postCode,
    required String nipNumber,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      await remoteDataSource.addWorkshop(
        name: name,
        address: address,
        postCode: postCode,
        nipNumber: nipNumber,
        email: email,
        phoneNumber: phoneNumber,
      );
    } on Exception {
      rethrow;
    }
  }

  @override
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
      await remoteDataSource.updateWorkshop(
        workshopId: workshopId,
        name: name,
        address: address,
        postCode: postCode,
        nipNumber: nipNumber,
        email: email,
        phoneNumber: phoneNumber,
      );
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> deleteWorkshop(String workshopId) async {
    try {
      await remoteDataSource.deleteWorkshop(workshopId);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<List<Employee>> getEmployees(String workshopId) async {
    try {
      final models = await remoteDataSource.getEmployees(workshopId);
      return models.map((model) => model.toEntity()).toList();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<Employee> getEmployeeDetails(String workshopId, String employeeId) async {
    try {
      final model = await remoteDataSource.getEmployeeDetails(workshopId, employeeId);
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> assignCreatorToWorkshop({
    required String workshopId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.assignCreatorToWorkshop(
        workshopId: workshopId,
        userId: userId,
      );
    } on Exception {
      rethrow;
    }
  }
  
@override
  Future<void> useTemporaryCode({
    required String code,
  }) async {
    try {
      await remoteDataSource.useTemporaryCode(code);
    } on Exception {
      rethrow;
    }
  }

@override
  Future<TemporaryCode> getTemporaryCode(String workshopId) async {
    try {
      final model = await remoteDataSource.getTemporaryCode(workshopId);
      return model.toEntity();
    } on Exception {
      rethrow;
    }
  }
  
  @override
  Future<void> removeEmployeeFromWorkshop({required String workshopId, required String employeeId}) async {
    try {
      await remoteDataSource.removeEmployeeFromWorkshop(
        workshopId: workshopId,
        employeeId: employeeId,
      );
    } on Exception {
      rethrow;
    }
  }
}