// lib/providers/job_provider.dart
import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/models/candidate_model.dart';
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

  Future<bool> sendCandidature(CandidateModel candidature, String token) async {
    _isLoading = true;
    notifyListeners();
    print('STARTED CALLING SEND CANDIDATURE');

    final response = await ApiService().addCandidate(candidature, token);
    try {
      if (response != null) {
        print('Candidature added successfully');
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Exception in sendCandidature: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateJobOffer(
    String id,
    AddVancyModel jobOffer,
    String? token,
  ) async {
    _isLoading = true;
    notifyListeners();

    final success = await ApiService().updateJobOffer(id, jobOffer, token);
    if (success) {
      await loadVancies(token); // Refresh list
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<dynamic> deleteJobOffer(String id, String? token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await ApiService().deleteJobOffer(id, token);
      if (success) {
        _vacancies.removeWhere((v) => v.id == id);
        _filterVancy.removeWhere((v) => v.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (e.toString().contains('API_ERROR: FOREIGN_KEY')) {
        _isLoading = false;
        notifyListeners();
        return 'FOREIGN_KEY_VIOLATION';
      }
      print('Error in provider delete: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
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
    final cats = _vacancies.map((j) => j.title).toSet().toList();
    cats.sort();
    return ['Tout', ...cats];
  }

  void clearSearch() {
    _filterVancy = List.from(_vacancies);
    notifyListeners();
  }
}
