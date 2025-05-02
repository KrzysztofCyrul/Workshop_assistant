class VehicleFormModel {
  final String make;
  final String model;
  final String? year;
  final String? vin;
  final String licensePlate;
  final String? mileage;
  final String clientId;

  const VehicleFormModel({
    required this.make,
    required this.model,
    this.year,
    this.vin,
    required this.licensePlate,
    this.mileage,
    required this.clientId,
  });

  Map<String, dynamic> toJson() => {
    'make': make,
    'model': model,
    'year': year != null ? int.tryParse(year!) : null,
    'vin': vin,
    'licensePlate': licensePlate,
    'mileage': mileage != null ? int.tryParse(mileage!) : null,
    'clientId': clientId,
  };
}