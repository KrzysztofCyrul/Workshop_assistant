class Workshop {
  final String id;
  final String name;
  final String address;
  final String postCode;
  final String nipNumber;
  final String email;
  final String phoneNumber;

  Workshop({
    required this.id,
    required this.name,
    required this.address,
    required this.postCode,
    required this.nipNumber,
    required this.email,
    required this.phoneNumber,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      postCode: json['post_code'],
      nipNumber: json['nip_number'],
      email: json['email'],
      phoneNumber: json['phone_number'],
    );
  }
}
