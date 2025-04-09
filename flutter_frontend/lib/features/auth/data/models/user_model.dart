import '../../domain/entities/user.dart';
import '../../../../models/employee.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.roles,
    required super.employeeProfiles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      employeeProfiles: (json['employee_profiles'] as List<dynamic>?)
          ?.map((e) => Employee.fromJson(e))
          .toList() ?? [],
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      roles: roles,
      employeeProfiles: employeeProfiles,
    );
  }
}