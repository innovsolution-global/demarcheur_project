import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/services/config.dart';

class PrestaModel {
  final String? id;
  final String title;
  final String salary;
  final String companyName;
  final List imageUrl;
  final String postDate;
  final String location;
  final String status;
  final String categorie;
  final List exigences;
  final String about;
  final String? ownerId;
  final String? ownerRole;
  final AddVancyModel? originalVancy;

  PrestaModel({
    this.id,
    required this.title,
    required this.salary,
    required this.companyName,
    required this.imageUrl,
    required this.postDate,
    required this.location,
    required this.status,
    required this.categorie,
    required this.exigences,
    required this.about,
    this.ownerId,
    this.ownerRole,
    this.originalVancy,
  });

  factory PrestaModel.fromJson(Map<String, dynamic> json) {
    return PrestaModel(
      id: json['id']?.toString(),
      ownerId: json['ownerId']?.toString() ?? json['companyId']?.toString(),
      ownerRole: json['ownerRole']?.toString() ?? json['role']?.toString(),
      title: json['title']?.toString() ?? 'N/A',
      salary: json['salary']?.toString() ?? '0',
      companyName: json['companyName']?.toString() ?? 'Entreprise',
      imageUrl: (json['imageUrl'] as List? ?? [])
          .map((e) => Config.getImgUrl(e.toString()))
          .where((e) => e != null)
          .cast<String>()
          .toList(),
      postDate: json['postDate']?.toString() ?? 'N/A',
      location: (json['adresse'] ?? json['location'])?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'Disponible',
      categorie: (json['categorie'] ?? json['typeJobe'])?.toString() ?? 'N/A',
      exigences: (json['exigences'] as List? ?? []),
      about: json['about']?.toString() ?? json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'salary': this.salary,
    'companyName': companyName,
    'imageUrl': imageUrl,
    'postDate': postDate,
    'adresse': location,
    'status': status,
    'categorie': categorie,
    'exigences': exigences,
    'about': about,
    'ownerRole': ownerRole,
  };
}
