import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../services/api_service.dart';

class CandidatureProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CandidateModel> _applicants = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CandidateModel> get applicants => _applicants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchApplicants(String jobId, String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.getJobApplicants(jobId, token);

      // Note: We previously attempted to enrich candidates by fetching their full profiles
      // (ApiService.getUserProfile), but the backend does not expose an endpoint for this
      // (returns 404). We will rely on the basic info provided in the candidate list.
      _applicants = results;
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des candidatures: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearApplicants() {
    _applicants = [];
    notifyListeners();
  }

  Future<CandidateModel?> fetchCandidatureDetail(
    String candidatureId,
    String? token,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // The user named the method getJobApplicantById but it likely takes a candidatureId
      final results = await _apiService.getJobApplicantById(
        candidatureId,
        token,
      );
      if (results.isNotEmpty) {
        return results.first;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération du détail: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
