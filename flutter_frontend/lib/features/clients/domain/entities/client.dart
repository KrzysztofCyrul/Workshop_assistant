class Client {
  final String id;
  final String workshopId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final String? segment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.workshopId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    this.segment,
    required this.createdAt,
    required this.updatedAt,
  });
}
