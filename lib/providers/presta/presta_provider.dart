import 'package:demarcheur_app/models/presta/presta_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:flutter/foundation.dart';

class PrestaProvider extends ChangeNotifier {
  List<PrestaModel> _allJobs = [];
  List<PrestaModel> _filteredJobs = [];
  bool _isLoading = false;

  List<PrestaModel> get allJobs => _allJobs;
  List<PrestaModel> get filteredJobs => _filteredJobs;
  bool get isLoading => _isLoading;

  /// Load local (mock) data for now
  /// Load real vacancies from API
  Future<void> loadVancies(String? token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final realVancies = await ApiService().getMyVacancies(token);

      _allJobs = realVancies.map((v) => PrestaModel(
        id: v.id,
        ownerId: v.companyId,
        title: v.title,
        companyName: v.companyName ?? 'Entreprise',
        imageUrl: [(Config.getImgUrl(v.companyImage ?? '') ?? '')],
        postDate: v.createdAt ?? 'Récent',
        location: v.city,
        status: 'Disponible',
        categorie: v.typeJobe,
        exigences: v.reqProfile.map((e) => e.toString()).toList(),
        about: v.description,
        salary: "${v.salary} GNF",
        originalVancy: v,
      )).toList();
    } catch (e) {
      debugPrint('Error loading vacancies in PrestaProvider: $e');
      _allJobs = [];
    }

    _filteredJobs = _allJobs;
    _isLoading = false;
    notifyListeners();
  
  }

  // 🔹 Dynamic categories list (always up-to-date)
  List<String> get categories {
    final uniqueCategories = _allJobs
        .map((job) => job.categorie)
        .toSet()
        .toList();
    uniqueCategories.sort(); // optional: sort alphabetically
    return ['Tout', ...uniqueCategories];
  }

  /// Search functionality
  void searchJobs(String query) {
    if (query.isEmpty) {
      _filteredJobs = _allJobs;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredJobs = _allJobs.where((job) {
        return job.title.toLowerCase().contains(lowerQuery) ||
            job.companyName.toLowerCase().contains(lowerQuery) ||
            job.location.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  final String _query = '';
  String _selectedType = 'Type\'emploi';
  String _selectedLocation = 'Lieu';
  String? _minSalary;

  // Initialize with jobs from JobProvider
  void setJobs(List<PrestaModel> jobs) {
    _allJobs = jobs;
    _filteredJobs = jobs;
    notifyListeners();
  }

  // Filter by type
  void filterByType(String type) {
    _selectedType = type;
    _applyFilters();
  }

  // Filter by location
  void filterByLocation(String location) {
    _selectedLocation = location;
    _applyFilters();
  }

  // Filter by salary range
  void filterBySalary(String val) {
    _minSalary = val;
    _applyFilters();
  }

  void _applyFilters() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      _filteredJobs = _allJobs.where((job) {
        final matchesQuery =
            job.title.toLowerCase().contains(_query) ||
            job.companyName.toLowerCase().contains(_query) ||
            job.location.toLowerCase().contains(_query);

        final matchesType =
            _selectedType == 'Type d\'emploi' || job.status == _selectedType;
        final matchesLocation =
            _selectedLocation == 'Lieu' || job.location == _selectedLocation;
        final matchesSalary = (_minSalary == null);

        return matchesQuery && matchesType && matchesLocation && matchesSalary;
      }).toList();

      _isLoading = false;
      notifyListeners();
    });
  }

  /// Reset search results
  void clearSearch() {
    _filteredJobs = _allJobs;
    notifyListeners();
  }
}
