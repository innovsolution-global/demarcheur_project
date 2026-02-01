import 'dart:io';
import 'package:demarcheur_app/models/user_model.dart';

class CandidateModel {
  String? id;
  String jobId;
  String appliquantId;
  File? document;
  UserModel? applicant;
  String? status;
  String? createdAt;
  String? cvUrl;

  CandidateModel({
    this.id,
    required this.jobId,
    required this.appliquantId,
    this.document,
    this.applicant,
    this.status,
    this.createdAt,
    this.cvUrl,
  });
  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    print("DEBUG: CandidateModel raw JSON: $json");
    print("DEBUG: CandidateModel.fromJson - Keys: ${json.keys.toList()}");

    // Try to find the applicant/user data
    final applicantData =
        json['userInfor'] ?? // API uses this field name!
        json['appliquant'] ??
        json['user'] ??
        json['applicant'] ??
        json['searcher'] ??
        json['demandeur'];

    print(
      "DEBUG: CandidateModel.fromJson - applicantData is ${applicantData != null ? 'present' : 'NULL'}",
    );

    return CandidateModel(
      id:
          (json['_id'] ??
                  json['id'] ??
                  json['candidature_id'] ??
                  json['candidatureId'] ??
                  json['candidateId'] ??
                  json['_id']?['id'])
              ?.toString(),
      jobId:
          json['jobId']?.toString() ??
          json['JobId']?.toString() ??
          json['job_id']?.toString() ??
          '',
      appliquantId:
          json['appliquantId']?.toString() ??
          json['userId']?.toString() ??
          json['user_id']?.toString() ??
          json['searcherId']?.toString() ??
          '',
      applicant: applicantData != null
          ? UserModel.fromJson(applicantData)
          : null,
      status: json['status']?.toString() ?? json['statut']?.toString(),
      createdAt:
          json['createdAt']?.toString() ??
          json['created_at']?.toString() ??
          json['appliedAt']?.toString(),
      cvUrl:
          json['cv_url']?.toString() ??
          json['cv']?.toString() ??
          json['document_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'jobId': jobId,
    'appliquantId': appliquantId,
    'appliquant': applicant?.toJson(),
    'status': status,
    'createdAt': createdAt,
    'cvUrl': cvUrl,
  };
}
