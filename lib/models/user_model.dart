import 'package:demarcheur_app/services/config.dart';

class UserModel {
  final String? id;
  final String name;
  final String speciality;
  final String exp;
  final String postDate;
  final String location;
  final String photo;
  final String gender;
  String status;
  final String? email;
  final String? phone;
  final String? candidatureId;

  // Le document PDF associé à l'utilisateur
  final String? document; // fichier PDF local ou null

  UserModel({
    this.id,
    required this.name,
    required this.speciality,
    required this.exp,
    required this.postDate,
    required this.location,
    required this.photo,
    this.document,
    required this.gender,
    required this.status,
    this.email,
    this.phone,
    this.candidatureId,
  });

  // Conversion JSON → objet
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("DEBUG: UserModel.fromJson - Keys: ${json.keys.toList()}");
    print("DEBUG: UserModel.fromJson - userId value: '${json['userId']}'");
    print("DEBUG: UserModel.fromJson - id value: '${json['id']}'");
    
    final parsedId = json['userId']?.toString() ?? json['id']?.toString() ?? json['_id']?.toString();
    print("DEBUG: UserModel.fromJson - Final parsed id: '$parsedId'");
    
    return UserModel(
      id: json['userId']?.toString() ?? json['id']?.toString() ?? json['_id']?.toString(),
      name: json['fullName']?.toString() ?? 
            json['name']?.toString() ?? 
            json['username']?.toString() ?? 
            json['full_name']?.toString() ?? 
            'Inconnu',
      speciality: json['speciality']?.toString() ?? 
                  json['specialty']?.toString() ?? 
                  json['specialite']?.toString() ?? 
                  json['profession']?.toString() ?? 
                  'N/A',
      exp: json['exp']?.toString() ?? 
           json['experience']?.toString() ?? 
           json['experienceYear']?.toString() ?? 
           'N/A',
      postDate: json['postDate']?.toString() ?? 
                json['createdAt']?.toString() ?? 
                json['created_at']?.toString() ?? 
                '',
      location: json['location']?.toString() ?? 
                json['city']?.toString() ?? 
                json['ville']?.toString() ?? 
                json['adress']?.toString() ?? 
                'N/A',
      photo: Config.getImgUrl(
          json['photo']?.toString() ??
              json['profile']?.toString() ??
              json['image']?.toString() ??
              json['avatar']?.toString() ??
              json['photoPath']?.toString() ??
              json['photo_path']?.toString() ??
              json['picture']?.toString() ??
              json['profilePath']?.toString() ??
              json['image_url']?.toString() ??
              json['imageUrl']?.toString()) ??
          'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png',
      document: json['documentPath']?.toString() ?? json['document']?.toString(),
      gender: json['gender']?.toString() ?? json['sexe']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? json['statut']?.toString() ?? 'En cours',
      email: json['email']?.toString() ?? json['mail']?.toString() ?? 'Non renseigné',
      phone: json['phone']?.toString() ?? json['telephone']?.toString(),
      candidatureId: json['candidatureId']?.toString(),
    );
  }

  // Conversion objet → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'speciality': speciality,
    'exp': exp,
    'postDate': postDate,
    'location': location,
    'photo': photo,
    'documentPath': document,
    'gender': gender,
    'status': status,
    'email': email,
    'phone': phone,
    'candidatureId': candidatureId,
  };

  UserModel copyWithStatus(String newStatus) {
    return UserModel(
      id: id,
      name: name,
      speciality: speciality,
      exp: exp,
      postDate: postDate,
      location: location,
      photo: photo,
      document: document,
      gender: gender,
      status: newStatus,
      email: email,
      phone: phone,
    );
  }
}
