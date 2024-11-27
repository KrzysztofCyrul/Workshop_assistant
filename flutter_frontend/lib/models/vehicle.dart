class Vehicle {
  final String id;
  final String clientId;
  final String make;
  final String model;
  final int year;
  final String vin;
  final String licensePlate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int mileage;

  Vehicle({
    required this.id,
    required this.clientId,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.licensePlate,
    required this.createdAt,
    required this.updatedAt,
    required this.mileage,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      clientId: json['client'],
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      vin: json['vin'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      mileage: json['mileage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': clientId,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'license_plate': licensePlate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'mileage': mileage,
    };
  }
}
