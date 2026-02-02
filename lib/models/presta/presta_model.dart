import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/services/config.dart';

class PrestaModel {
  final String? id;
  final String title;
  final String companyName;
  final List imageUrl;
  final String postDate;
  final String location;
  final String status;
  final String categorie;
  final List exigences;
  final String about;
  final String salary;
  final String? ownerId;
  final AddVancyModel? originalVancy;

  PrestaModel({
    this.id,
    required this.title,
    required this.companyName,
    required this.imageUrl,
    required this.postDate,
    required this.location,
    required this.status,
    required this.categorie,
    required this.exigences,
    required this.about,
    required this.salary,
    this.ownerId,
    this.originalVancy,
  });
  factory PrestaModel.fromJson(Map<String, dynamic> json) {
    return PrestaModel(
      id: json['id'],
      ownerId: json['ownerId']?.toString() ?? json['companyId']?.toString(),
      title: json['title'],
      companyName: json['companyName'],
      imageUrl: (json['imageUrl'] as List? ?? [])
          .map((e) => Config.getImgUrl(e.toString()))
          .where((e) => e != null)
          .cast<String>()
          .toList(),
      postDate: json['postDate'],
      location: json['adresse'],
      status: json['status'],
      categorie: json['categorie'],
      exigences: json['exigences'],
      about: json['about'],
      salary: json['salary'],
    );
  }

  // Serialize Model → JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'companyName': companyName,
    'imageUrl': imageUrl,
    'postDate': postDate,
    'adresse': location,
    'status': status,
    'categorie': categorie,
    'exigences': exigences,
    'about': about,
    'salary': salary,
  };
}
