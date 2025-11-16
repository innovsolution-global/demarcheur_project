// lib/providers/job_provider.dart
import 'package:demarcheur_app/models/presta/presta_user_model.dart';
import 'package:flutter/foundation.dart';

class PrestaUserProvider extends ChangeNotifier {
  List<PrestaUserModel> _allJobs = [];
  List<PrestaUserModel> _filteredJobs = [];
  bool _isLoading = false;

  List<PrestaUserModel> get allJobs => _allJobs;
  List<PrestaUserModel> get filteredJobs => _filteredJobs;
  bool get isLoading => _isLoading;

  /// Load local (mock) data for now
  Future<void> loadVancies() async {
    _isLoading = true;
    notifyListeners();

    // 🧩 You can later replace this section with an API call
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    _allJobs = [
      PrestaUserModel(
        id: '1',
        companyName: 'Alphonse loua',
        imageUrl: [
          "https://sammechanical.com/wp-content/uploads/2022/11/General-Mechanic-in-Industrial-Facility.jpg",
        ],
        location: 'Zaly',
        status: 'Disponible',
        categorie: 'Mecanique',
        about: "Nous sommes une entreprise specialise dans la production",
        salary: 1500000,
      ),
      PrestaUserModel(
        id: '2',
        companyName: 'Alphonse loua',
        imageUrl: [
          "https://tse4.mm.bing.net/th/id/OIP.NXdTT1tLRK7x548fJmY7bAHaFj?cb=ucfimgc2&rs=1&pid=ImgDetMain&o=7&rm=3",
        ],
        location: 'Zaly',
        status: 'Disponible',
        categorie: 'Macon',

        about: "Nous sommes une entreprise specialise dans la production",
        salary: 500000,
      ),
      PrestaUserModel(
        id: '3',
        companyName: 'PlomPresta',
        imageUrl: [
          "https://th.bing.com/th/id/R.9926fc26263686ff691771e95d9ce011?rik=oXskjusCqtQC2w&riu=http%3a%2f%2fclipground.com%2fimages%2felectricity-clipart-12.jpg&ehk=zhJExsCcpK%2fZxZWpz9KiBSv4y8JWKi%2f8ZSGZGKJAatY%3d&risl=&pid=ImgRaw&r=0",
        ],
        location: 'Zaly',
        status: 'Disponible',
        categorie: 'Electricite',

        about: "Nous sommes une entreprise specialise dans la production",
        salary: 300000,
      ),
      PrestaUserModel(
        id: '4',
        companyName: 'PlomPresta',
        imageUrl: [
          "https://tse1.mm.bing.net/th/id/OIP.fsJ7hcriyOCxJKTr-nU8-QHaE8?cb=ucfimgc2&rs=1&pid=ImgDetMain&o=7&rm=3",
        ],
        location: 'Zaly',
        status: 'Disponible',
        categorie: 'Plomberie',

        about: "Nous sommes une entreprise specialise dans la production",
        salary: 25000,
      ),
    ];

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
        return job.companyName.toLowerCase().contains(lowerQuery) ||
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
  void setJobs(List<PrestaUserModel> jobs) {
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
