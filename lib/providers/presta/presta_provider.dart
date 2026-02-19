import 'dart:convert';
import 'dart:io';

import 'package:demarcheur_app/models/enterprise/enterprise_model.dart';
import 'package:demarcheur_app/models/presta/presta_model.dart';
import 'package:demarcheur_app/models/presta/presta_user_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:demarcheur_app/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrestaProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<PrestaModel> _allJobs = [];
  List<PrestaModel> _filteredJobs = [];
  bool _isLoading = false;
  PrestaUserModel? _user;

  List<PrestaModel> get allJobs => _allJobs;
  List<PrestaModel> get filteredJobs => _filteredJobs;
  bool get isLoading => _isLoading;
  PrestaUserModel? get user => _user;

  /// Load profile for the SERVICE role
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService();
      final token = await storage.getToken() ?? prefs.getString('token');
      final role = prefs.getString('role');

      debugPrint('DEBUG PRESTA: token null? ${token == null}');
      debugPrint('DEBUG PRESTA: role: $role');

      if (token != null) {
        // 1. Try to load cached data first
        final cachedData = prefs.getString('last_user_data');
        EnterpriseModel? enterprise;

        if (cachedData != null) {
          try {
            final json = jsonDecode(cachedData);
            enterprise = EnterpriseModel.fromJson(json);
            debugPrint('DEBUG PRESTA: Loaded enterprise from cache');
          } catch (e) {
            debugPrint('DEBUG PRESTA: Error parsing cache: $e');
          }
        }

        // 2. Fetch fresh profile from API (Prestataires use giverProfile endpoint but with SERVICE role)
        final EnterpriseModel? freshEnterprise = await _apiService.giverProfile(
          token,
        );
        debugPrint(
          'DEBUG PRESTA: enterprise result from API null? ${freshEnterprise == null}',
        );

        if (freshEnterprise != null) {
          if (enterprise != null) {
            enterprise = enterprise.mergeFrom(freshEnterprise);
          } else {
            enterprise = freshEnterprise;
          }
          // Save updated data
          await prefs.setString('last_user_data', jsonEncode(enterprise.toJson()));
          if (enterprise.id != null) await prefs.setString('userId', enterprise.id!);
        }

        if (enterprise != null) {
          _user = PrestaUserModel(
            id: enterprise.id,
            companyName: enterprise.name,
            imageUrl: enterprise.profile != null ? [enterprise.profile!] : [],
            location: enterprise.adress ?? enterprise.city ?? '',
            status: enterprise.isVerified == true ? 'Vérifié' : 'Non vérifié',
            categorie: enterprise.specialite ?? '',
            about: enterprise.domaine ?? '',
            salary: 0,
            email: enterprise.email,
            phoneNumber: enterprise.phone ?? '',
            rate: enterprise.rate,
          );
          debugPrint('DEBUG PRESTA: user model set for ${enterprise.name}');
        } else {
          debugPrint(
            'DEBUG PRESTA: No user data available (API and Cache failed)',
          );
        }
      } else {
        debugPrint('DEBUG PRESTA: Token is NULL, cannot load profile');
      }
    } catch (e) {
      debugPrint('Error loading SERVICE profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update profile for the SERVICE role
  Future<bool> updateProfile(
    String name,
    String? phone,
    String? address,
    String? city,
    File? image,
  ) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Create a temporary EnterpriseModel to send to the API
      final enterpriseToUpdate = EnterpriseModel(
        id: _user!.id,
        name: name,
        email: _user!.email ?? '',
        phone: phone,
        adress: address,
        city: city,
        profile: _user!.imageUrl.isNotEmpty ? _user!.imageUrl.first : null,
        specialite: _user!.categorie,
        domaine: _user!.about,
      );

      final result = await _apiService.updateEnterpriseProfile(
        enterpriseToUpdate,
        image,
      );

      if (result != null) {
        debugPrint("DEBUG: updateProfile (PrestaProvider) - Success");
        // Reload to get fresh data and update local _user
        await loadUser();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating SERVICE profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Load real vacancies from API
  Future<void> loadVancies(String? token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final realVancies = await _apiService.getMyVacancies(token);

      _allJobs = realVancies
          .map(
            (v) => PrestaModel(
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
              ownerRole: v.ownerRole,
              originalVancy: v,
            ),
          )
          .toList();
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
