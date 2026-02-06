import 'package:demarcheur_app/models/candidate_model.dart';
import 'package:demarcheur_app/models/user_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool _hasFetchedCandidates = false;
  List<UserModel> _allusers  =[];
   List<UserModel> get allusers => _allusers;
  bool  _isLoading = false;
  bool get isLoading => _isLoading;
  bool get hasFetchedCandidates => _hasFetchedCandidates;

  void clearCandidates() {
    _allusers = [];
    _hasFetchedCandidates = false;
    notifyListeners();
  }

  Future<void> loadUsers({String? token}) async {
    await loadCandidates(token);
  }

  Future<void> loadCandidates(
    String? token, {
    String? jobId,
    String? enterpriseId,
  }) async {
    print("DEBUG: UserProvider.loadCandidates ENTERED");
    print(
      "DEBUG: UserProvider - loadCandidates called with jobId: $jobId, enterpriseId: $enterpriseId",
    );
    _isLoading = true;
    notifyListeners();

    try {
      List<CandidateModel>? candidates;

      if (jobId != null && jobId.isNotEmpty) {
        print("DEBUG: UserProvider - Fetching by jobId: $jobId");
        candidates = await ApiService().getJobApplicants(jobId, token);
      } else if (enterpriseId != null && enterpriseId.isNotEmpty) {
        print("DEBUG: UserProvider - Fetching by enterpriseId: $enterpriseId");
        candidates = await ApiService().getEnterpriseCandidates(
          enterpriseId,
          token,
        );
      } else {
        print("DEBUG: UserProvider - No ID provided, cannot fetch candidates");
      }

      if (candidates != null) {
        print(
          "DEBUG: UserProvider - Fetched ${candidates.length} candidates from API",
        );

        // Enrich candidates with full profile data
        List<UserModel> enrichedUsers = [];

        for (var cand in candidates) {
          if (cand.applicant != null) {
            // We have basic user info, now fetch full profile
            final userId = cand.applicant!.id;
            print(
              "DEBUG: UserProvider - Applicant ID: $userId (name: ${cand.applicant!.name})",
            );
            if (userId != null && userId.isNotEmpty) {
              print(
                "DEBUG: UserProvider - Fetching full profile for user: $userId",
              );
              final fullProfile = await ApiService().getUserProfile(
                userId,
                token,
              );

              if (fullProfile != null) {
                // Convert DonneurModel to UserModel with candidate status
                print(
                  "DEBUG: UserProvider - Full profile data: name=${fullProfile.name}, email=${fullProfile.email}, profile=${fullProfile.profile}",
                );

                enrichedUsers.add(
                  UserModel(
                    id: fullProfile.id,
                    name: fullProfile.name,
                    speciality:
                        'N/A', // Speciality field doesn't exist in DonneurModel
                    exp: fullProfile.phone ?? 'N/A',
                    postDate: cand.createdAt ?? "",
                    location:
                        fullProfile.city ??
                        fullProfile.adress ??
                        cand.applicant!.location,
                    photo:
                        fullProfile.profile ??
                        'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png',
                    gender: 'N/A',
                    status: cand.status ?? 'En cours',
                    email: fullProfile.email ?? 'Non renseigné',
                    candidatureId: cand.id,
                  ),
                );
                print(
                  "DEBUG: UserProvider - Added user with photo: ${fullProfile.profile ?? 'default'}",
                );
              } else {
                // Fallback to basic info if profile fetch fails
                enrichedUsers.add(
                  UserModel(
                    id: cand.applicant!.id,
                    name: cand.applicant!.name,
                    speciality: cand.applicant!.speciality,
                    exp: cand.applicant!.phone ?? cand.applicant!.exp,
                    postDate: cand.createdAt ?? "",
                    location: cand.applicant!.location,
                    photo: cand.applicant!.photo,
                    gender: cand.applicant!.gender,
                    status: cand.status ?? 'En cours',
                    email: cand.applicant!.email,
                    phone: cand.applicant!.phone,
                    document: cand.cvUrl,
                    candidatureId: cand.id,
                  ),
                );
              }
            } else {
              enrichedUsers.add(
                UserModel(
                  id: cand.applicant!.id,
                  name: cand.applicant!.name,
                  speciality: cand.applicant!.speciality,
                  exp: cand.applicant!.phone ?? cand.applicant!.exp,
                  postDate: cand.createdAt ?? "",
                  location: cand.applicant!.location,
                  photo: cand.applicant!.photo,
                  gender: cand.applicant!.gender,
                  status: cand.status ?? 'En cours',
                  email: cand.applicant!.email,
                  phone: cand.applicant!.phone,
                  document: cand.cvUrl,
                  candidatureId: cand.id,
                ),
              );
            }
          } else {
            // Fallback if applicant is still null (shouldn't happen now)
            print("WARNING: Candidate ${cand.id} has null applicant data!");
            enrichedUsers.add(
              UserModel(
                id: cand.appliquantId,
                name: "Candidat Inconnu",
                speciality: "N/A",
                exp: "N/A",
                postDate: cand.createdAt ?? "",
                location: "N/A",
                photo:
                    "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png",
                gender: "N/A",
                status: cand.status ?? "En cours",
                candidatureId: cand.id,
              ),
            );
          }
        }

        _allusers = enrichedUsers;
      } else {
        print("DEBUG: UserProvider - candidates list is NULL");
      }
    } catch (e) {
      print('UserProvider.loadCandidates error: $e');
    }

    _isLoading = false;
    _hasFetchedCandidates = true;
    notifyListeners();
  }
}
