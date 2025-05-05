import 'package:flutter_frontend/features/workshop/domain/entities/employee.dart';
import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class GetEmployeeDetails {
  final WorkshopRepository repository;

  GetEmployeeDetails(this.repository);

  Future<Employee> call(String workshopId, String employeeId) async {
    return await repository.getEmployeeDetails(workshopId, employeeId);
  }
}