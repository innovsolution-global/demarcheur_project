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
  double? rate;
  bool isVerified;

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
    this.rate = 0.0,
    this.isVerified = false,
  });

  factory DonneurModel.fromJson(Map<String, dynamic> json) {
    print("DEBUG: DonneurModel.fromJson called with keys: ${json.keys.toList()}");
    
    // Safety check: If this is clearly a GIVER/Enterprise, don't parse as Donneur
    final role = json['role']?.toString();
    if (role == 'GIVER') {
      print("WARNING: Attempted to parse GIVER data as DonneurModel. Returning empty.");
      // We could throw here, but returning a semi-empty model is safer for existing UI
    }

    return DonneurModel(
      id:
          (json['userId'] ??
                  json['id'] ??
                  json['_id'] ??
                  json['user_id'] ??
                  json['donneur_id'])
              ?.toString(),
      name: json['name']?.toString() ?? json['username']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
      adress:
          json['adress']?.toString() ??
          json['address']?.toString() ??
          json['location']?.toString(),
      city: json['city']?.toString(),
      profile: Config.getImgUrl(
        (json['profile'] ??
            json['logo'] ??
            json['image'] ??
            json['photo'] ??
            json['photoPath'] ??
            json['photo_path'] ??
            json['profilePath'] ??
            json['logoPath'] ??
            json['logo_path'] ??
            json['companyLogo'] ??
            json['company_logo'] ??
            json['entrepriseLogo'] ??
            json['entreprise_logo'] ??
            json['companyPicture'] ??
            json['entreprisePicture'] ??
            json['image_url'])?.toString(),
      ),
      nameOrganization: json['name_organization']?.toString() ?? json['nameOrganization']?.toString(),
      rate: (json['rate'] ?? 0.0).toDouble(),
      isVerified: json['isVerified'] ?? false,
    );
  }

  DonneurModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? password,
    String? adress,
    String? city,
    String? profile,
    File? image,
    String? nameOrganization,
    double? rate,
    bool? isVerified,
  }) {
    return DonneurModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      adress: adress ?? this.adress,
      city: city ?? this.city,
      profile: profile ?? this.profile,
      image: image ?? this.image,
      nameOrganization: nameOrganization ?? this.nameOrganization,
      rate: rate ?? this.rate,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// Merges another model into this one, keeping existing values if new ones are null or empty
  DonneurModel mergeFrom(DonneurModel other) {
    print("DEBUG: DonneurModel - Merging existing data with fresh data from API");
    return DonneurModel(
      id: (other.id != null && other.id!.isNotEmpty) ? other.id : id,
      name: (other.name.trim().isNotEmpty) ? other.name.trim() : name,
      phone: (other.phone != null && other.phone!.trim().isNotEmpty) ? other.phone!.trim() : phone,
      email: (other.email.trim().isNotEmpty) ? other.email.trim() : email,
      password: (other.password != null && other.password!.isNotEmpty) ? other.password : password,
      adress: (other.adress != null && other.adress!.trim().isNotEmpty) ? other.adress!.trim() : adress,
      city: (other.city != null && other.city!.trim().isNotEmpty) ? other.city!.trim() : city,
      profile: (other.profile != null && other.profile!.isNotEmpty) ? other.profile : profile,
      image: other.image ?? image,
      nameOrganization: (other.nameOrganization != null && other.nameOrganization!.isNotEmpty) ? other.nameOrganization : nameOrganization,
      rate: (other.rate != null && other.rate! > 0) ? other.rate : rate,
      isVerified: other.isVerified,
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': id,
    "name": name,
    "fullName": name,
    "username": name,
    "nom": name,
    "phone": phone,
    "phoneNumber": phone,
    "telephone": phone,
    "email": email,
    "password": password,
    "adress": adress,
    "address": adress,
    "city": city,
    "image": profile,
    "profile": profile,
    "logo": profile,
    "photo": profile,
    "name_organization": nameOrganization,
    "rate": rate,
    "isVerified": isVerified,
  };
}
