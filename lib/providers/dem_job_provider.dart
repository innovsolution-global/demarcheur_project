// lib/providers/job_provider.dart
import 'package:demarcheur_app/models/dem_job_model.dart';
import 'package:flutter/foundation.dart';

class DemJobProvider extends ChangeNotifier {
  List<DemJobModel> _allJobs = [];
  List<DemJobModel> _filteredJobs = [];
  bool _isLoading = false;

  List<DemJobModel> get allJobs => _allJobs;
  List<DemJobModel> get filteredJobs => _filteredJobs;
  bool get isLoading => _isLoading;

  /// Load local (mock) data for now
  Future<void> loadVancies() async {
    _isLoading = true;
    notifyListeners();

    // 🧩 You can later replace this section with an API call
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    _allJobs = [
      DemJobModel(
        id: '1',
        title: 'Flutter Developer',
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
        postDate: 'il y a 10 minutes',
        salary: 15000000.0,
        location: 'Zaly',
        type: 'Temps-plein',
        status: 'Disponible',
        category: 'Comptabilite',
      ),
      DemJobModel(
        id: '2',
        title: 'Frontend Engineer',
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
        postDate: 'il y a 28 jours',
        salary: 2000000.0,
        location: 'Kindia',
        type: 'Temps-plein',
        status: 'Disponible',
        category: 'Mobile App dev',
      ),
      DemJobModel(
        id: '2',
        title: 'Backend Engineer',
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
        postDate: 'il y a 20 jours',
        salary: 6000000.0,
        location: 'Mamou',
        type: 'Temps-plein',
        status: 'Plus dispo',
        category: 'Mecanique',
      ),
      DemJobModel(
        id: '3',
        title: 'UI/UX Designer',
        companyName: 'CodeHub',
        imageUrl:
            "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3",
        postDate: 'il y a 2 jours',
        salary: 4500000,
        location: 'Conakry',
        type: 'En ligne',
        status: 'Disponible',
        category: 'Finance',
      ),
    ];

    _filteredJobs = _allJobs;

    _isLoading = false;
    notifyListeners();
  }

  // 🔹 Dynamic categories list (always up-to-date)
  List<String> get categories {
    final uniqueCategories = _allJobs
        .map((job) => job.category)
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
  void setJobs(List<DemJobModel> jobs) {
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
            _selectedType == 'Type d\'emploi' || job.type == _selectedType;
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
