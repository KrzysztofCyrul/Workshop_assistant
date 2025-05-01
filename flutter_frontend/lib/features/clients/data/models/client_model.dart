import '../../domain/entities/client.dart';

class ClientModel extends Client{
  ClientModel({
    required super.id,
    required super.workshopId,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    super.address,
    super.segment,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      workshopId: json['workshop'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      segment: json['segment'] ?? '',
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

  Client toEntity() {
    return Client(
      id: id,
      workshopId: workshopId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      segment: segment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static ClientModel fromEntity(Client client) {
    return ClientModel(
      id: client.id,
      workshopId: client.workshopId,
      firstName: client.firstName,
      lastName: client.lastName,
      email: client.email,
      phone: client.phone,
      address: client.address,
      segment: client.segment,
      createdAt: client.createdAt,
      updatedAt: client.updatedAt,
    );
  }
}