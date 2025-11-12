// lib/services/api_service.dart
import 'dart:convert';
import 'package:demarcheur_app/models/job_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://your-api-url.com/api';

  Future<List<JobModel>> fetchJobs() async {
    final response = await http.get(Uri.parse('$baseUrl/doctors'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => JobModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }
}
