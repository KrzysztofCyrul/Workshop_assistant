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
}