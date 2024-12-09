import 'employee.dart';
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      employeeProfiles: json['employee_profiles'] != null
          ? List<Employee>.from(
              json['employee_profiles'].map((e) => Employee.fromJson(e)))
          : [],
    );
  }

  get clients => null;
}
