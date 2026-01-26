// lib/services/api_service.dart
import 'dart:io';
import 'dart:convert';

import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/models/candidate_model.dart';
import 'package:demarcheur_app/models/donneur/donneur_model.dart';
import 'package:demarcheur_app/models/enterprise/enterprise_model.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/models/services/service_model.dart';
import 'package:demarcheur_app/models/type_properties.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final String baseUrl = Config.baseUrl;
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>?;
          if (data != null) {
            SharedPreferences pref = await SharedPreferences.getInstance();
            if (data['userId'] != null) {
              await pref.setString('userId', data['userId'].toString());
            }
            if (data['token'] != null) {
              await pref.setString('token', data['token'].toString());
            }
            // initializeChatPlugin(data['userId'], data['token']); // Removed
          }
          return data;
        } catch (jsonError) {
          print('JSON decode error in donneurRegistration: $jsonError');
          print('Response body: ${response.body}');
          return null;
        }
      } else {
        print('Registration failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('DonneurRegistration error: $e');
      return null;
    }
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
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>?;
          if (data != null) {
            SharedPreferences pref = await SharedPreferences.getInstance();
            if (data['userId'] != null) {
              await pref.setString('userId', data['userId'].toString());
            }
            if (data['token'] != null) {
              await pref.setString('token', data['token'].toString());
            }
            // initializeChatPlugin(data['userId'], data['token']); // Removed
          }
          return data;
        } catch (jsonError) {
          print('JSON decode error in registerGiver: $jsonError');
          print('Response body: ${response.body}');
          return null;
        }
      } else {
        print('Registration failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('RegisterGiver error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> setLogin(String item, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'item': item, 'password': password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data != null && data is Map<String, dynamic>) {
          // Defensive extraction
          String? userIdString = data['userId']?.toString();
          // Fallback to nested user object if top-level ID is missing
          if (userIdString == null && data['user'] is Map) {
            userIdString =
                data['user']['id']?.toString() ??
                data['user']['_id']?.toString();
          }

          final tokenString = data['token']?.toString();

          if (userIdString != null && tokenString != null) {
            SharedPreferences pref = await SharedPreferences.getInstance();
            await pref.setString('userId', userIdString);
            await pref.setString('token', tokenString);
            // initializeChatPlugin(userIdString, tokenString); // Removed
          } else {
            print(
              'DEBUG: setLogin - Missing userId or token in response: data=$data',
            );
          }
        }
        return data; // Return data even if we couldn't cache it, or let the caller decide
      } else {
        print('Authentification failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
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

    if (token == null || token.isEmpty) {
      print('Giver Profile failed: No token provided');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile-giver'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    try {
      if (response.statusCode == 200) {
        print('DEBUG: Profile RAW: ${response.body}');
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body['data'] != null) {
            return EnterpriseModel.fromJson(body['data']);
          } else if (body['user'] != null) {
            return EnterpriseModel.fromJson(body['user']);
          }
          return EnterpriseModel.fromJson(body);
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print(
          'Giver Profile failed: ${response.statusCode} - Authentication error',
        );
        print('Response: ${response.body}');
        // Token is invalid, return null to trigger re-authentication
        return null;
      } else {
        print('Giver Profile failed: ${response.statusCode}');
        print('DEBUG: Giver Profile Raw Response: ${response.body}');
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
        print('DEBUG: Searcher Profile Raw Response: ${response.body}');
      }
    } catch (e) {
      print('Error parsing searcher profile: $e');
    }
    return null;
  }

  // Get user profile by userId
  Future<DonneurModel?> getUserProfile(String userId, String? token) async {
    // Known endpoints in this project's backend structure
    final endpoints = [
      '$baseUrl/auth/searcher/$userId', // Most likely based on auth provider
      '$baseUrl/users/$userId',
    ];

    for (final url in endpoints) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) {
            if (body['data'] != null) {
              return DonneurModel.fromJson(body['data']);
            } else if (body['user'] != null) {
              return DonneurModel.fromJson(body['user']);
            }
            return DonneurModel.fromJson(body);
          }
        }
      } catch (e) {
        print('ApiService.getUserProfile error for $url: $e');
      }
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
          final List<dynamic>? list =
              decodedBody['data'] ??
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

  Future<Map<String, dynamic>?> addCandidate(
    CandidateModel candidate,
    String? token,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/candidatures'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['JobId'] = candidate.jobId;
      request.fields['appliquantId'] = candidate.appliquantId;

      print("DEBUG: Multipart Request Fields: ${request.fields}");

      if (candidate.document != null) {
        final file = candidate.document!;
        final mimeType = lookupMimeType(file.path);

        // Default to application/pdf if mimeType lookup fails, or handle error
        final contentType = mimeType != null
            ? MediaType.parse(mimeType)
            : MediaType('application', 'pdf');

        request.files.add(
          await http.MultipartFile.fromPath(
            'document', // Changed from 'cv' to 'document' based on error
            file.path,
            contentType: contentType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('AddCandidate failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('An exception occurred at $e');
    }
    return null;
  }

  Future<List<CandidateModel>> getJobApplicants(
    String jobId,
    String? token, {
    int page = 1,
    int limit = 10,
  }) async {
    print("DEBUG: ApiService.getJobApplicants ENTERED - jobId: $jobId");
    try {
      final url = '$baseUrl/candidatures/job/$jobId';
      print("DEBUG: ApiService - Fetching applicants from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("DEBUG: ApiService - Response status: ${response.statusCode}");
      print("DEBUG: ApiService - Response body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data = [];

        if (decoded is List) {
          data = decoded;
          print(
            "DEBUG: ApiService - Response is a List with ${data.length} items",
          );
        } else if (decoded is Map<String, dynamic>) {
          data =
              decoded['data'] ??
              decoded['candidatures'] ??
              decoded['results'] ??
              [];
          print(
            "DEBUG: ApiService - Response is a Map, extracted ${data.length} items from 'data' key",
          );
        }

        final candidates = data.map((json) {
          print("DEBUG: ApiService - Parsing candidate JSON: $json");
          return CandidateModel.fromJson(json);
        }).toList();
        print(
          "DEBUG: ApiService - Parsed ${candidates.length} CandidateModel objects",
        );
        return candidates;
      } else {
        print("DEBUG: ApiService - Error response: ${response.body}");
      }
    } catch (e) {
      print('ApiService.getJobApplicants error: $e');
    }
    return [];
  }

  Future<List<CandidateModel>> getEnterpriseCandidates(
    String enterpriseId,
    String? token,
  ) async {
    try {
      print("DEBUG: ApiService - Fetching jobs for enterprise: $enterpriseId");

      // First, get all jobs for this enterprise
      final allJobs = await getMyVacancies(token);

      // Filter to only jobs that belong to this specific enterprise
      final jobs = allJobs
          .where((job) => job.companyId == enterpriseId)
          .toList();

      if (jobs.isEmpty) {
        print(
          "DEBUG: ApiService - No jobs found for this enterprise (ID: $enterpriseId)",
        );
        return [];
      }

      print(
        "DEBUG: ApiService - Found ${jobs.length} jobs for enterprise $enterpriseId (filtered from ${allJobs.length} total jobs)",
      );

      // Then, fetch candidates for each job
      List<CandidateModel> allCandidates = [];

      for (var job in jobs) {
        if (job.id != null && job.id!.isNotEmpty) {
          print(
            "DEBUG: ApiService - Fetching candidates for job: ${job.id} (${job.title})",
          );
          final jobCandidates = await getJobApplicants(job.id!, token);
          print(
            "DEBUG: ApiService - Job ${job.id} returned ${jobCandidates.length} candidates",
          );
          allCandidates.addAll(jobCandidates);
          print(
            "DEBUG: ApiService - Total candidates so far: ${allCandidates.length}",
          );
        }
      }

      print(
        "DEBUG: ApiService - Total candidates found: ${allCandidates.length}",
      );
      return allCandidates;
    } catch (e) {
      print('ApiService.getEnterpriseCandidates error: $e');
    }
    return [];
  }

  Future<List<CandidateModel>> getJobApplicantById(
    String jobId,
    String? token,
  ) async {
    try {
      final url = '$baseUrl/candidatures/$jobId';
      print("DEBUG: ApiService - Fetching applicants from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("DEBUG: ApiService - Response status: ${response.statusCode}");
      print("DEBUG: ApiService - Response body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> data = [];

        if (decoded is List) {
          data = decoded;
          print(
            "DEBUG: ApiService - Response is a List with ${data.length} items",
          );
        } else if (decoded is Map<String, dynamic>) {
          data =
              decoded['data'] ??
              decoded['candidatures'] ??
              decoded['results'] ??
              [];
          print(
            "DEBUG: ApiService - Response is a Map, extracted ${data.length} items from 'data' key",
          );
        }

        final candidates = data.map((json) {
          print("DEBUG: ApiService - Parsing candidate JSON: $json");
          return CandidateModel.fromJson(json);
        }).toList();
        print(
          "DEBUG: ApiService - Parsed ${candidates.length} CandidateModel objects",
        );
        return candidates;
      } else {
        print("DEBUG: ApiService - Error response: ${response.body}");
      }
    } catch (e) {
      print('ApiService.getJobApplicants error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> updateStatus(
    String candidatureId,
    String newStatus,
    String token,
  ) async {
    print('START CALLING THE UPDATE');

    final response = await http.patch(
      Uri.parse('$baseUrl/candidatures/$candidatureId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      print('Updated successfully the new status is: $newStatus');

      return jsonDecode(response.body);
    } else {
      print('Update failed: ${response.body}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserApplications(
    String? token, {
    String? userId,
  }) async {
    if (userId == null) return [];

    try {
      final url = '$baseUrl/candidatures/$userId';
      print("DEBUG: ApiService - Fetching applications from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("DEBUG: Status: ${response.statusCode} for $url");

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> list = [];

        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list =
              decoded['data'] ??
              decoded['candidatures'] ??
              decoded['results'] ??
              [];
        }

        print("DEBUG: ApiService - Found ${list.length} applications");
        return List<Map<String, dynamic>>.from(list);
      } else {
        print("DEBUG: ApiService - Failed with status ${response.statusCode}");
        print("DEBUG: Response body: ${response.body}");
      }
    } catch (e) {
      print('ApiService.getUserApplications error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getJobById(String jobId, String? token) async {
    try {
      final url = '$baseUrl/job-offers/$jobId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? decoded['job'] ?? decoded;
      }
    } catch (e) {
      print('ApiService.getJobById error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> addProperties(
    HouseModel property,
    List<File> images,
    String? token,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/properties'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add text fields
      final fields = property.toJson();
      fields.forEach((key, value) {
        if (value != null && key != 'imageUrl') {
          if (value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      print("DEBUG: addProperties fields being sent: ${request.fields}");

      // Add images
      for (var file in images) {
        final mimeType = lookupMimeType(file.path);
        final contentType = mimeType != null
            ? MediaType.parse(mimeType)
            : MediaType('image', 'jpeg');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Changed from 'images' to match other endpoints like donneurRegistration
            file.path,
            contentType: contentType,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Add Property status: ${response.statusCode}');
      print('Add Property body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error adding property: $e');
    }

    return null;
  }

  Future<List<TypeProperties>> typeProperties(String? token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/type-properties'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      // ignore: avoid_print
      print('DEBUG: types status: ${response.statusCode}');
      // ignore: avoid_print
      print('DEBUG: types body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> body = [];
        if (decoded is List) {
          body = decoded;
        } else if (decoded is Map<String, dynamic>) {
          body =
              decoded['data'] ?? decoded['types'] ?? decoded['results'] ?? [];
        }
        return body.map((e) => TypeProperties.fromJson(e)).toList();
      } else {
        // If API fails, return hardcoded list for now
        print('DEBUG: API failed, returning hardcoded property types');
        return [
          TypeProperties(
            id: '1',
            tyPePropertyName: 'Appartement',
            typeEnum: 'RESIDENCY',
          ),
          TypeProperties(
            id: '2',
            tyPePropertyName: 'Maison',
            typeEnum: 'RESIDENCY',
          ),
          TypeProperties(
            id: '3',
            tyPePropertyName: 'Villa',
            typeEnum: 'RESIDENCY',
          ),
          TypeProperties(
            id: '4',
            tyPePropertyName: 'Studio',
            typeEnum: 'RESIDENCY',
          ),
          TypeProperties(
            id: '5',
            tyPePropertyName: 'Duplex',
            typeEnum: 'RESIDENCY',
          ),
          TypeProperties(
            id: '6',
            tyPePropertyName: 'Penthouse',
            typeEnum: 'RESIDENCY',
          ),
          TypeProperties(
            id: '7',
            tyPePropertyName: 'Loft',
            typeEnum: 'RESIDENCY',
          ),
          TypeProperties(
            id: '8',
            tyPePropertyName: 'Terrain',
            typeEnum: 'LAND',
          ),
          TypeProperties(
            id: '9',
            tyPePropertyName: 'Local commercial',
            typeEnum: 'COMMERCIAL',
          ),
          TypeProperties(
            id: '10',
            tyPePropertyName: 'Bureau',
            typeEnum: 'COMMERCIAL',
          ),
        ];
      }
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: types exception: $e');
    }
    return [];
  }
  // Future<Map<String, dynamic>?> giverProfile(String? token) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/auth/profile-giver'),
  //       headers: {
  //         'Authorization':' Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     // ignore: avoid_print
  //     print('DEBUG: giverProfile status: ${response.statusCode}');
  //     // ignore: avoid_print
  //     print('DEBUG: giverProfile body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     }
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print('DEBUG: giverProfile exception: $e');
  //   }
  //   return null;

  Future<List<HouseModel>> getProperties(
    String? token, {
    String? companyId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/properties'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      // ignore: avoid_print
      print('DEBUG: getProperties status: ${response.statusCode}');
      // ignore: avoid_print
      print('DEBUG: getProperties body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> body = [];
        if (decoded is List) {
          body = decoded;
        } else if (decoded is Map<String, dynamic>) {
          body =
              decoded['data'] ??
              decoded['properties'] ??
              decoded['results'] ??
              [];
        }
        List<HouseModel> all = body.map((e) => HouseModel.fromJson(e)).toList();

        if (companyId != null) {
          return all
              .where((h) => h.companyId == companyId || h.ownerId == companyId)
              .toList();
        }
        return all;
      }
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: getProperties exception: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> sendMessage(
    SendMessageModel chat,
    String? token,
  ) async {
    try {
      final url = '$baseUrl/chats';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      print('DEBUG: sendMessage - URL: $url');
      print(
        'DEBUG: sendMessage - Token present: ${token != null && token.isNotEmpty}',
      );
      if (token != null && token.length > 20) {
        print(
          'DEBUG: sendMessage - Token snippet: ${token.substring(0, 20)}...',
        );
      }

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      Map<String, dynamic> fields = chat.toJson();
      fields.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (chat.image != null) {
        final file = chat.image!;
        final mimeType = lookupMimeType(file.path);
        final contentType = mimeType != null
            ? MediaType.parse(mimeType)
            : MediaType('image', 'jpeg');

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            contentType: contentType,
          ),
        );
      }

      // 4. Send the request
      print('Sending request to: $url');
      var streamedResponse = await request.send();
      // 5. Read the response
      var response = await http.Response.fromStream(streamedResponse);

      // 6. Handle the status code
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response (e.g., 200, 201)
        print('DEBUG: sendMessage SUCCESS - Status: ${response.statusCode}');
        print('DEBUG: sendMessage body: ${response.body}');
        return jsonDecode(response.body);
      } else {
        // Error response (e.g., 400, 500)
        print('Failed to send message Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during message sending: $e');
      return null;
    }
  }

  // Future<List<SendMessageModel>> fetchMessagesBetweenUsers(
  //   String userId,
  //   String otherUserId,
  //   String? token, {
  //   int page = 1,
  //   int limit = 30,
  // }) async {
  //   try {
  //     final List<String> urlVariations = [
  //       '$baseUrl/chats?id=$userId',
  //       '$baseUrl/chats?id=$userId&otherId=$otherUserId',
  //       '$baseUrl/chats?userId=$userId&otherUserId=$otherUserId',
  //       '$baseUrl/chats?senderId=$userId&receiverId=$otherUserId',
  //       '$baseUrl/chats?user_id=$userId&other_user_id=$otherUserId',
  //       '$baseUrl/chats?receiverId=$userId&senderId=$otherUserId',
  //       '$baseUrl/chats?sender=$userId&receiver=$otherUserId',
  //       '$baseUrl/chats?receiver=$userId&sender=$otherUserId',
  //       '$baseUrl/chats?userId=me&otherUserId=$otherUserId',
  //       '$baseUrl/chats/$otherUserId',
  //       '$baseUrl/chats/$userId/$otherUserId',
  //       '$baseUrl/chats/user/$otherUserId',
  //       '$baseUrl/chats/messages/$otherUserId',
  //     ];

  //     List<dynamic> data = [];

  //     final List<String> authHeaders = [];
  //     if (token != null && token.isNotEmpty) {
  //       final cleanToken =
  //           token.startsWith('Bearer ') || token.startsWith('BEARER ')
  //           ? token.substring(token.indexOf(' ') + 1)
  //           : token;
  //       authHeaders.add('Bearer $cleanToken');
  //     }

  //     for (var variantUrl in urlVariations) {
  //       for (var currentAuth in (authHeaders.isNotEmpty ? authHeaders : [''])) {
  //         try {
  //           print(
  //             'DEBUG: fetchMessagesBetweenUsers - Attempting: $variantUrl${currentAuth.isNotEmpty ? " with $currentAuth" : ""}',
  //           );
  //           final response = await http.get(
  //             Uri.parse(variantUrl),
  //             headers: {
  //               if (currentAuth.isNotEmpty) 'Authorization': currentAuth,
  //               'Accept': 'application/json',
  //             },
  //           );

  //           if (response.statusCode == 200) {
  //             final decoded = jsonDecode(response.body);
  //             if (decoded is List) {
  //               print(
  //                 'DEBUG: fetchMessagesBetweenUsers - SUCCESS (List) with $variantUrl',
  //               );
  //               data = decoded;
  //             } else if (decoded is Map) {
  //               final List<dynamic> currentData =
  //                   decoded['data'] ??
  //                   decoded['messages'] ??
  //                   decoded['results'] ??
  //                   decoded['items'] ??
  //                   [];
  //               if (currentData.isNotEmpty) {
  //                 print(
  //                   'DEBUG: fetchMessagesBetweenUsers - SUCCESS (Map) with $variantUrl',
  //                 );
  //                 data = currentData;
  //               }
  //             }

  //             if (data.isNotEmpty) break;
  //           } else {
  //             print(
  //               'DEBUG: fetchMessagesBetweenUsers - Status: ${response.statusCode} for $variantUrl',
  //             );
  //           }
  //         } catch (e) {
  //           print(
  //             'DEBUG: fetchMessagesBetweenUsers - Error for $variantUrl: $e',
  //           );
  //         }
  //       }
  //       if (data.isNotEmpty) break;
  //     }

  //     if (data.isEmpty) {
  //       print(
  //         'DEBUG: fetchMessagesBetweenUsers - All variations returned empty. This might mean the user has no messages or the query is wrong.',
  //       );
  //     }

  //     // Client-side filtering as fallback if backend doesn't filter
  //     final messages = data.map((e) => SendMessageModel.fromJson(e)).toList();
  //     return messages.where((msg) {
  //       return (msg.senderId == userId && msg.receiverId == otherUserId) ||
  //           (msg.senderId == otherUserId && msg.receiverId == userId);
  //     }).toList();
  //   } catch (e) {
  //     print('Error fetching messages: $e');
  //   }
  //   return [];
  // }

  //retrieve messages by id
  Future<Map<String, dynamic>?> fetchMessagesById(
    String conversationId,
    String? token,
  ) async {
    try {
      final url = '$baseUrl/chats/$conversationId';

      print('DEBUG: fetchMessagesById - URL: $url');
      print(
        'DEBUG: fetchMessagesById - Token present: ${token != null && token.isNotEmpty}',
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? decoded['messages'] ?? decoded;
      } else {
        print('Failed to fetch messages: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
    return null;
  }

  // Future<List<dynamic>> fetchConversations(
  //   String? token, {
  //   String? userId,
  //   String? otherId,
  // }) async {
  //   try {
  //     print('DEBUG: fetchConversations - userId passed: $userId');
  //     print('DEBUG: fetchConversations - token present: ${token != null}');

  //     // Diagnostic: Check what the backend thinks our profile is
  //     String? giverId;
  //     String? searcherId;
  //     try {
  //       final giver = await giverProfile(token);
  //       if (giver != null) {
  //         giverId = giver.id;
  //         print('DEBUG: fetchConversations - GIVER Profile ID: $giverId');
  //       }
  //       final searcher = await searcherProfile(token);
  //       if (searcher != null) {
  //         searcherId = searcher.id;
  //         print('DEBUG: fetchConversations - SEARCHER Profile ID: $searcherId');
  //       }
  //     } catch (e) {
  //       print('DEBUG: fetchConversations - Profile check failed: $e');
  //     }

  //     final List<String> allUserIds = {
  //       if (userId != null && userId.isNotEmpty) userId,
  //       if (giverId != null && giverId.isNotEmpty) giverId,
  //       if (searcherId != null && searcherId.isNotEmpty) searcherId,
  //     }.toList();

  //     print('DEBUG: fetchConversations - IDs to probe: $allUserIds');

  //     final List<String> urlVariations = [];

  //     // PRIORITY 1: Plain /chats (standard)
  //     urlVariations.add('$baseUrl/chats');

  //     // PRIORITY 2: User specific variations
  //     for (var uId in allUserIds) {
  //       urlVariations.addAll([
  //         '$baseUrl/chats?userId=$uId',
  //         '$baseUrl/chats?id=$uId',
  //         '$baseUrl/chats/user/$uId',
  //         '$baseUrl/chats?user_id=$uId',
  //         '$baseUrl/chats?senderId=$uId',
  //         '$baseUrl/chats?receiverId=$uId',
  //       ]);
  //     }

  //     // PRIORITY 3: Role and Alias variations
  //     urlVariations.addAll([
  //       '$baseUrl/chats?userId=me',
  //       '$baseUrl/chats/me',
  //       '$baseUrl/chats/conversations',
  //       '$baseUrl/chats/searcher',
  //       '$baseUrl/chats/giver',
  //       '$baseUrl/messages',
  //     ]);

  //     List<dynamic> messages = [];

  //     final List<String> authHeaders = [];
  //     if (token != null && token.isNotEmpty) {
  //       final cleanToken =
  //           token.startsWith('Bearer ') || token.startsWith('BEARER ')
  //           ? token.substring(token.indexOf(' ') + 1)
  //           : token;

  //       authHeaders.add('Bearer $cleanToken');

  //       if (token.length > 20) {
  //         print(
  //           'DEBUG: fetchConversations - Token snippet: ${cleanToken.substring(0, 20)}...',
  //         );
  //       }
  //     }

  //     for (var variantUrl in urlVariations) {
  //       for (var currentAuth in (authHeaders.isNotEmpty ? authHeaders : [''])) {
  //         try {
  //           print(
  //             'DEBUG: fetchConversations - Attempting: $variantUrl${currentAuth.isNotEmpty ? " with $currentAuth" : ""}',
  //           );
  //           final response = await http.get(
  //             Uri.parse(variantUrl),
  //             headers: {
  //               if (currentAuth.isNotEmpty) 'Authorization': currentAuth,
  //               'Accept': 'application/json',
  //             },
  //           );

  //           if (response.statusCode == 200) {
  //             final decoded = jsonDecode(response.body);
  //             if (decoded is Map && decoded.containsKey('total')) {
  //               print(
  //                 'DEBUG: fetchConversations - Found ${decoded['total']} items for $variantUrl',
  //               );
  //             }

  //             final List<dynamic> currentData = decoded is List
  //                 ? decoded
  //                 : (decoded['data'] ??
  //                       decoded['messages'] ??
  //                       decoded['conversations'] ??
  //                       decoded['results'] ??
  //                       decoded['items'] ??
  //                       []);

  //             if (currentData.isNotEmpty) {
  //               print('DEBUG: fetchConversations - SUCCESS with $variantUrl');

  //               final first = currentData.first;
  //               final isAlreadyConversation =
  //                   first is Map &&
  //                   (first.containsKey('receiverId') ||
  //                       first.containsKey('otherUser') ||
  //                       first.containsKey('participants'));

  //               if (isAlreadyConversation) {
  //                 print(
  //                   'DEBUG: fetchConversations - Data detected as PRE-GROUPED CONVERSATIONS',
  //                 );
  //                 return currentData;
  //               }

  //               messages = currentData;
  //               break; // Break from inner loop (auth headers)
  //             } else {
  //               print(
  //                 'DEBUG: fetchConversations - Body was empty or zero items: ${response.body}',
  //               );
  //             }
  //           } else {
  //             print(
  //               'DEBUG: fetchConversations - Status Code: ${response.statusCode} for $variantUrl',
  //             );
  //             if (response.statusCode != 404) {
  //               print('DEBUG: fetchConversations - Response: ${response.body}');
  //             }
  //           }
  //         } catch (e) {
  //           print(
  //             'DEBUG: fetchConversations - Probe Error for $variantUrl: $e',
  //           );
  //         }
  //       }
  //       if (messages.isNotEmpty) break;
  //     }

  //     if (messages.isNotEmpty) {
  //       print(
  //         'DEBUG: fetchConversations - Final selection has ${messages.length} messages',
  //       );
  //       print(
  //         'DEBUG: fetchConversations - First message sample: ${messages.first}',
  //       );
  //     }

  //     // Group messages by conversation (unique sender/receiver pairs)
  //     final Map<String, dynamic> conversationsMap = {};

  //     for (var message in messages) {
  //       final senderId =
  //           (message['senderId'] ??
  //                   message['sender_id'] ??
  //                   message['sender']?['id'] ??
  //                   message['sender']?['_id'])
  //               ?.toString();

  //       final receiverId =
  //           (message['receiverId'] ??
  //                   message['receiver_id'] ??
  //                   message['receiver']?['id'] ??
  //                   message['receiver']?['_id'])
  //               ?.toString();

  //       if (senderId == null || receiverId == null) {
  //         print('DEBUG: fetchConversations - Skipping message: missing IDs');
  //         continue;
  //       }

  //       // Only include messages where the current user is involved
  //       if (allUserIds.isNotEmpty &&
  //           !allUserIds.contains(senderId) &&
  //           !allUserIds.contains(receiverId)) {
  //         continue;
  //       }

  //       // Determine who the "other" person in the conversation is
  //       final isSenderMe = allUserIds.contains(senderId);
  //       final otherUserId = isSenderMe ? receiverId : senderId;

  //       String otherName = 'Utilisateur';
  //       String? otherImage;

  //       if (senderId == otherUserId) {
  //         otherName =
  //             message['senderName'] ??
  //             message['sender']?['name'] ??
  //             'Utilisateur';
  //         otherImage = message['senderImage'] ?? message['sender']?['image'];
  //       } else {
  //         otherName =
  //             message['receiverName'] ??
  //             message['receiver']?['name'] ??
  //             'Utilisateur';
  //         otherImage =
  //             message['receiverImage'] ?? message['receiver']?['image'];
  //       }

  //       // Create a unique key for this conversation (sorted to ensure consistency)
  //       final participants = [senderId, receiverId]..sort();
  //       final conversationKey = participants.join('_');

  //       if (!conversationsMap.containsKey(conversationKey)) {
  //         conversationsMap[conversationKey] = {
  //           'receiverId': otherUserId,
  //           'receiverName': otherName,
  //           'receiverImage': otherImage,
  //           'lastMessage': message,
  //           'unreadCount':
  //               (message['isRead'] == false || message['read'] == false)
  //               ? 1
  //               : 0,
  //         };
  //       } else {
  //         // Update if this message is newer
  //         final existing = conversationsMap[conversationKey];
  //         final existingTime = existing['lastMessage']?['createdAt'];
  //         final newTime = message['createdAt'];

  //         if (newTime != null &&
  //             (existingTime == null ||
  //                 DateTime.parse(
  //                   newTime,
  //                 ).isAfter(DateTime.parse(existingTime)))) {
  //           conversationsMap[conversationKey]!['lastMessage'] = message;
  //         }
  //       }
  //     }

  //     return conversationsMap.values.toList();
  //   } catch (e) {
  //     print('Error fetching conversations: $e');
  //   }
  //   return [];
  // }

  // Future<String?> getToken() async {
  //   return await storage.read(key: 'token');
  // }

  // Future<void> logout() async {
  //   await storage.delete(key: 'token');
  // }

  Future<List<dynamic>> fetchConversations(
    String? token, {
    String? userId,
  }) async {
    try {
      final String baseWithoutV1 = baseUrl.replaceAll('/v1', '');
      final List<String> urlVariations = [
        // Primary variations (v1)
        if (userId != null) '$baseUrl/chats/$userId',
        '$baseUrl/chats',
        if (userId != null) '$baseUrl/chats?id=$userId',
        if (userId != null) '$baseUrl/chats?user_id=$userId',
        if (userId != null) '$baseUrl/chats?senderId=$userId',
        if (userId != null) '$baseUrl/chats?receiverId=$userId',
        if (userId != null) '$baseUrl/chats?receiver_id=$userId',

        // Root Variations (likely for some backends)
        '$baseWithoutV1/chats',
        if (userId != null) '$baseWithoutV1/chats?userId=$userId',

        // Endpoint Variations
        '$baseUrl/messages',
        if (userId != null) '$baseUrl/chats/$userId',
        '$baseUrl/conversations',
        if (userId != null) '$baseUrl/conversations?userId=$userId',

        // Identity Variations
        '$baseUrl/chats/me',
        '$baseUrl/chats?userId=me',
      ];

      for (var variantUrl in urlVariations) {
        print('DEBUG: ApiService.fetchConversations - Attempting: $variantUrl');
        final response = await http.get(
          Uri.parse(variantUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print(
          'DEBUG: ApiService.fetchConversations - Status: ${response.statusCode}',
        );
        if (response.statusCode == 200) {
          print(
            'DEBUG: ApiService.fetchConversations Body: ${response.body.length > 300 ? response.body.substring(0, 300) : response.body}',
          );
        }

        if (response.statusCode == 200) {
          final dynamic decoded = jsonDecode(response.body);

          // Flexible extraction: Look for any List if typical keys are missing
          List<dynamic> currentData = [];
          if (decoded is List) {
            currentData = decoded;
          } else if (decoded is Map<String, dynamic>) {
            currentData =
                decoded['data'] ??
                decoded['conversations'] ??
                decoded['results'] ??
                decoded['chats'] ??
                decoded['messages'] ??
                decoded['items'] ??
                [];

            // If still empty but map has other lists, pick the first one
            if (currentData.isEmpty) {
              for (var val in decoded.values) {
                if (val is List && val.isNotEmpty) {
                  currentData = val;
                  break;
                }
              }
            }
          }

          if (currentData.isNotEmpty) {
            print(
              'DEBUG: ApiService.fetchConversations - SUCCESS with $variantUrl (${currentData.length} items)',
            );
            return currentData;
          }
        }
      }
    } catch (e) {
      print('ApiService.fetchConversations error: $e');
    }
    return [];
  }

  // Fetch messages between two users

  Future<List<SendMessageModel>> fetchMessagesBetweenUsers(
    String userId,
    String otherUserId,
    String? token, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final List<String> urlVariations = [
        '$baseUrl/chats?userId=$userId&otherUserId=$otherUserId&page=$page&limit=$limit',
        '$baseUrl/chats?senderId=$userId&receiverId=$otherUserId',
        '$baseUrl/chats?senderId=$otherUserId&receiverId=$userId',
        '$baseUrl/chats?userId=$userId&otherId=$otherUserId',
        '$baseUrl/chats',
      ];

      for (var variantUrl in urlVariations) {
        print(
          'DEBUG: ApiService.fetchMessagesBetweenUsers - Attempting: $variantUrl',
        );
        final response = await http.get(
          Uri.parse(variantUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print(
          'DEBUG: ApiService.fetchMessagesBetweenUsers - Status: ${response.statusCode}',
        );

        if (response.statusCode == 200) {
          final dynamic decoded = jsonDecode(response.body);
          List<dynamic> messagesList =
              (decoded is Map
                  ? (decoded['data'] ?? decoded['messages'])
                  : (decoded is List ? decoded : [])) ??
              [];

          if (messagesList.isNotEmpty) {
            print(
              'DEBUG: ApiService.fetchMessagesBetweenUsers - SUCCESS with $variantUrl (${messagesList.length} items)',
            );
            return messagesList
                .map((msg) => SendMessageModel.fromJson(msg))
                .toList();
          }
        }
      }
    } catch (e) {
      print('ApiService.fetchMessagesBetweenUsers error: $e');
    }
    return [];
  }

  Future<void> initializeChatPlugin(String userId, String token) async {
    // Commented out - chat_plugin package has bugs
    // try {
    //   if (ChatConfig.instance.userId == userId) {
    //     ChatPlugin.chatService.refreshGlobalConnection();
    //     return;
    //   }
    //   ChatPlugin.initialize(
    //     config: ChatConfig(
    //       apiUrl: Config.baseUrl,
    //       userId: userId,
    //       token: token,
    //       enableOnlineStatus: true,
    //       maxReconnectionAttempts: 5,
    //       enableReadReceipts: true,
    //       enableTypingIndicators: true,
    //       autoMarkAsRead: true,
    //       debugMode: true,
    //     ),
    //   );
    // } catch (e) {
    //   print(e);
    // }
    print('ChatPlugin disabled - using direct API calls instead');
  }

  Future<void> setupChatApiHandler(String userId, String token) async {
    // Commented out - chat_plugin package has bugs
    //   final handlers = ChatApiHandlers(
    //     loadMessagesHandler: ({limit = 30, page = 1, searchText = ''}) async {
    //       final receiverId = ChatPlugin.chatService.receiverId;
    //       if (receiverId.isEmpty) {
    //         return [];
    //       }
    //       try {
    //         var url =
    //             '${Config.baseUrl}/chat/userId=$userId&otherUserId=$receiverId&page=$page&limit=$limit';
    //         if (searchText.isNotEmpty) {
    //           url += '&searchText=${Uri.decodeComponent(searchText)}';
    //         }
    //         final response = await http.get(
    //           Uri.parse(url),
    //           headers: {
    //             'Authorization': 'Bearer$token',
    //             'Content-Type': 'application/json',
    //           },
    //         );
    //         if (response.statusCode == 200) {
    //           final List<dynamic> data = jsonDecode(response.body);
    //           return data.map((msg) => ChatMessage.fromMap(msg, userId)).toList();
    //         } else {
    //           return [];
    //         }
    //       } catch (e) {
    //         return [];
    //       }
    //     },
    //     loadChatRoomsHandler: () async {
    //       try {
    //         var url = '${Config.baseUrl}/chat';

    //         final response = await http.get(
    //           Uri.parse(url),
    //           headers: {
    //             'Authorization': 'Bearer$token',
    //             'Content-Type': 'application/json',
    //           },
    //         );
    //         if (response.statusCode == 200) {
    //           final List<dynamic> data = jsonDecode(response.body);
    //           return data.map((room) => ChatRoom.fromMap(room)).toList();
    //         } else {
    //           return [];
    //         }
    //       } catch (e) {
    //         return [];
    //       }
    //     },
    //   );
    //   ChatPlugin.chatService.setApiHandlers(handlers);
    //   print('ChatPlugin API handlers disabled - using direct API calls instead');
  }
}
