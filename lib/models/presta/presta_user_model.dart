import 'package:demarcheur_app/services/config.dart';

class PrestaUserModel {
  final String? id;
  final String companyName;
  final List imageUrl;
  final String location;
  final String status;
  final String categorie;
  final String about;
  final int salary;
  final String? email;
  final String? phoneNumber;
  final double? rate;

  PrestaUserModel({
    this.id,
    required this.companyName,
    required this.imageUrl,
    required this.location,
    required this.status,
    required this.categorie,
    required this.about,
    required this.salary,
    this.email,
    this.phoneNumber,
    this.rate,
  });

  factory PrestaUserModel.fromJson(Map<String, dynamic> json) {
    return PrestaUserModel(
      id: json['id'],
      companyName: json['companyName'] ?? '',
      imageUrl: (json['imageUrl'] as List? ?? [])
          .map((e) => Config.getImgUrl(e.toString()))
          .where((e) => e != null)
          .cast<String>()
          .toList(),
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      categorie: json['categorie'] ?? '',
      about: json['about'] ?? '',
      salary: int.tryParse(json['salary']?.toString() ?? '0') ?? 0,
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      rate: double.tryParse(json['rate']?.toString() ?? '0') ?? 0.0,
    );
  }

  // Serialize Model → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'imageUrl': imageUrl,
    'location': location,
    'status': status,
    'categorie': categorie,
    'about': about,
    'salary': salary,
    'email': email,
    'phoneNumber': phoneNumber,
    'rate': rate,
  };
}


