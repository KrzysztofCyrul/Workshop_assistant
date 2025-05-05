import 'package:flutter_frontend/features/workshop/domain/entities/workshop.dart';

class WorkshopModel extends Workshop {
  WorkshopModel({
    required super.id,
    required super.name,
    required super.address,
    required super.postCode,
    required super.nipNumber,
    required super.email,
    required super.phoneNumber,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      postCode: json['post_code'],
      nipNumber: json['nip_number'],
      email: json['email'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'post_code': postCode,
      'nip_number': nipNumber,
      'email': email,
      'phone_number': phoneNumber,
    };
  }

  Workshop toEntity() {
    return Workshop(
      id: id,
      name: name,
      address: address,
      postCode: postCode,
      nipNumber: nipNumber,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  static WorkshopModel fromEntity(Workshop workshop) {
    return WorkshopModel(
      id: workshop.id,
      name: workshop.name,
      address: workshop.address,
      postCode: workshop.postCode,
      nipNumber: workshop.nipNumber,
      email: workshop.email,
      phoneNumber: workshop.phoneNumber,
    );
  }
}
