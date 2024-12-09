class Employee {
  final String id;
  final String userId;
  final String userFullName;
  final String workshopId;
  final String position;
  final String status;
  final String hireDate;
  final String? salary; // Zmienione na nullable

  Employee({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.workshopId,
    required this.position,
    required this.status,
    required this.hireDate,
    this.salary, // Nullable
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      userId: json['user'],
      userFullName: json['user_full_name'],
      workshopId: json['workshop'],
      position: json['position'] ?? '',
      status: json['status'] ?? '',
      hireDate: json['hire_date'] ?? '',
      salary: json['salary'], // Może być null
    );
  }
}
