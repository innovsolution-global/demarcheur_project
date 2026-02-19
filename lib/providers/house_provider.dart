// Sanity checkComment
import 'dart:convert';
import 'package:demarcheur_app/models/enterprise/enterprise_model.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:demarcheur_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HouseProvider extends ChangeNotifier {
  final _apiService = ApiService();
  List<HouseModel> _allhouses = [];
  List<HouseModel> _housefiltered = [];
  bool _viewAll = false;
  bool get viewAll => _viewAll;
  bool _isLoading = false;
  List<HouseModel> get allhouses => _allhouses;
  static const int _limit = 5;

  EnterpriseModel? _user;
  EnterpriseModel? get user => _user;

  List<HouseModel> get firstFiveHouses => _housefiltered.length > _limit
      ? _housefiltered.take(_limit).toList()
      : _housefiltered;

  List<HouseModel> get housefiltered => _housefiltered;

  bool get isLoading => _isLoading;

  /// Load profile for the IMMO role
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService();
      final token = await storage.getToken() ?? prefs.getString('token');

      if (token != null) {
        // 1. Try to load cached data first for immediate display and field fallback
        final cachedData = prefs.getString('last_user_data');
        if (cachedData != null) {
          try {
            final json = jsonDecode(cachedData);
            _user = EnterpriseModel.fromJson(json);
            debugPrint('DEBUG IMMO: Loaded user from cache');
          } catch (e) {
            debugPrint('DEBUG IMMO: Error parsing cache: $e');
          }
        }

        // 2. Fetch fresh profile from API
        final EnterpriseModel? freshEnterprise = await _apiService.giverProfile(token);
        if (freshEnterprise != null) {
          if (_user != null) {
            _user = _user!.mergeFrom(freshEnterprise);
          } else {
            _user = freshEnterprise;
          }
          debugPrint('DEBUG IMMO: Fresh profile merged for ${_user?.name}');
        }
      }
    } catch (e) {
      debugPrint('Error loading IMMO profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setHouseFiltered(List<HouseModel> houses) {
    _housefiltered = houses;
    notifyListeners();
  }

  void toggleView() {
    _viewAll = !_viewAll;
    notifyListeners();
  }

  void searchHouse(String query) {
    if (query.isEmpty) {
      _housefiltered = _allhouses;
    } else {
      final q = query.toLowerCase();
      _housefiltered = _allhouses
          .where(
            (job) =>
                (job.companyName?.toLowerCase().contains(q) ?? false) ||
                (job.location?.toLowerCase().contains(q) ?? false) ||
                (job.category?.toLowerCase().contains(q) ?? false) ||
                (job.title?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    _viewAll = false;
    notifyListeners();
  }

  Future<void> loadHous({String? token, String? companyId}) async {
    _isLoading = true;
    _allhouses = [];
    _housefiltered = [];
    notifyListeners();

    try {
      final houses = await _apiService.getProperties(
        token,
        companyId: companyId,
      );
      if (houses.isNotEmpty) {
        print(
          '=== DEBUG: HouseProvider.loadHous - Inspecting ALL Statuses ===',
        );
        for (var h in houses) {
          print(
            'House ${h.id}: title="${h.title}", status="${h.status}", statusProperty="${h.statusProperty}"',
          );
        }
      }
      _allhouses = houses;
      _housefiltered = houses;
    } catch (e) {
      debugPrint("Error loading houses: $e");
      _allhouses = [];
      _housefiltered = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String?> get categories {
    final uniqueCategories = _allhouses
        .map((house) => house.category)
        .where((c) => c != null)
        .toSet()
        .toList();
    uniqueCategories.sort();
    return ['Tout', ...uniqueCategories];
  }

  void clearSearch() {
    _housefiltered = _allhouses;
    _viewAll = false;
    notifyListeners();
  }

  Future<bool> deleteHouse(String houseId, String? token) async {
    try {
      final success = await _apiService.deleteProperty(houseId, token);
      if (success) {
        _allhouses.removeWhere((h) => h.id == houseId);
        _housefiltered.removeWhere((h) => h.id == houseId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error deleting house: $e");
    }
    return false;
  }

  Future<bool> updateHouse(
    String houseId,
    HouseModel property,
    String? token,
  ) async {
    try {
      print('=== HouseProvider.updateHouse - START ===');
      print('DEBUG: HouseId: $houseId');
      final data = property.toUpdateJson();
      print('DEBUG: Update data: $data');

      final result = await _apiService.updateProperty(houseId, data, token);
      if (result != null) {
        print('DEBUG: Update success, refreshing local data');
        final updatedHouse = HouseModel.fromJson(result);
        final index = _allhouses.indexWhere((h) => h.id == houseId);
        if (index != -1) {
          _allhouses[index] = updatedHouse;
        }
        final filteredIndex = _housefiltered.indexWhere((h) => h.id == houseId);
        if (filteredIndex != -1) {
          _housefiltered[filteredIndex] = updatedHouse;
        }
        notifyListeners();
        print('=== HouseProvider.updateHouse - SUCCESS ===');
        return true;
      } else {
        print('DEBUG: Update returned null');
      }
    } catch (e) {
      print('=== HouseProvider.updateHouse - ERROR ===');
      debugPrint("Error updating house: $e");
    }
    return false;
  }
}

