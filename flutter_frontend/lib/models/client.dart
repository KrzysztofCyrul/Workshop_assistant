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

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      workshopId: json['workshop'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      segment: json['segment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshop': workshopId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'segment': segment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Client && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
