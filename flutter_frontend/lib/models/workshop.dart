class Workshop {
  final String id;
  final String name;
  final String address;
  
  Workshop({
    required this.id,
    required this.name,
    required this.address,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}
