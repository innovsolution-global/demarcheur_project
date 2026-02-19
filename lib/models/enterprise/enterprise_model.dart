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
  String? specialite;
  String? domaine;

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
    this.specialite,
    this.domaine,
  });

  factory EnterpriseModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      print("DEBUG: EnterpriseModel - Received EMPTY JSON");
    } else {
      print("DEBUG: EnterpriseModel parsing JSON with keys: ${json.keys.toList()}");
    }

    final role = json['role']?.toString();
    if (role != 'GIVER') {
      print("WARNING: EnterpriseModel.fromJson - Role is NOT GIVER ($role). This might be a SEARCHER.");
    }

    final mappedId = (json['entreprise_id'] ?? json['id'] ?? json['_id'] ?? json['user_id'] ?? json['userId'])?.toString();
    
    return EnterpriseModel(
      id: mappedId,
      name: (json['name'] ?? json['name_organization'] ?? json['username'] ?? json['nameOrganization'])?.toString() ?? '',
      phone: (json['phone'] ?? json['phoneNumber'] ?? json['phone_number'])?.toString(),
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
      adress: (json['adress'] ?? json['address'] ?? json['location'])?.toString(),
      city: json['city']?.toString(),
      serviceId: (json['serviceId'] ?? json['service_id'])?.toString(),
      profile: Config.getImgUrl((json['profile'] ??
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
               json['image_url'])?.toString()),
      role: role ?? 'GIVER',
      rate: double.tryParse(json['rate']?.toString() ?? '0') ?? 0.0,
      isVerified: json['isVerified'] ?? false,
      specialite: (json['specialite'] ?? json['speciality'] ?? json['category'])?.toString(),
      domaine: (json['domaine'] ?? json['domain'])?.toString(),
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
    double? rate,
    bool? isVerified,
    String? specialite,
    String? domaine,
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
      rate: rate ?? this.rate,
      isVerified: isVerified ?? this.isVerified,
      specialite: specialite ?? this.specialite,
      domaine: domaine ?? this.domaine,
    );
  }

  /// Merges another model into this one, keeping existing values if new ones are null or empty
  EnterpriseModel mergeFrom(EnterpriseModel other) {
    print("DEBUG: EnterpriseModel - Merging existing data with fresh data from API");
    print("DEBUG: EnterpriseModel - Current name: '$name', Fresh name from API: '${other.name}'");
    return EnterpriseModel(
      id: (other.id != null && other.id!.isNotEmpty) ? other.id : id,
      name: (other.name.trim().isNotEmpty) ? other.name.trim() : name,
      phone: (other.phone != null && other.phone!.trim().isNotEmpty) ? other.phone!.trim() : phone,
      email: (other.email.trim().isNotEmpty) ? other.email.trim() : email,
      password: (other.password != null && other.password!.isNotEmpty) ? other.password : password,
      adress: (other.adress != null && other.adress!.trim().isNotEmpty) ? other.adress!.trim() : adress,
      city: (other.city != null && other.city!.trim().isNotEmpty) ? other.city!.trim() : city,
      serviceId: (other.serviceId != null && other.serviceId!.isNotEmpty) ? other.serviceId : serviceId,
      profile: (other.profile != null && other.profile!.isNotEmpty) ? other.profile : profile,
      image: other.image ?? image,
      role: (other.role != null && other.role!.isNotEmpty) ? other.role : role,
      rate: (other.rate != null && other.rate! > 0) ? other.rate : rate,
      isVerified: other.isVerified,
      specialite: (other.specialite != null && other.specialite!.isNotEmpty) ? other.specialite : specialite,
      domaine: (other.domaine != null && other.domaine!.isNotEmpty) ? other.domaine : domaine,
    );
  }

  Map<String, dynamic> toUpdateJson() => {
    "name": name,
    "fullName": name,
    "username": name,
    "nom": name,
    "nom_entreprise": name,
    "phone": phone,
    "telephone": phone,
    "phoneNumber": phone,
    "phone_number": phone,
    "adress": adress,
    "address": adress,
    "adresse": adress,
    "city": city,
    "ville": city,
    "profile": profile,
    "logo": profile,
    "image": profile,
    "specialite": specialite,
    "domaine": domaine,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': id,
    "name": name,
    "fullName": name,
    "name_organization": name,
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
    "serviceId": serviceId,
    "role": role,
    "rate": rate,
    "isVerified": isVerified,
    "profile": profile,
    "logo": profile,
    "image": profile,
    "photo": profile,
    "specialite": specialite,
    "domaine": domaine,
  };
}

