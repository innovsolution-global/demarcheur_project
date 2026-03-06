import 'package:demarcheur_app/models/candidate_model.dart';
import 'package:demarcheur_app/models/user_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool _hasFetchedCandidates = false;
  bool _hasFetchError = false;
  List<UserModel> _allusers = [];
  List<UserModel> get allusers => _allusers;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool get hasFetchedCandidates => _hasFetchedCandidates;
  /// True si le dernier fetch a échoué (ex: 401 sans refresh token)
  bool get hasFetchError => _hasFetchError;

  void clearCandidates() {
    _allusers = [];
    _hasFetchedCandidates = false;
    _hasFetchError = false;
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

        // Enrich candidates with full profile data concurrently
        List<UserModel> enrichedUsers = [];
        Set<String> seenUserIds = {};

        // Prepare futures for profile fetching
        final profileFutures = candidates.map((cand) async {
          final userId = cand.applicant?.id ?? cand.appliquantId;
          if (userId == null || seenUserIds.contains(userId)) {
            print("DEBUG: UserProvider - Skipping duplicate/null applicant: $userId");
            return null;
          }
          seenUserIds.add(userId);

          if (cand.applicant != null) {
            final applicantId = cand.applicant!.id;
            print(
              "DEBUG: UserProvider - Applicant ID: $applicantId (name: ${cand.applicant!.name})",
            );
            if (applicantId != null && applicantId.isNotEmpty) {
              print(
                "DEBUG: UserProvider - Fetching full profile for user: $applicantId",
              );
              final fullProfile = await ApiService().getUserProfile(
                applicantId,
                token,
              );

              if (fullProfile != null) {
                print(
                  "DEBUG: UserProvider - Full profile data: name=${fullProfile.name}, email=${fullProfile.email}, profile=${fullProfile.profile}",
                );
                return UserModel(
                  id: fullProfile.id,
                  name: fullProfile.name,
                  speciality: 'N/A',
                  exp: fullProfile.phone ?? 'N/A',
                  postDate: cand.createdAt ?? "",
                  location: fullProfile.city ??
                      fullProfile.adress ??
                      cand.applicant!.location,
                  photo: fullProfile.profile ?? cand.applicant!.photo,
                  gender: 'N/A',
                  status: cand.status ?? 'En cours',
                  email: fullProfile.email ?? 'Non renseigné',
                  candidatureId: cand.id,
                );
              } else {
                return UserModel(
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
                );
              }
            } else {
              return UserModel(
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
              );
            }
          } else {
            print("WARNING: Candidate ${cand.id} has null applicant data!");
            return UserModel(
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
            );
          }
        });

        // Await all futures concurrently
        final resolvedProfiles = await Future.wait(profileFutures);
        
        // Filter out nulls (skipped duplicates)
        enrichedUsers = resolvedProfiles.whereType<UserModel>().toList();

        _allusers = enrichedUsers;
      } else {
        print("DEBUG: UserProvider - candidates list is NULL");
      }
    } on SessionExpiredException catch (e) {
      print('UserProvider.loadCandidates - SESSION EXPIRED: $e');
      _hasFetchError = true;
      // We could add a specific flag for session expired if needed
    } catch (e) {
      print('UserProvider.loadCandidates error: $e');
      _hasFetchError = true;
    }

    _isLoading = false;
    _hasFetchedCandidates = true;
    notifyListeners();
  }

   void clear() {
     _allusers = [];
     _isLoading = false;
     _hasFetchedCandidates = false;
     _hasFetchError = false;
     notifyListeners();
   }
}

