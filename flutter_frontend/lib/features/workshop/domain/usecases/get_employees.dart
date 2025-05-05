import 'package:flutter_frontend/features/workshop/domain/entities/employee.dart';
import 'package:flutter_frontend/features/workshop/domain/repositories/workshop_repository.dart';

class GetEmployees {
  final WorkshopRepository repository;

  GetEmployees(this.repository);

  Future<List<Employee>> call(String workshopId) async {
    return await repository.getEmployees(workshopId);
  }
}