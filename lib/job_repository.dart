import 'package:demarcheur_app/models/job_model.dart';
import 'package:demarcheur_app/services/api_service.dart';

class DoctorRepository {
  final ApiService _apiService = ApiService();

  Future<List<JobModel>> getAllJobs() async {
    return await _apiService.fetchJobs();
  }
}
