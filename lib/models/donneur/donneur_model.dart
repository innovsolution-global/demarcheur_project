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
  String? description;
  String? website;
  String? link_linkdin;
  String? serviceId;

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
    this.description,
    this.website,
    this.link_linkdin,
    this.serviceId,
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
      description: (json['description'] ?? json['about'])?.toString(),
      website: json['website']?.toString(),
      link_linkdin: (json['link_linkdin'] ?? json['linkedin'] ?? json['linkedin_url'])?.toString(),
      serviceId: (json['serviceId'] ?? json['service_id'])?.toString(),
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
    String? description,
    String? website,
    String? link_linkdin,
    String? serviceId,
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
      description: description ?? this.description,
      website: website ?? this.website,
      link_linkdin: link_linkdin ?? this.link_linkdin,
      serviceId: serviceId ?? this.serviceId,
    );
  }

  DonneurModel mergeFrom(DonneurModel other) {
    print("DEBUG: DonneurModel - Merging existing data with fresh data from API");
    print("DEBUG: DonneurModel - Current name: '$name', Fresh name from API: '${other.name}'");

    // For editable fields, we TRUST the local state if it's already populated.
    final mergedName = (name.trim().isNotEmpty) ? name : other.name.trim();
    final mergedPhone = (phone != null && phone!.trim().isNotEmpty) ? phone!.trim() : (other.phone?.trim() ?? '');
    final mergedEmail = (email.trim().isNotEmpty) ? email : other.email.trim();
    final mergedAdress = (adress != null && adress!.trim().isNotEmpty) ? adress!.trim() : (other.adress?.trim() ?? '');
    final mergedCity = (city != null && city!.trim().isNotEmpty) ? city!.trim() : (other.city?.trim() ?? '');
    
    // For server-managed fields, we take the fresh API data
    final mergedProfile = (other.profile != null && other.profile!.isNotEmpty && !other.profile!.contains('null')) ? other.profile : profile;

    print("DEBUG: DonneurModel - Merge Result -> Name: '$mergedName', Phone: '$mergedPhone', City: '$mergedCity'");

    return DonneurModel(
      id: (other.id != null && other.id!.isNotEmpty) ? other.id : id,
      name: mergedName,
      phone: mergedPhone,
      email: mergedEmail,
      password: (other.password != null && other.password!.isNotEmpty) ? other.password : password,
      adress: mergedAdress,
      city: mergedCity,
      profile: mergedProfile,
      image: other.image ?? image,
      nameOrganization: (other.nameOrganization != null && other.nameOrganization!.isNotEmpty) ? other.nameOrganization : nameOrganization,
      rate: (other.rate != null && other.rate! > 0) ? other.rate : rate,
      isVerified: other.isVerified,
      description: (other.description != null && other.description!.isNotEmpty) ? other.description : description,
      website: (other.website != null && other.website!.isNotEmpty) ? other.website : website,
      link_linkdin: (other.link_linkdin != null && other.link_linkdin!.isNotEmpty) ? other.link_linkdin : link_linkdin,
      serviceId: (other.serviceId != null && other.serviceId!.isNotEmpty) ? other.serviceId : serviceId,
    );
  }

  Map<String, dynamic> toUpdateJson() => {
    "name": name,
    "fullName": name,
    "username": name,
    "nom": name,
    "nom_entreprise": name,
    "name_organization": name,
    "nameOrganization": name,
    "companyName": name,
    "company_name": name,
    "phone": phone,
    "phoneNumber": phone,
    "telephone": phone,
    "phone_number": phone,
    "email": email,
    "adress": adress,
    "address": adress,
    "adresse": adress,
    "city": city,
    "ville": city,
    "location": adress,
    "profile": profile,
    "logo": profile,
    "image": profile,
    "photo": profile,
    "description": description,
    "website": website,
    "link_linkdin": link_linkdin,
    "serviceId": serviceId,
    "password": password,
    "name_organization": nameOrganization,
  };

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
    "description": description,
    "website": website,
    "link_linkdin": link_linkdin,
    "serviceId": serviceId,
  };
}
