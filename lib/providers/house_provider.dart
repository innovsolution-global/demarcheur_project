import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:flutter/material.dart';

class HouseProvider extends ChangeNotifier {
  final _apiService = ApiService();
  List<HouseModel> _allhouses = [];
  List<HouseModel> _housefiltered = [];
  bool _viewAll = false;
  bool get viewAll => _viewAll;
  bool _isLoading = false;
  List<HouseModel> get allhouses => _allhouses;
  static const int _limit = 5; // Increased slightly for better default view
  
  List<HouseModel> get firstFiveHouses => _housefiltered.length > _limit
      ? _housefiltered.take(_limit).toList()
      : _housefiltered;
      
  List<HouseModel> get housefiltered => _housefiltered;

  bool get isLoading => _isLoading;

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

    _viewAll = false; // reset view when new search
    notifyListeners();
  }

  /// Loads properties for a specific company (Giver/Immo role)
  Future<void> loadHous({String? token, String? companyId}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _allhouses = await _apiService.getProperties(token, companyId: companyId);
      _housefiltered = _allhouses;
    } catch (e) {
      debugPrint("Error loading houses: $e");
      _allhouses = [];
      _housefiltered = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // 🔹 Dynamic categories list (always up-to-date)
  List<String?> get categories {
    final uniqueCategories = _allhouses
        .map((house) => house.category)
        .where((c) => c != null)
        .toSet()
        .toList();
    uniqueCategories.sort(); // optional: sort alphabetically
    return ['Tout', ...uniqueCategories];
  }

  void clearSearch() {
    _housefiltered = _allhouses;
    _viewAll = false;
    notifyListeners();
  }
}
