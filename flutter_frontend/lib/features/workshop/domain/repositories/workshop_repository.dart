import '../entities/employee.dart';
import '../entities/workshop.dart';
import '../entities/temporary_code.dart';

abstract class WorkshopRepository {
  Future<List<Workshop>> getWorkshops();
  Future<Workshop> getWorkshopDetails(String workshopId);
  Future<void> addWorkshop({
    required String name,
    required String address,
    required String postCode,
    required String nipNumber,
    required String email,
    required String phoneNumber,
  });
  Future<void> updateWorkshop({
    required String workshopId,
    required String name,
    required String address,
    required String postCode,
    required String nipNumber,
    required String email,
    required String phoneNumber,
  });
  Future<void> deleteWorkshop(String workshopId);
  Future<List<Employee>> getEmployees(String workshopId);
  Future<Employee> getEmployeeDetails(String workshopId, String employeeId);
  Future<void> assignCreatorToWorkshop ({
    required String workshopId,
    required String userId,
  });
  Future<void> removeEmployeeFromWorkshop({
    required String workshopId,
    required String employeeId,
  });
  Future<void> useTemporaryCode({
    required String code,
  });
  Future<TemporaryCode> getTemporaryCode(String workshopId);
}
