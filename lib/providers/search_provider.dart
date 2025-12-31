import 'package:flutter/foundation.dart';
import '../models/job_model.dart';

class SearchProvider extends ChangeNotifier {
  // 🔹 Full list of jobs from database
  List<JobModel> _allJobs = [];

  // 🔹 Filtered list depending on search & filters
  List<JobModel> _filteredJobs = [];

  // 🔹 Always contains FIRST 5 jobs
  // List<JobModel> get firstFiveJobs => _filteredJobs.length > _limit
  //     ? _filteredJobs.take(_limit).toList()
  //     : _filteredJobs;
  List<JobModel> get allJob => _allJobs;
  // 🔹 Controls the “Voir tout / Voir moins”
  bool _viewAll = false;
  bool get viewAll => _viewAll;

  // 🔹 Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 🔹 Getter: returns EITHER 5 jobs or all jobs
  List<JobModel> get filteredJobs => _filteredJobs;

  void toggleView() {
    _viewAll = !_viewAll;
    notifyListeners();
  }

  // 🔹 Load mock jobs (replace with DB later)
  Future<void> loadJobs() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _allJobs = [
      JobModel(
        id: '1',
        title: 'Flutter Developer',
        companyName: 'TechCorp',
        imageUrl: "https://th.bing.com/th/id/OIP.vmSybHNKgxBc1uunktEFOgHaHa",
        postDate: 'il y a 10 minutes',
        salary: 15000000,
        location: 'Zaly',
        type: 'Temps-plein',
        status: 'Disponible',
        category: 'Comptabilite',
      ),
      JobModel(
        id: '2',
        title: 'Frontend Engineer',
        companyName: 'CodeHub',
        imageUrl:
            'https://tse1.mm.bing.net/th/id/OIP.THYy3FmKCG6iaWGwn0Vn3AHaHa',
        postDate: 'il y a 28 jours',
        salary: 2000000,
        location: 'Kindia',
        type: 'Temps-plein',
        status: 'Disponible',
        category: 'Mobile App dev',
      ),
      JobModel(
        id: '3',
        title: 'Backend Engineer',
        companyName: 'CodeHub',
        imageUrl: 'https://th.bing.com/th/id/OIP.3WaQZ2RyQ3WT0rEOmtPUAAHaHa',
        postDate: 'il y a 20 jours',
        salary: 6000000,
        location: 'Mamou',
        type: 'Temps-plein',
        status: 'Plus dispo',
        category: 'Mecanique',
      ),
      JobModel(
        id: '4',
        title: 'UI/UX Designer',
        companyName: 'Google',
        imageUrl:
            "https://tse2.mm.bing.net/th/id/OIP.HP55nAQfHY4mlb4v9MxJKAHaEK",
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

  Future<void> setJobs(List<JobModel> allJobs) async {
    _allJobs = allJobs;
    _filteredJobs = _allJobs;
    await loadJobs();
  }

  // 🔹 Dynamic categories list
  List<String> get categories {
    final cats = _allJobs.map((j) => j.category).toSet().toList();
    cats.sort();
    return ['Tout', ...cats];
  }

  // 🔹 Search jobs
  void searchJobs(String query) {
    if (query.isEmpty) {
      _filteredJobs = _allJobs;
    } else {
      final q = query.toLowerCase();
      _filteredJobs = _allJobs
          .where((job) => job.title.toLowerCase().contains(q))
          .toList();
    }

    _viewAll = false; // reset view when new search
    notifyListeners();
  }

  // 🔹 Filters
  String _selectedType = "Type d'emploi";
  String _selectedLocation = "Lieu";
  String? _minSalary;
  final String _query = '';

  void filterByType(String type) {
    _selectedType = type;
    _applyFilters();
  }

  void filterByLocation(String location) {
    _selectedLocation = location;
    _applyFilters();
  }

  void filterBySalary(String salary) {
    _minSalary = salary;
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
            _selectedType == "Type d'emploi" || job.type == _selectedType;

        final matchesLocation =
            _selectedLocation == "Lieu" || job.location == _selectedLocation;

        final matchesSalary = _minSalary == null;

        return matchesQuery && matchesType && matchesLocation && matchesSalary;
      }).toList();

      _isLoading = false;
      _viewAll = false;
      notifyListeners();
    });
  }

  void clearSearch() {
    _filteredJobs = _allJobs;
    _viewAll = false;
    notifyListeners();
  }
}
