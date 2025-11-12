// application_provider.dart
import 'package:flutter/foundation.dart';
import '../models/application_model.dart';

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

  // Simulated async load (fills sample data)
  Future<void> loadApplication() async {
    _isLoading = true;
    notifyListeners();
    debugPrint('[ApplicationProvider] loadApplication started');

    try {
      await Future.delayed(const Duration(seconds: 5));
      _allapplication = [
        ApplicationModel(
          id: 1,
          companyName: "TechCorp",
          title: "Flutter Developer",
          status: "En attente",
          logo: "https://placehold.co/100x100",
          location: "Conakry",
          postDate: 'il y a 2 jours',
          jobStatus: "Disponible",
        ),
        ApplicationModel(
          id: 2,
          companyName: "CodeHub",
          title: "Backend Engineer",
          status: "Interview",
          logo: "https://placehold.co/100x100",
          location: "Labe",
          postDate: 'il y a 10 minutes',
          jobStatus: "Disponible",
        ),
        ApplicationModel(
          id: 3,
          companyName: "Google",
          title: "UI/UX Designer",
          status: "Accepte",
          logo: "https://placehold.co/100x100",
          location: "Conakry",
          postDate: 'il y a 2 jours',
          jobStatus: "Plus disponible",
        ),
      ];
      _allApp = _allapplication;
      _isLoading = false;
      notifyListeners();
      debugPrint(
        '[ApplicationProvider] loaded ${_allapplication.length} items',
      );
    } catch (ex, st) {
      debugPrint('[ApplicationProvider] loadApplication ERROR: $ex\n$st');
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
_allapplication          .where((user) =>
              user.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
