import 'dart:io';

class DonneurModel {
  String? id;
  String name;
  String? phone;
  String email;
  String? password;
  String? adress;
  String? city;
  String? profile;
  File? image;
  String? nameOrganization;

  DonneurModel({
    this.id,
    required this.name,
    this.phone,
    required this.email,
    this.password,
    this.adress,
    this.city,
    this.profile,
    this.image,
    this.nameOrganization,
  });

  factory DonneurModel.fromJson(Map<String, dynamic> json) {
    print("DEBUG: DonneurModel.fromJson called with: $json");
    return DonneurModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
      adress:
          json['adress']?.toString() ??
          json['address']?.toString() ??
          json['location']?.toString(),
      city: json['city']?.toString(),
      profile: json['profile']?.toString(),
      nameOrganization: json['name_organization']?.toString(),
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    "name": name,
    "phone": phone,
    "email": email,
    "password": password,
    "adress": adress,
    "city": city,
    "profile": profile,
    "name_organization": nameOrganization,
  };
}
