import 'package:flutter/foundation.dart';
import '../models/application_model.dart';
import '../services/api_service.dart';

class ApplicationProvider extends ChangeNotifier {
  List<ApplicationModel> _allapplication = [];
  List<ApplicationModel> _allApp = [];
  bool _isLoading = false;

  List<ApplicationModel> get allapplication => _allapplication;
  bool get isLoading => _isLoading;
  List<ApplicationModel> get allApp => _allApp;

  // Load by passing an external list (optional)
  void loadAppli(List<ApplicationModel> app) {
    _allapplication = app;
    debugPrint(
      '[ApplicationProvider] loadAppli: ${_allapplication.length} items',
    );
    notifyListeners();
  }

  // Categories computed from _allapplication
  List<String> get categories {
    final uniqueCategories = _allapplication
        .map((app) => app.status.trim())
        .toSet()
        .toList();
    uniqueCategories.sort();
    final result = ['Tout', ...uniqueCategories];
    debugPrint('[ApplicationProvider] categories -> $result');
    return result;
  }

  // Load from API
  Future<void> loadApplication(
    String? token, {
    String? userId,
    String? role,
  }) async {
    _isLoading = true;
    notifyListeners();
    print(
      '[ApplicationProvider] loadApplication started - token: ${token != null}, userId: $userId, role: $role',
    );

    if (userId == null) {
      print('[ApplicationProvider] loadApplication ABORT: userId is null');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      List<ApplicationModel> results = [];

      if (role == 'GIVER') {
        // Employers (Givers) view candidates who applied to their jobs
        print(
          '[ApplicationProvider] Role GIVER detected. Fetching incoming candidates...',
        );
        final candidates = await ApiService().getEnterpriseCandidates(
          userId,
          token,
        );

        // Map CandidateModel to ApplicationModel
        results = candidates.map((c) {
          final applicantName = c.applicant?.name ?? 'Candidat inconnu';
          final applicantPhoto =
              c.applicant?.photo ?? 'https://placehold.co/100x100';
          return ApplicationModel(
            id: c.id ?? '',
            companyName:
                'Pour: Offre #${c.jobId.length > 4 ? c.jobId.substring(0, 4) : c.jobId}...',
            title: applicantName,
            status: c.status ?? 'En attente',
            logo: applicantPhoto,
            location: c.applicant?.location ?? 'N/A',
            postDate: c.createdAt ?? 'N/A',
            jobStatus: 'Actif',
          );
        }).toList();
      } else {
        // Job Seekers (Prestataires) view their own applications
        print(
          '[ApplicationProvider] Role $role detected. Fetching my applications...',
        );
        final data = await ApiService().getUserApplications(
          token,
          userId: userId,
        );
        results = data.map((json) => ApplicationModel.fromJson(json)).toList();
      }

      _allapplication = results;
      _allApp = _allapplication;
      _isLoading = false;
      notifyListeners();
      print(
        '[ApplicationProvider] loaded ${_allapplication.length} items from API',
      );
    } catch (ex, st) {
      print('[ApplicationProvider] loadApplication ERROR: $ex\n$st');
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ApplicationModel> _filteredUsers = [];
  String _searchQuery = '';

  List<ApplicationModel> get users =>
      _searchQuery.isEmpty ? _allApp : _filteredUsers;

  void searchUser(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredUsers = [];
    } else {
      _filteredUsers = _allapplication
          .where(
            (user) => user.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }
}
