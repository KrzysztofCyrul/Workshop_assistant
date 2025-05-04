import '../../domain/entities/service_record.dart';

class ServiceRecordModel extends ServiceRecord {
  ServiceRecordModel({
    required super.id,
    required super.date,
    required super.description,
    required super.mileage,
    required super.createdAt,
    required super.updatedAt,
    required super.vehicleId,
    super.appointmentId,
  });

  factory ServiceRecordModel.fromJson(Map<String, dynamic> json) {
    return ServiceRecordModel(
      id: json['id'],
      date: json['date'],
      description: json['description'],
      mileage: json['mileage'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      vehicleId: json['vehicle'],
      appointmentId: json['appointment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'mileage': mileage,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'vehicle': vehicleId,
      'appointment': appointmentId,
    };
  }

  ServiceRecord toEntity() {
    return ServiceRecord(
      id: id,
      date: date,
      description: description,
      mileage: mileage,
      createdAt: createdAt,
      updatedAt: updatedAt,
      vehicleId: vehicleId,
      appointmentId: appointmentId,
    );
  }

  static ServiceRecordModel fromEntity(ServiceRecord entity) {
    return ServiceRecordModel(
      id: entity.id,
      date: entity.date,
      description: entity.description,
      mileage: entity.mileage,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      vehicleId: entity.vehicleId,
      appointmentId: entity.appointmentId,
    );
  }
}
