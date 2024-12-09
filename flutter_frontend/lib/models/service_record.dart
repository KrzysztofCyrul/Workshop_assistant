class ServiceRecord {
  final String id;
  final String date;         // YYYY-MM-DD
  final String description;
  final int mileage;
  final String createdAt;
  final String updatedAt;
  final String vehicleId;    // ID pojazdu
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

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
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
}
