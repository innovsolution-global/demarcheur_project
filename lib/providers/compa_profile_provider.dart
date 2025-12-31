// lib/providers/job_provider.dart
import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:flutter/foundation.dart';

class CompaProfileProvider extends ChangeNotifier {
  List<AddVancyModel> _vacancies = [];
  List<AddVancyModel> _filterVancy = [];
  List<AddVancyModel> get filterVancy => _filterVancy;
  bool _isLoading = false;

  List<AddVancyModel> get vacancies => _vacancies;
  bool get isLoading => _isLoading;

  Future<void> loadVancies(String? token) async {
    _isLoading = true;
    notifyListeners();

    _vacancies = await ApiService().getMyVacancies(token);
    _filterVancy = List.from(_vacancies); // Populate filter list

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      _filterVancy = List.from(_vacancies);
    } else {
      final q = query.toLowerCase();
      _filterVancy = _vacancies
          .where(
            (job) =>
                job.city.toLowerCase().contains(q) ||
                job.title.toLowerCase().contains(q) ||
                job.typeJobe.toLowerCase().contains(q),
          )
          .toList();
    }
    notifyListeners();
  }
 List<String> get categories {
    final cats = _vacancies.map((j) => j.city).toSet().toList();
    cats.sort();
    return ['Tout', ...cats];
  }
  void clearSearch() {
    _filterVancy = List.from(_vacancies);
    notifyListeners();
  }
}
