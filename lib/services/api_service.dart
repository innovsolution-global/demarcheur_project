// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/models/donneur/donneur_model.dart';
import 'package:demarcheur_app/models/enterprise/enterprise_model.dart';
import 'package:demarcheur_app/models/job_model.dart';
import 'package:demarcheur_app/models/services/service_model.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  final String baseUrl = Config.baseUrl;

  //for job seeker registration
  Future<Map<String, dynamic>?> donneurRegistration(
    DonneurModel donneur,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/register-searcher'),
      );

      // Add headers if required by backend
      request.headers.addAll({'Accept': 'application/json'});

      // Add text fields
      final fields = donneur.toJson();
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add image if present
      if (donneur.image != null) {
        final file = donneur.image!;
        final mimeType = lookupMimeType(file.path);

        if (mimeType == null || !mimeType.startsWith('image/')) {
          throw Exception('Selected file is not a valid image');
        }

        final mimeSplit = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Registration failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  //for service

  Future<Map<String, dynamic>?> serviceRegister(ServiceModel service) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(service),
      );
      if (response.statusCode == 200) {
        print('service selectionner avec success');
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Exception $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> registerGiver(
    EnterpriseModel enterprise,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/register-giver'),
      );

      // Add headers if required by backend
      request.headers.addAll({'Accept': 'application/json'});

      // Add text fields
      final fields = enterprise.toJson();
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add image if present
      if (enterprise.image != null) {
        final file = enterprise.image!;
        final mimeType = lookupMimeType(file.path);

        if (mimeType == null || !mimeType.startsWith('image/')) {
          throw Exception('Selected file is not a valid image');
        }

        final mimeSplit = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Registration failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> setLogin(String item, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'item': item, 'password': password}),
      );
      if (response.statusCode == 200) {
        print('Connected successfully');
        return jsonDecode(response.body);
      } else {
        print('Authentification faliled');
      }
    } catch (e) {
      throw e;
    }
    return null;
  }
  //for services

  Future<List<ServiceModel>> serviceList() async {
    print('START CALLING THE LIST');

    final response = await http.get(
      Uri.parse('$baseUrl/services'),
      headers: {'Content-Type': 'application/json'},
    );
    try {
      if (response.statusCode == 200) {
        print('Succes message');
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => ServiceModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('An exception occurred $e');
    }
    return [];
  }

  Future<EnterpriseModel?> giverProfile(String? token) async {
    print('DEBUG: ApiService.giverProfile - URL: $baseUrl/auth/profile-giver');
    print('DEBUG: ApiService.giverProfile - Token: $token');
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile-giver'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    try {
      if (response.statusCode == 200) {
        print('Giver Profile RAW: ${response.body}');
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body['data'] != null) {
            return EnterpriseModel.fromJson(body['data']);
          } else if (body['user'] != null) {
            return EnterpriseModel.fromJson(body['user']);
          }
          return EnterpriseModel.fromJson(body);
        }
      } else {
        print('Giver Profile failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error parsing giver profile: $e');
    }
    return null;
  }

  //load the givers
  Future<DonneurModel?> searcherProfile(String? token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile-searcher'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    try {
      if (response.statusCode == 200) {
        print('Searcher Profile: Success');
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body['data'] != null) {
            return DonneurModel.fromJson(body['data']);
          } else if (body['user'] != null) {
            return DonneurModel.fromJson(body['user']);
          }
          return DonneurModel.fromJson(body);
        }
      } else {
        print('Searcher Profile failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error parsing searcher profile: $e');
    }
    return null;
  }

  //adding job vancy
  Future<Map<String, dynamic>?> addVancy(
    AddVancyModel vancy,
    String? token,
  ) async {
    try {
      final body = jsonEncode(vancy);
      print('DEBUG: addVancy request body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/job-offers'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print('DEBUG: addVancy status: ${response.statusCode}');
      print('DEBUG: addVancy body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('The catch message: $e');
    }

    return null;
  }

  // Get company vacancies
  Future<List<AddVancyModel>> getMyVacancies(String? token) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/job-offers',
        ), // Assuming this endpoint exists, or fallback to /job-offers
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: getMyVacancies status: ${response.statusCode}');
      print('DEBUG: getMyVacancies body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        
        if (decodedBody is List) {
          return decodedBody.map((e) => AddVancyModel.fromJson(e)).toList();
        } else if (decodedBody is Map<String, dynamic>) {
          // Check for common keys like 'data', 'offers', 'results'
          final List<dynamic>? list = decodedBody['data'] ?? 
                                     decodedBody['offers'] ?? 
                                     decodedBody['results'] ??
                                     decodedBody['vancies']; // Based on developer naming patterns observed
          
          if (list != null) {
            return list.map((e) => AddVancyModel.fromJson(e)).toList();
          }
        }
      }
    } catch (e) {
      print('Error fetching vacancies: $e');
    }
    return [];
  }
}
