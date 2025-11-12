// lib/providers/job_provider.dart
import 'package:demarcheur_app/models/presta/presta_model.dart';
import 'package:flutter/foundation.dart';

class PrestaProvider extends ChangeNotifier {
  List<PrestaModel> _allJobs = [];
  List<PrestaModel> _filteredJobs = [];
  bool _isLoading = false;

  List<PrestaModel> get allJobs => _allJobs;
  List<PrestaModel> get filteredJobs => _filteredJobs;
  bool get isLoading => _isLoading;

  /// Load local (mock) data for now
  Future<void> loadVancies() async {
    _isLoading = true;
    notifyListeners();

    // 🧩 You can later replace this section with an API call
    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    _allJobs = [
      PrestaModel(
        id: '1',
        title: 'Besoin d\'un mecanicien',
        companyName: 'Alphonse loua',
        imageUrl: [
          "https://sammechanical.com/wp-content/uploads/2022/11/General-Mechanic-in-Industrial-Facility.jpg",
        ],
        postDate: 'il y a 10 minutes',
        location: 'Zaly',
        status: 'Disponible',
        categorie: 'Mecanique',
        exigences: [
          "Avoir une connaissance des outils de mecanique",
          "Être toujours à jour sur les nouvelles tendances",
          "Être capable de travailler dans une petite ou large équipe",
          "Avoir une expérience de 3 ans minimum",
        ],
        about: "Nous sommes une entreprise specialise dans la production",
        salary: "1.500.000 GNF",
      ),
      PrestaModel(
        id: '2',
        title: 'Besoin d\'un macon',
        companyName: 'Alphonse loua',
        imageUrl: [
          "https://tse4.mm.bing.net/th/id/OIP.NXdTT1tLRK7x548fJmY7bAHaFj?cb=ucfimgc2&rs=1&pid=ImgDetMain&o=7&rm=3",
        ],
        postDate: 'il y a 10 minutes',
        location: 'Zaly',
        status: 'Disponible',
        categorie: 'Macon',
        exigences: [
          "Avoir une connaissance des outils de maconnerie",
          "Être toujours à jour sur les nouvelles tendances",
          "Être capable de travailler dans une petite ou large équipe",
          "Avoir une expérience de 3 ans minimum",
        ],
        about: "Nous sommes une entreprise specialise dans la production",
        salary: "500.000 GNF",
      ),
      PrestaModel(
        id: '3',
        title: 'Besoin d\'un electricien',
        companyName: 'PlomPresta',
        imageUrl: [
          "https://th.bing.com/th/id/R.9926fc26263686ff691771e95d9ce011?rik=oXskjusCqtQC2w&riu=http%3a%2f%2fclipground.com%2fimages%2felectricity-clipart-12.jpg&ehk=zhJExsCcpK%2fZxZWpz9KiBSv4y8JWKi%2f8ZSGZGKJAatY%3d&risl=&pid=ImgRaw&r=0",
        ],
        postDate: 'il y a 28 minutes',
        location: 'Zaly',
        status: 'Disponible',
        categorie: 'Electricite',
        exigences: [
          "Avoir une connaissance des outils d'electricite",
          "Être toujours à jour sur les nouvelles tendances",
          "Être capable de travailler dans une petite ou large équipe",
          "Avoir une expérience de 3 ans minimum",
        ],
        about: "Nous sommes une entreprise specialise dans la production",
        salary: "A negocier",
      ),
      PrestaModel(
        id: '4',
        title: 'Besoin d\'un plombier',
        companyName: 'PlomPresta',
        imageUrl: [
          "https://tse1.mm.bing.net/th/id/OIP.fsJ7hcriyOCxJKTr-nU8-QHaE8?cb=ucfimgc2&rs=1&pid=ImgDetMain&o=7&rm=3",
        ],
        postDate: 'il y a 28 minutes',
        location: 'Zaly',
        status: 'Disponible',
        categorie: 'Plomberie',
        exigences: [
          "Avoir une connaissance des outils de plomberie",
          "Être toujours à jour sur les nouvelles tendances",
          "Être capable de travailler dans une petite ou large équipe",
          "Avoir une expérience de 3 ans minimum",
        ],
        about: "Nous sommes une entreprise specialise dans la production",
        salary: "250.000 GNF",
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
