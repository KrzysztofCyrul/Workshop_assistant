import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  EmployeeModel({
    required super.id,
    required super.userId,
    required super.userFullName,
    required super.workshopId,
    required super.workshopName,
    required super.position,
    required super.status,
    required super.hireDate,
    super.salary,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      userId: json['user'],
      userFullName: json['user_full_name'],
      workshopId: json['workshop'],
      workshopName: json['workshop_name'],
      position: json['position'] ?? '',
      status: json['status'] ?? '',
      hireDate: json['hire_date'] ?? '',
      salary: json['salary'], // Może być null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'user_full_name': userFullName,
      'workshop': workshopId,
      'workshop_name': workshopName,
      'position': position,
      'status': status,
      'hire_date': hireDate,
      'salary': salary, // Może być null
    };
  }

  Employee toEntity() {
    return Employee(
      id: id,
      userId: userId,
      userFullName: userFullName,
      workshopId: workshopId,
      workshopName: workshopName,
      position: position,
      status: status,
      hireDate: hireDate,
      salary: salary, // Może być null
    );
  }

  static EmployeeModel fromEntity(Employee employee) {
    return EmployeeModel(
      id: employee.id,
      userId: employee.userId,
      userFullName: employee.userFullName,
      workshopId: employee.workshopId,
      workshopName: employee.workshopName,
      position: employee.position,
      status: employee.status,
      hireDate: employee.hireDate,
      salary: employee.salary, // Może być null
    );
  }
}
