// lib/models/visit.dart
class Visit {
  final String id;
  final String date;
  final String name;
  final String description;
  final String parts;
  final double? price;
  final List<Car> cars;
  final List<Mechanic> mechanics;
  final String status;
  final Map<int, bool> strikedLines;
  final bool isActive;

  Visit({
    required this.id,
    required this.date,
    required this.name,
    required this.description,
    required this.parts,
    this.price,
    required this.cars,
    required this.mechanics,
    required this.status,
    this.strikedLines = const {},
    this.isActive = true,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      parts: json['parts'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      cars: (json['cars'] as List).map((car) => Car.fromJson(car)).toList(),
      mechanics: (json['mechanics'] as List).map((mechanic) => Mechanic.fromJson(mechanic)).toList(),
      status: json['status'] ?? '',
      strikedLines: (json['striked_lines'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), value as bool)),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'name': name,
      'description': description,
      'parts': parts,
      'price': price,
      'cars': cars.map((car) => car.toJson()).toList(),
      'mechanics': mechanics.map((mechanic) => mechanic.toJson()).toList(),
      'status': status,
      'striked_lines': strikedLines.map((key, value) => MapEntry(key.toString(), value)),
      'is_active': isActive,
    };
  }

  Visit copyWith({
    String? id,
    String? date,
    String? name,
    String? description,
    String? parts,
    double? price,
    List<Car>? cars,
    List<Mechanic>? mechanics,
    String? status,
    Map<int, bool>? strikedLines,
    bool? isActive,
  }) {
    return Visit(
      id: id ?? this.id,
      date: date ?? this.date,
      name: name ?? this.name,
      description: description ?? this.description,
      parts: parts ?? this.parts,
      price: price ?? this.price,
      cars: cars ?? this.cars,
      mechanics: mechanics ?? this.mechanics,
      status: status ?? this.status,
      strikedLines: strikedLines ?? this.strikedLines,
      isActive: isActive ?? this.isActive,
    );
  }
}

class Car {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String vin;
  final String licensePlate;
  final Client client;
  final String? company;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.vin,
    required this.licensePlate,
    required this.client,
    this.company,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      vin: json['vin'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      client: Client.fromJson(json['client']),
      company: json['company'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'vin': vin,
      'license_plate': licensePlate,
      'client': client.toJson(),
      'company': company,
    };
  }
}

class Client {
  final int id;
  final String firstName;
  final String? email;
  final String phone;

  Client({
    required this.id,
    required this.firstName,
    this.email,
    required this.phone,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'email': email,
      'phone': phone,
    };
  }
}

class Mechanic {
  final int id;
  final String firstName;
  final String lastName;

  Mechanic({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
