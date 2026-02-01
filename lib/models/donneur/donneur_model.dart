import 'dart:io';

import 'package:demarcheur_app/services/config.dart';

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
      id:
          (json['userId'] ??
                  json['id'] ??
                  json['_id'] ??
                  json['user_id'] ??
                  json['donneur_id'])
              ?.toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
      adress:
          json['adress']?.toString() ??
          json['address']?.toString() ??
          json['location']?.toString(),
      city: json['city']?.toString(),
      profile: Config.getImgUrl(
        json['profile']?.toString() ??
            json['image']?.toString() ??
            json['photo']?.toString() ??
            json['photoPath']?.toString() ??
            json['photo_path']?.toString() ??
            json['profilePath']?.toString(),
      ),

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
    "image": profile,
    "name_organization": nameOrganization,
  };
}
