class Employee {
  final String id;
  final String userId;
  final String userFullName;
  final String workshopId;
  final String workshopName;
  final String position;
  final String status;
  final String hireDate;
  final String? salary;

  Employee({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.workshopId,
    required this.workshopName,
    required this.position,
    required this.status,
    required this.hireDate,
    this.salary,
  });
}
