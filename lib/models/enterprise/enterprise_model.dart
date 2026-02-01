import 'dart:io';
import 'package:demarcheur_app/services/config.dart';

class EnterpriseModel {
  String? id;
  String name;
  String? phone;
  String email;
  String? password;
  String? adress;
  String? city;
  String? serviceId;
  String? profile;
  File? image;
  String? role;
  double? rate;
  bool isVerified;

  EnterpriseModel({
    this.id,
    required this.name,
    this.phone,
    required this.email,
    this.password,
    this.adress,
    this.city,
    this.serviceId,
    this.profile,
    this.image,
    this.role,
    this.rate = 0.0,
    this.isVerified = false,
  });

  factory EnterpriseModel.fromJson(Map<String, dynamic> json) {
    print("DEBUG: EnterpriseModel parsing JSON with keys: ${json.keys.toList()}");
    final mappedId = (json['entreprise_id'] ?? json['id'] ?? json['_id'] ?? json['user_id'] ?? json['userId'])?.toString();
    print("DEBUG: EnterpriseModel - Mapped ID: $mappedId");
    
    return EnterpriseModel(
      id: mappedId,
      name: (json['name_organization'] ?? json['name'] ?? json['username'])?.toString() ?? '',
      phone: (json['phone'] ?? json['phoneNumber'] ?? json['phone_number'])?.toString(),
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
      adress: (json['adress'] ?? json['address'] ?? json['location'])?.toString(),
      city: json['city']?.toString(),
      serviceId: json['serviceId']?.toString(),
      profile: Config.getImgUrl(json['profile']?.toString() ??
               json['photoPath']?.toString() ??
               json['photo_path']?.toString() ??
               json['profilePath']?.toString()),
      role: json['role']?.toString(),
      rate: (json['rate'] ?? 0.0).toDouble(),
      isVerified: json['isVerified'] ?? false,
    );
  }

  EnterpriseModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? password,
    String? adress,
    String? city,
    String? serviceId,
    String? profile,
    File? image,
    String? role,
  }) {
    return EnterpriseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      adress: adress ?? this.adress,
      city: city ?? this.city,
      serviceId: serviceId ?? this.serviceId,
      profile: profile ?? this.profile,
      image: image ?? this.image,
      role: role ?? this.role,
      rate: rate ?? rate,
      isVerified: isVerified ?? isVerified,
    );
  }

  /// Merges another model into this one, keeping existing values if new ones are null or empty
  EnterpriseModel mergeFrom(EnterpriseModel other) {
    print("DEBUG: EnterpriseModel - Merging existing data with fresh data from API");
    return EnterpriseModel(
      id: (other.id != null && other.id!.isNotEmpty) ? other.id : id,
      name: (other.name.trim().isNotEmpty) ? other.name.trim() : name,
      phone: (other.phone != null && other.phone!.trim().isNotEmpty) ? other.phone!.trim() : phone,
      email: (other.email.trim().isNotEmpty) ? other.email.trim() : email,
      password: (other.password != null && other.password!.isNotEmpty) ? other.password : password,
      adress: (other.adress != null && other.adress!.trim().isNotEmpty) ? other.adress!.trim() : adress,
      city: (other.city != null && other.city!.trim().isNotEmpty) ? other.city!.trim() : city,
      serviceId: other.serviceId ?? serviceId,
      profile: (other.profile != null && other.profile!.isNotEmpty) ? other.profile : profile,
      image: other.image ?? image,
      role: (other.role != null && other.role!.isNotEmpty) ? other.role : role,
      rate: (other.rate != null && other.rate! > 0) ? other.rate : rate,
      isVerified: other.isVerified,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    "name_organization": name,
    "phone": phone,
    "email": email,
    "password": password,
    "adress": adress,
    "city": city,
    "serviceId": serviceId,
    "profile": profile,
    "role": role,
    "rate": rate,
    "isVerified": isVerified,
  };
}
