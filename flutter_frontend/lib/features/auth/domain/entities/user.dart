import 'package:flutter_frontend/features/workshop/domain/entities/employee.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final List<Employee> employeeProfiles;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    required this.employeeProfiles,
  });

  String get fullName => '$firstName $lastName';
}