class ServiceRecord {
  final String id;
  final String date; // YYYY-MM-DD
  final String description;
  final int mileage;
  final String createdAt;
  final String updatedAt;
  final String vehicleId; // ID pojazdu
  final String? appointmentId;

  ServiceRecord({
    required this.id,
    required this.date,
    required this.description,
    required this.mileage,
    required this.createdAt,
    required this.updatedAt,
    required this.vehicleId,
    this.appointmentId,
  });
}
