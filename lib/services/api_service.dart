// lib/services/api_service.dart
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/models/candidate_model.dart';
import 'package:demarcheur_app/models/donneur/donneur_model.dart';
import 'package:demarcheur_app/models/enterprise/enterprise_model.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/models/services/service_model.dart';
import 'package:demarcheur_app/models/type_properties.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:demarcheur_app/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  final StorageService _storage = StorageService();
  final String baseUrl = Config.baseUrl;
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _getAuthHeaders([String? token]) async {
    final headers = _headers;
    final authToken = token ?? await _storage.getToken();
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

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
          }
          return data;
        } catch (jsonError) {
          print('JSON decode error in donneurRegistration: $jsonError');
          return null;
        }
      } else {
        print('Registration failed: ${response.statusCode}');
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
        try {
          return jsonDecode(response.body) as Map<String, dynamic>?;
        } catch (jsonError) {
          return null;
        }
      }
    } catch (e) {
      print('ServiceRegister error: $e');
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
          }
          return data;
        } catch (jsonError) {
          return null;
        }
      } else {
        print('Registration failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
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
          print('DEBUG: setLogin response keys: ${data.keys.toList()}');
          print('DEBUG: setLogin token: ${data['token'] != null}');
          print('DEBUG: setLogin refreshToken: ${data['refreshToken']}');
          print('DEBUG: setLogin refresh_token: ${data['refresh_token']}');

          // Defensive extraction
          String? userIdString = data['userId']?.toString();
          // Fallback to nested user object if top-level ID is missing
          if (userIdString == null && data['user'] is Map) {
            userIdString =
                data['user']['id']?.toString() ??
                data['user']['_id']?.toString();
          }

          final tokenString = data['token']?.toString();
          // Extract refresh token from likely keys
          final refreshTokenString =
              data['refreshToken']?.toString() ??
              data['refresh_token']?.toString();

          if (userIdString != null && tokenString != null) {
            SharedPreferences pref = await SharedPreferences.getInstance();
            await pref.setString('userId', userIdString);
            await pref.setString('token', tokenString);

            // Save refresh token if available
            if (refreshTokenString != null) {
              await pref.setString('refreshToken', refreshTokenString);
              await StorageService().saveRefreshToken(refreshTokenString);
            }
          } else {
            print(
              'DEBUG: setLogin - Missing userId or token in response: data=$data',
            );
          }
        }
        return data;
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
    final response = await http.get(
      Uri.parse('$baseUrl/services'),
      headers: {'Content-Type': 'application/json'},
    );
    try {
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => ServiceModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('An exception occurred $e');
    }
    return [];
  }

  Future<EnterpriseModel?> giverProfile(String? token) async {
    if (token == null || token.isEmpty) {
      return null;
    }

    final headers = await _getAuthHeaders(token);
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile-giver'),
      headers: headers,
    );
    try {
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print('DEBUG: giverProfile - Raw Response Body: $body');
        if (body is Map<String, dynamic>) {
          if (body['data'] != null) {
            return EnterpriseModel.fromJson(body['data']);
          } else if (body['user'] != null) {
            return EnterpriseModel.fromJson(body['user']);
          }
          return EnterpriseModel.fromJson(body);
        }
      }
    } catch (e) {
      print('Error parsing giver profile: $e');
    }
    return null;
  }

  // Refresh token method
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();

      print('DEBUG: refreshToken - Found in storage: ${refreshToken != null}');
      if (refreshToken == null) {
        print('DEBUG: refreshToken - Aborting, no refresh token available.');
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'), // Verify endpoint name
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newToken = data['token'] ?? data['accessToken'];
        final newRefreshToken = data['refreshToken'] ?? data['refresh_token'];

        if (newToken != null) {
          await _storage.saveToken(newToken);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', newToken);

          if (newRefreshToken != null) {
            await _storage.saveRefreshToken(newRefreshToken);
            await prefs.setString('refreshToken', newRefreshToken);
          }
          return newToken;
        }
      } else {
        print(
          'Token refresh failed: ${response.statusCode} - ${response.body}',
        );
        // Optional: clear tokens if refresh fails to force login
        // await _storage.clearAll();
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return null;
  }

  Future<DonneurModel?> searcherProfile(String? ignoreToken) async {
    return await _authenticatedRequest<DonneurModel?>((token) async {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile-searcher'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
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
      } else if (response.statusCode == 401) {
        throw '401';
      }
      return null;
    });
  }

  // Get user profile by userId
  Future<DonneurModel?> getUserProfile(
    String userId,
    String? ignoreToken,
  ) async {
    return await _authenticatedRequest<DonneurModel?>((token) async {
      final endpoints = [
        '$baseUrl/auth/searcher/$userId',
        '$baseUrl/users/$userId',
        '$baseUrl/auth/user/$userId',
        '$baseUrl/api/user/users/$userId',
        '$baseUrl/user/$userId',
        '$baseUrl/donneurs/$userId',
        '$baseUrl/searchers/$userId',
        '$baseUrl/auth/donneur/$userId',
      ];

      for (final url in endpoints) {
        try {
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
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
          } else if (response.statusCode == 401) {
            throw '401';
          }
        } catch (e) {
          if (e.toString().contains('401')) rethrow;
          print('ApiService.getUserProfile error for $url: $e');
        }
      }
      return null;
    });
  }

  Future<Map<String, dynamic>?> canditures() async {}

  //adding job vancy
  Future<Map<String, dynamic>?> addVancy(
    AddVancyModel vancy,
    List<File> images,
    String? token, // token argument kept for compatibility
  ) async {
    return await _authenticatedRequest<Map<String, dynamic>?>((
      authToken,
    ) async {
      try {
        print('=== ADD VANCY DEBUG ===');
        print('Number of images to upload: ${images.length}');

        // If no images, use regular JSON POST for better backend validation compatibility
        if (images.isEmpty) {
          print('Adding vacancy via JSON POST (no images)...');
          final response = await http.post(
            Uri.parse('$baseUrl/job-offers'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(vancy.toJson()),
          );

          print('Response status code: ${response.statusCode}');
          print('Response body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            return jsonDecode(response.body);
          } else {
            //if (response.statusCode == 401) rethrow; // Let _authenticatedRequest handle it
            print('ERROR: Failed to add vancy via JSON');
            return null;
          }
        }

        // If images exist, use MultipartRequest
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/job-offers'),
        );

        request.headers.addAll({
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        });

        // Add text fields from vancy model
        final fields = vancy.toJson();
        fields.forEach((key, value) {
          if (value != null) {
            if (value is List) {
              if (value.isEmpty) {
                request.fields[key] = "[]";
              } else {
                request.fields[key] = jsonEncode(value);
              }
            } else {
              request.fields[key] = value.toString();
            }
          }
        });

        print('Vancy fields: ${request.fields.keys.toList()}');

        // Add images (max 10)
        for (var i = 0; i < images.length; i++) {
          final file = images[i];
          final mimeType = lookupMimeType(file.path);
          final contentType = mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('image', 'jpeg');

          final fieldName = 'image';
          print(
            'Adding image $i as $fieldName: ${file.path} (${contentType.mimeType})',
          );

          request.files.add(
            await http.MultipartFile.fromPath(
              fieldName,
              file.path,
              contentType: contentType,
            ),
          );
        }

        print('Total files attached: ${request.files.length}');
        print('Sending multipart request to: ${request.url}');

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          print('Job vacancy added successfully via Multipart!');
          return responseData;
        } else {
          if (response.statusCode == 401)
            throw '401'; // Let _authenticatedRequest handle it
          print('ERROR: Failed to add vancy via Multipart');
          print('Status: ${response.statusCode}');
          print('Body: ${response.body}');
        }
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        print('ERROR adding vancy: $e');
      }
      return null;
    });
  }

  // Get company vacancies
  Future<List<AddVancyModel>> getMyVacancies(String? ignoreToken) async {
    return await _authenticatedRequest<List<AddVancyModel>>((token) async {
          List<AddVancyModel> allVacancies = [];
          int page = 1;
          bool hasMore = true;

          while (hasMore) {
            final url = '$baseUrl/job-offers?page=$page&limit=50';
            print('DEBUG: getMyVacancies fetching page $page: $url');

            final response = await http.get(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            );

            if (response.statusCode == 200) {
              final dynamic decodedBody = jsonDecode(response.body);
              List<dynamic>? list;
              int? totalPages;

              if (decodedBody is List) {
                list = decodedBody;
                hasMore = false;
              } else if (decodedBody is Map<String, dynamic>) {
                list =
                    decodedBody['data'] ??
                    decodedBody['offers'] ??
                    decodedBody['results'] ??
                    decodedBody['vancies'];

                if (decodedBody['meta'] != null) {
                  totalPages = decodedBody['meta']['totalPages'];
                  final int currentPage = decodedBody['meta']['page'] ?? page;
                  if (totalPages != null && currentPage >= totalPages) {
                    hasMore = false;
                  }
                } else if (decodedBody['totalPages'] != null) {
                  totalPages = decodedBody['totalPages'];
                  if (page >= totalPages!) hasMore = false;
                } else {
                  if (list == null || list.isEmpty) hasMore = false;
                }
              }

              if (list != null && list.isNotEmpty) {
                final pageItems = list
                    .map((e) => AddVancyModel.fromJson(e))
                    .toList();
                allVacancies.addAll(pageItems);
                print(
                  'DEBUG: getMyVacancies page $page added ${pageItems.length} items',
                );
                page++;
              } else {
                hasMore = false;
              }
            } else if (response.statusCode == 401) {
              throw '401';
            } else {
              print(
                'DEBUG: getMyVacancies failed with status: ${response.statusCode}',
              );
              hasMore = false;
            }
          }
          return allVacancies;
        }) ??
        [];
  }

  Future<bool> updateJobOffer(
    String id,
    AddVancyModel jobOffer,
    String?
    token, // token argument kept for compatibility but will be overridden by _authenticatedRequest
  ) async {
    final result = await _authenticatedRequest<bool>((authToken) async {
      try {
        print(
          'DEBUG: updateJobOffer - Sending PATCH to $baseUrl/job-offers/$id',
        );

        // Filter payload to match API documentation strictly
        final Map<String, dynamic> payload = jobOffer.toJson();
        payload.remove('companyId');
        payload.remove('ownerRole');
        payload.remove('createdAt');
        payload.remove('companyName');
        payload.remove('companyImage');
        payload.remove('id'); // ID is in URL

        print('DEBUG: updateJobOffer - Payload: ${jsonEncode(payload)}');

        final response = await http.patch(
          Uri.parse('$baseUrl/job-offers/$id'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(payload),
        );

        print(
          'DEBUG: updateJobOffer - Response Status: ${response.statusCode}',
        );
        print('DEBUG: updateJobOffer - Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        } else if (response.statusCode == 401) {
          throw '401'; // Force retry
        } else {
          print(
            'Error updating job offer: ${response.statusCode} - ${response.body}',
          );
          return false;
        }
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        print('Exception updating job offer: $e');
        return false;
      }
    });
    return result ?? false;
  }

  Future<bool> deleteJobOffer(String id, String? token) async {
    final result = await _authenticatedRequest<bool>((authToken) async {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/job-offers/$id'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          return true;
        } else if (response.statusCode == 401) {
          throw '401'; // Force retry
        } else {
          print(
            'Error deleting job offer: ${response.statusCode} - ${response.body}',
          );
          if (response.body.contains('Foreign key constraint violated')) {
            throw 'API_ERROR: FOREIGN_KEY';
          }
          return false;
        }
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        if (e.toString().contains('API_ERROR:')) rethrow;
        print('Exception deleting job offer: $e');
        return false;
      }
    });
    return result ?? false;
  }

  // Used for adding a candidate (apply for job)
  Future<Map<String, dynamic>?> addCandidate(
    CandidateModel candidate,
    String? ignoreToken,
  ) async {
    return await _authenticatedRequest<Map<String, dynamic>?>((token) async {
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

        if (candidate.document != null) {
          final file = candidate.document!;
          final mimeType = lookupMimeType(file.path);
          final contentType = mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('application', 'pdf');

          request.files.add(
            await http.MultipartFile.fromPath(
              'document',
              file.path,
              contentType: contentType,
            ),
          );
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 401) {
          throw '401';
        } else {
          print('AddCandidate failed: ${response.statusCode}');
        }
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        print('An exception occurred at $e');
      }
      return null;
    });
  }

  Future<List<CandidateModel>> getJobApplicants(
    String jobId,
    String? initialToken, {
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _authenticatedRequest<List<CandidateModel>>((
      token,
    ) async {
      try {
        final url = '$baseUrl/candidatures/job/$jobId';
        print('DEBUG: getJobApplicants fetching for jobId: $jobId');

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        print('DEBUG: getJobApplicants response code: ${response.statusCode}');
        print('DEBUG: getJobApplicants response body: ${response.body}');

        if (response.statusCode == 200) {
          final dynamic decoded = jsonDecode(response.body);
          List<dynamic> data = [];

          if (decoded is List) {
            data = decoded;
          } else if (decoded is Map<String, dynamic>) {
            data =
                decoded['data'] ??
                decoded['candidatures'] ??
                decoded['results'] ??
                [];
          }

          print(
            'DEBUG: getJobApplicants found ${data.length} applicants for job $jobId',
          );

          final candidates = data.map((json) {
            return CandidateModel.fromJson(json);
          }).toList();
          return candidates;
        } else if (response.statusCode == 401) {
          throw '401'; // Force retry in _authenticatedRequest
        } else {
          print(
            "DEBUG: getJobApplicants failed with ${response.statusCode}: ${response.body}",
          );
        }
      } catch (e) {
        if (e.toString().contains('401'))
          rethrow; // Pass up to _authenticatedRequest
        print('ApiService.getJobApplicants error: $e');
      }
      return [];
    });
    return result ?? [];
  }

  // Rebuild comment
  // Rebuild comment
  Future<List<CandidateModel>> getEnterpriseCandidates(
    String enterpriseId,
    String? ignoreToken,
  ) async {
    return await _authenticatedRequest<List<CandidateModel>>((token) async {
          try {
            print(
              'DEBUG: getEnterpriseCandidates called for enterpriseId: $enterpriseId',
            );
            final allJobs = await getMyVacancies(token);
            final jobs = allJobs.where((job) {
              return job.companyId.toString().trim() ==
                  enterpriseId.toString().trim();
            }).toList();

            if (jobs.isEmpty) return [];

            List<CandidateModel> allCandidates = [];
            for (var job in jobs) {
              if (job.id != null && job.id!.isNotEmpty) {
                final jobCandidates = await getJobApplicants(job.id!, token);
                allCandidates.addAll(jobCandidates);
              }
            }
            return allCandidates;
          } catch (e) {
            if (e.toString().contains('401')) rethrow;
            print('ApiService.getEnterpriseCandidates error: $e');
          }
          return [];
        }) ??
        [];
  }

  Future<List<CandidateModel>> getJobApplicantById(
    String jobId,
    String? ignoreToken,
  ) async {
    return await _authenticatedRequest<List<CandidateModel>>((token) async {
          try {
            final url = '$baseUrl/candidatures/$jobId';
            final response = await http.get(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            );
            if (response.statusCode == 200) {
              final dynamic decoded = jsonDecode(response.body);
              List<dynamic> data = [];
              if (decoded is List) {
                data = decoded;
              } else if (decoded is Map) {
                data =
                    decoded['data'] ??
                    decoded['candidatures'] ??
                    decoded['results'] ??
                    [];
              }
              return data.map((json) => CandidateModel.fromJson(json)).toList();
            } else if (response.statusCode == 401) {
              throw '401';
            }
          } catch (e) {
            if (e.toString().contains('401')) rethrow;
            print('ApiService.getJobApplicantById error: $e');
          }
          return [];
        }) ??
        [];
  }

  Future<Map<String, dynamic>?> updateStatus(
    String candidatureId,
    String newStatus, [
    String? token,
  ]) async {
    return _authenticatedRequest<Map<String, dynamic>?>((authToken) async {
      try {
        final response = await http.patch(
          Uri.parse('$baseUrl/candidatures/$candidatureId'),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'status': newStatus}),
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 401) {
          throw '401'; // Force retry
        } else {
          print('Update failed: ${response.body}');
          return null;
        }
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        print('Exception updating status: $e');
        return null;
      }
    });
  }

  Future<List<Map<String, dynamic>>> getUserApplications(
    String? ignoreToken, {
    String? userId,
  }) async {
    if (userId == null) return [];
    return await _authenticatedRequest<List<Map<String, dynamic>>>((
          token,
        ) async {
          try {
            final url = '$baseUrl/candidatures/$userId';
            final response = await http.get(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            );
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
              return List<Map<String, dynamic>>.from(list);
            } else if (response.statusCode == 401) {
              throw '401';
            }
          } catch (e) {
            if (e.toString().contains('401')) rethrow;
            print('ApiService.getUserApplications error: $e');
          }
          return [];
        }) ??
        [];
  }

  // Get job applications for a specific user (Searcher)
  Future<List<Map<String, dynamic>>> getUserJobApplications({
    required String userId,
    String? token,
    int page = 1,
    int limit = 10,
  }) async {
    return await _authenticatedRequest<List<Map<String, dynamic>>>((
          authToken,
        ) async {
          try {
            final url =
                '$baseUrl/candidatures/job/by-user/$userId?page=$page&limit=$limit';
            print('DEBUG: getUserJobApplications fetching: $url');

            final response = await http.get(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $authToken',
                'Accept': 'application/json',
              },
            );

            print('DEBUG: getUserJobApplications response: ${response.body}');

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
              return List<Map<String, dynamic>>.from(list);
            } else if (response.statusCode == 401) {
              throw '401';
            } else {
              print(
                'getUserJobApplications failed: ${response.statusCode} - ${response.body}',
              );
              return [];
            }
          } catch (e) {
            if (e.toString().contains('401')) rethrow;
            print('ApiService.getUserJobApplications error: $e');
            return [];
          }
        }) ??
        [];
  }

  Future<Map<String, dynamic>?> getJobById(
    String jobId,
    String? ignoreToken,
  ) async {
    return await _authenticatedRequest<Map<String, dynamic>?>((token) async {
      try {
        final url = '$baseUrl/job-offers/$jobId';
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 401) {
          throw '401';
        }
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        print('ApiService.getJobById error: $e');
      }
      return null;
    });
  }

  Future<Map<String, dynamic>?> addProperties(
    HouseModel property,
    List<File> images,
    String? ignoreToken,
  ) async {
    return await _authenticatedRequest<Map<String, dynamic>?>((token) async {
      try {
        print('=== ADD PROPERTIES DEBUG ===');
        print('Number of images to upload: ${images.length}');

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/properties'),
        );

        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

        final fields = property.toJson();
        fields.forEach((key, value) {
          if (value != null) {
            if (value is List) {
              request.fields[key] = jsonEncode(value);
            } else {
              request.fields[key] = value.toString();
            }
          }
        });

        for (var i = 0; i < images.length; i++) {
          final file = images[i];
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

        final response = await http.Response.fromStream(await request.send());

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 401) {
          throw '401';
        } else {
          print(
            'ERROR: Failed to add property. Status: ${response.statusCode}',
          );
        }
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        print('ERROR adding property: $e');
      }
      return null;
    });
  }

  Future<Map<String, dynamic>?> updateGalleryImage(
    String propertyId,
    List<File> images,
    String? ignoreToken,
  ) async {
    return await _authenticatedRequest<Map<String, dynamic>?>((token) async {
      try {
        final request = http.MultipartRequest(
          'PATCH',
          Uri.parse('$baseUrl/properties/update-galery-image/$propertyId'),
        );

        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

        for (var i = 0; i < images.length; i++) {
          final file = images[i];
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

        final response = await http.Response.fromStream(await request.send());

        if (response.statusCode == 200 || response.statusCode == 201) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 401) {
          throw '401';
        }
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        print('ERROR updating gallery: $e');
      }
      return null;
    });
  }

  Future<bool> deleteProperty(String id, String? ignoreToken) async {
    return await _authenticatedRequest<bool>((token) async {
          final response = await http.delete(
            Uri.parse('$baseUrl/properties/$id'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            print('Property deleted successfully');
            return true;
          } else if (response.statusCode == 401) {
            throw '401';
          } else {
            print('Delete Property failed: ${response.statusCode}');
            print('Body: ${response.body}');
            return false;
          }
        }) ??
        false;
  }

  Future<List<TypeProperties>> typeProperties(String? ignoreToken) async {
    return await _authenticatedRequest<List<TypeProperties>>((token) async {
          final response = await http.get(
            Uri.parse('$baseUrl/type-properties'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final dynamic decoded = jsonDecode(response.body);
            List<dynamic> body = [];
            if (decoded is List) {
              body = decoded;
            } else if (decoded is Map<String, dynamic>) {
              body =
                  decoded['data'] ??
                  decoded['types'] ??
                  decoded['results'] ??
                  [];
            }
            return body.map((e) => TypeProperties.fromJson(e)).toList();
          } else if (response.statusCode == 401) {
            throw '401';
          } else {
            print('API fetch typeProperties failed: ${response.statusCode}');
            return null; // Let the wrapper handle it or return fallback
          }
        }) ??
        [
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

  Future<List<HouseModel>> getProperties(
    String? ignoreToken, {
    String? companyId,
  }) async {
    return await _authenticatedRequest<List<HouseModel>>((token) async {
          final response = await http.get(
            Uri.parse('$baseUrl/properties'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

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
            List<HouseModel> all = body
                .map((e) => HouseModel.fromJson(e))
                .toList();

            if (companyId != null) {
              return all
                  .where(
                    (h) => h.companyId == companyId || h.ownerId == companyId,
                  )
                  .toList();
            }
            return all;
          } else if (response.statusCode == 401) {
            throw '401';
          } else {
            print('ApiService.getProperties failed: ${response.statusCode}');
            return null;
          }
        }) ??
        [];
  }

  Future<Map<String, dynamic>?> updateProperty(
    String id,
    Map<String, dynamic> data,
    String? token,
  ) async {
    return _authenticatedRequest((token) async {
      print('=== ApiService.updateProperty - START ===');
      final url = Uri.parse('$baseUrl/properties/$id');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('DEBUG: Using standard JSON PATCH for metadata');

      if (data.containsKey('area') && data['area'] != null) {
        data['area'] = data['area'].toString();
      }

      if (data.containsKey('advantage') && data['advantage'] is String) {
        data['advantage'] = [data['advantage']];
      }
      if (data.containsKey('condition') && data['condition'] is String) {
        data['condition'] = [data['condition']];
      }

      // Check for empty strings in the lists and replace with null as requested
      void cleanList(String key) {
        if (data.containsKey(key) && data[key] is List) {
          final list = data[key] as List;
          if (list.isEmpty ||
              (list.length == 1 && list.first.toString().trim().isEmpty)) {
            data[key] = null;
          }
        }
      }

      cleanList('advantage');
      cleanList('condition');

      print('DEBUG: Payload: ${jsonEncode(data)}');

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw '401';
      } else {
        print(
          '=== ApiService.updateProperty - FAILED: ${response.statusCode} ===',
        );
        print('Body: ${response.body}');
        return null;
      }
    });
  }

  Future<bool> updateGalleryImages(
    String id,
    List<File> images,
    String? ignoreToken,
  ) async {
    return await _authenticatedRequest<bool>((token) async {
          print('=== ApiService.updateGalleryImages - START ===');
          final url = Uri.parse('$baseUrl/properties/update-galery-image/$id');
          final request = http.MultipartRequest('PATCH', url);
          request.headers.addAll({
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          });

          for (var file in images) {
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

          final response = await http.Response.fromStream(await request.send());
          print('Gallery update response status: ${response.statusCode}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            return true;
          } else if (response.statusCode == 401) {
            throw '401';
          } else {
            print(
              'ERROR: Failed to update gallery images: ${response.statusCode}',
            );
            print('Body: ${response.body}');
            return false;
          }
        }) ??
        false;
  }

  Future<Map<String, dynamic>?> sendMessage(
    SendMessageModel chat,
    String? token,
  ) async {
    try {
      final url = '$baseUrl/chats';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      final headers = await _getAuthHeaders(token);
      request.headers.addAll(headers);

      request.fields['senderId'] = chat.senderId;
      request.fields['receiverId'] = chat.receiverId;
      request.fields['content'] = chat.content;

      if (chat.attachments != null && chat.attachments!.isNotEmpty) {
        for (var file in chat.attachments!.take(15)) {
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
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print('DEBUG: sendMessage FAILED Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('DEBUG: sendMessage error: $e');
      return null;
    }
  }

  // Retrieve a message by its ID
  Future<List<SendMessageModel>> fetchMessagesById(
    String messageId, [
    String? token,
  ]) async {
    try {
      final url = '$baseUrl/chats/$messageId';
      final headers = await _getAuthHeaders(token);
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded['data'] ?? decoded['message'] ?? decoded;
        if (list is List) {
          return list.map((j) => SendMessageModel.fromJson(j)).toList();
        }
      }
    } catch (e) {
      print('Failed to fetch message by ID: $e');
    }
    return [];
  }

  Future<List<SendMessageModel>?> allConversation(
    String userId, {
    String? token,
  }) async {
    try {
      final headers = await _getAuthHeaders(token);
      final response = await http.get(
        Uri.parse('$baseUrl/chats/by-user/$userId'),
        headers: headers,
      );

      List<SendMessageModel> allMessages = [];

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> list = [];

        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list =
              decoded['data'] ??
              decoded['chats'] ??
              decoded['messages'] ??
              decoded['results'] ??
              [];
        }

        allMessages = list
            .map((json) => SendMessageModel.fromJson(json))
            .toList();
      }

      if (allMessages.isEmpty) {
        final fallbackData = await fetchConversations(token, userId: userId);
        final List<SendMessageModel> fallbackModels = [];
        for (final e in fallbackData) {
          if (e is Map<String, dynamic>) {
            final partnerId =
                (e['receiverId'] ?? e['otherUserId'] ?? e['id'])?.toString() ??
                '';
            if (partnerId.isEmpty || partnerId == 'null') continue;
            fallbackModels.add(
              SendMessageModel(
                id: partnerId,
                content: e['lastMessage'] ?? '',
                senderId: userId,
                receiverId: partnerId,
                userName: e['name'] ?? 'Utilisateur',
                userPhoto: e['image'],
                timestamp: e['timestamp'] != null
                    ? DateTime.tryParse(e['timestamp'])
                    : null,
              ),
            );
          }
        }
        return fallbackModels;
      }

      final Map<String, SendMessageModel> conversationsMap = {};
      for (var msg in allMessages) {
        String partnerId = '';
        if (msg.senderId.isNotEmpty && msg.senderId != userId) {
          partnerId = msg.senderId;
        } else if (msg.receiverId.isNotEmpty && msg.receiverId != userId) {
          partnerId = msg.receiverId;
        }

        if (partnerId.isEmpty || partnerId == userId) continue;

        final wasMe = (msg.senderId == userId || msg.senderId.trim().isEmpty);
        final normalizedMsg = SendMessageModel(
          id: msg.id,
          content: msg.content,
          senderId: wasMe ? userId : partnerId,
          receiverId: wasMe ? partnerId : userId,
          userName: msg.userName,
          userPhoto: msg.userPhoto,
          timestamp: msg.timestamp,
        );

        if (!conversationsMap.containsKey(partnerId)) {
          conversationsMap[partnerId] = normalizedMsg;
        } else {
          final existing = conversationsMap[partnerId]!;
          if (normalizedMsg.timestamp != null &&
              (existing.timestamp == null ||
                  normalizedMsg.timestamp!.isAfter(existing.timestamp!))) {
            conversationsMap[partnerId] = normalizedMsg;
          }
        }
      }
      final result = conversationsMap.values.toList();
      result.sort(
        (a, b) =>
            (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)),
      );
      return result;
    } catch (e) {
      print('ApiService.allConversation error: $e');
      return null;
    }
  }

  Future<List<dynamic>> fetchConversations(
    String? token, {
    String? userId,
  }) async {
    try {
      final headers = await _getAuthHeaders(token);
      List<SendMessageModel> allMessages = [];

      Future<void> fetchAndAdd(String url) async {
        final resp = await http.get(Uri.parse(url), headers: headers);
        if (resp.statusCode == 200) {
          final d = jsonDecode(resp.body);
          List l = [];
          if (d is List)
            l = d;
          else if (d is Map)
            l = d['data'] ?? d['messages'] ?? d['results'] ?? [];
          allMessages.addAll(l.map((e) => SendMessageModel.fromJson(e)));
        }
      }

      await fetchAndAdd('$baseUrl/chats?senderId=$userId&limit=100');
      await fetchAndAdd('$baseUrl/chats?receiverId=$userId&limit=100');

      final Map<String, Map<String, dynamic>> conversations = {};
      for (var msg in allMessages) {
        String partnerId = (msg.senderId == userId)
            ? msg.receiverId
            : msg.senderId;
        if (partnerId.isEmpty || partnerId == 'null') continue;

        if (!conversations.containsKey(partnerId)) {
          conversations[partnerId] = {
            'id': partnerId,
            'name': msg.userName.isNotEmpty ? msg.userName : "Utilisateur",
            'lastMessage': msg.content,
            'timestamp': msg.timestamp?.toIso8601String(),
            'receiverId': partnerId,
            'image': msg.userPhoto,
          };
        }
      }
      return conversations.values.toList();
    } catch (e) {
      print('ApiService.fetchConversations error: $e');
      return [];
    }
  }

  // Fetch messages between two users
  Future<List<SendMessageModel>> fetchMessagesBetweenUsers(
    String senderId,
    String receiverId,
    String? token, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final headers = await _getAuthHeaders(token);
      List<SendMessageModel> allRelevantMessages = [];

      Future<void> fetchAndAdd(String url) async {
        final resp = await http.get(Uri.parse(url), headers: headers);
        if (resp.statusCode == 200) {
          final d = jsonDecode(resp.body);
          List l = [];
          if (d is List)
            l = d;
          else if (d is Map)
            l = d['data'] ?? d['messages'] ?? d['results'] ?? [];
          allRelevantMessages.addAll(
            l.map((e) => SendMessageModel.fromJson(e)),
          );
        }
      }

      await fetchAndAdd(
        '$baseUrl/chats?senderId=$senderId&receiverId=$receiverId&limit=$limit&page=$page',
      );
      await fetchAndAdd(
        '$baseUrl/chats?senderId=$receiverId&receiverId=$senderId&limit=$limit&page=$page',
      );

      final filtered = allRelevantMessages.where((msg) {
        final s = msg.senderId.trim();
        final r = msg.receiverId.trim();
        return (s == senderId && r == receiverId) ||
            (s == receiverId && r == senderId);
      }).toList();

      final uniqueMessages = {for (var m in filtered) m.id: m}.values.toList();
      uniqueMessages.sort(
        (a, b) =>
            (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)),
      );
      return uniqueMessages;
    } catch (e) {
      print('ApiService.fetchMessagesBetweenUsers error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> updateEnterpriseProfile(
    EnterpriseModel request, [
    File? image, // Optional image
  ]) async {
    return _authenticatedRequest<Map<String, dynamic>?>((token) async {
      // List of potential update endpoints to try if one fails to persist
      // Actually, we'll stick to the one that gives 200 first, but we'll try to find the "richest" one
      final endpoints = [
        Uri.parse('$baseUrl/auth/update-profile/${request.id}'),
        Uri.parse('$baseUrl/auth/update-profile-giver/${request.id}'),
        Uri.parse('$baseUrl/auth/update-giver/${request.id}'),
      ];

      Map<String, dynamic>? lastResult;

      for (final url in endpoints) {
        print('DEBUG: updateEnterpriseProfile - Trying URL: $url');

        final req = http.MultipartRequest('PATCH', url);
        req.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

        // Add text fields (all variants from toUpdateJson)
        final fields = request.toUpdateJson();
        fields.forEach((key, value) {
          if (value != null) {
            req.fields[key] = value.toString();
          }
        });

        // Log fields once per request
        print(
          'DEBUG: updateEnterpriseProfile - Sending fields: ${req.fields.keys.toList()}',
        );

        File? imageToSend = image;

        // MANDATORY IMAGE: Backend requirement. Download current if no new one provided.
        if (imageToSend == null &&
            request.profile != null &&
            request.profile!.isNotEmpty) {
          print(
            'DEBUG: updateEnterpriseProfile - No new image, downloading existing for re-upload: ${request.profile}',
          );
          imageToSend = await _downloadFile(
            request.profile!,
            'temp_current_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        }

        if (imageToSend != null) {
          final mimeType = lookupMimeType(imageToSend.path);
          final contentType = mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('image', 'jpeg');
          req.files.add(
            await http.MultipartFile.fromPath(
              'image',
              imageToSend.path,
              contentType: contentType,
            ),
          );
        }

        final streamedResponse = await req.send();
        final response = await http.Response.fromStream(streamedResponse);

        print(
          'DEBUG: updateEnterpriseProfile - Status for $url: ${response.statusCode}',
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final result = jsonDecode(response.body);
          print(
            'DEBUG: updateEnterpriseProfile - Success Body for $url: $result',
          );
          lastResult = result;
          break;
        } else if (response.statusCode == 401) {
          throw '401';
        } else {
          print(
            'DEBUG: updateEnterpriseProfile - Failed for $url: ${response.body}',
          );
        }
      }
      return lastResult;
    });
  }

  Future<Map<String, dynamic>?> updateDonneurProfile(
    DonneurModel request, [
    File? image,
  ]) async {
    return _authenticatedRequest<Map<String, dynamic>?>((token) async {
      final req = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/auth/update-profile/${request.id}'),
      );

      req.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final jsonMap = request.toJson();
      jsonMap.forEach((key, value) {
        if (value != null) {
          req.fields[key] = value.toString();
        }
      });

      File? imageToSend = image;

      if (imageToSend == null &&
          request.profile != null &&
          request.profile!.isNotEmpty) {
        final receivedFile = await _downloadFile(
          request.profile!,
          'temp_donneur_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        if (receivedFile != null) {
          imageToSend = receivedFile;
        }
      }

      if (imageToSend != null) {
        final mimeType = lookupMimeType(imageToSend.path);
        final contentType = mimeType != null
            ? MediaType.parse(mimeType)
            : MediaType('image', 'jpeg');

        req.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageToSend.path,
            contentType: contentType,
          ),
        );
      }

      final streamedResponse = await req.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw '401';
      } else {
        print('Update Donneur Profile (Multipart) failed: ${response.body}');
      }
      return null;
    });
  }

  Future<File?> _downloadFile(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$filename');
        return await file.writeAsBytes(response.bodyBytes);
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: _headers,
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Verify OTP failed: ${response.statusCode} - ${response.body}');
        return {
          'error': true,
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createNewPassword(
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/create-new-password/$email'),
        headers: _headers,
        body: jsonEncode({'password': password, 'cpassword': confirmPassword}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Create new password failed: ${response.statusCode} - ${response.body}',
        );
        return {
          'error': true,
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      print('Error creating new password: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendOtpByMail(String email) async {
    int retryCount = 0;
    const int maxRetries = 2;

    while (retryCount < maxRetries) {
      try {
        print(
          'DEBUG: sendOtpByMail - START (Attempt ${retryCount + 1}) for $email',
        );
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/send-otp-by-mail'),
              headers: _headers,
              body: jsonEncode({'email': email}),
            )
            .timeout(const Duration(seconds: 60));

        print('DEBUG: sendOtpByMail - STATUS: ${response.statusCode}');
        print('DEBUG: sendOtpByMail - BODY: ${response.body}');

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode >= 500 && retryCount < maxRetries - 1) {
          print('DEBUG: Server error 500, retrying...');
          retryCount++;
          await Future.delayed(const Duration(seconds: 2));
          continue;
        } else {
          print('Send OTP failed: ${response.statusCode} - ${response.body}');
          return {
            'error': true,
            'statusCode': response.statusCode,
            'body': response.body,
            'message': _parseErrorMessage(response.body),
          };
        }
      } catch (e) {
        print('Error sending OTP (Attempt ${retryCount + 1}): $e');
        if (retryCount < maxRetries - 1) {
          retryCount++;
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        String errorMessage = e.toString();
        if (e is TimeoutException) {
          errorMessage =
              "Le serveur est trop lent (Timeout 60s). Il se peut que le service soit en cours de démarrage.";
        }
        return {'error': true, 'message': errorMessage};
      }
    }
    return null;
  }

  String _parseErrorMessage(String body) {
    try {
      final data = jsonDecode(body);
      return data['message'] ?? data['error'] ?? 'Une erreur est survenue';
    } catch (_) {
      return 'Une erreur serveur est survenue';
    }
  }

  // Helper for automatic token refresh
  Future<T?> _authenticatedRequest<T>(
    Future<T?> Function(String token) request, [
    int depth = 0,
  ]) async {
    if (depth > 1) {
      print('Max refresh retries reached. Aborting.');
      return null;
    }

    // 1. Get current token
    String? token = await _storage.getToken();
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    if (token == null) return null;

    try {
      // 2. Try request
      return await request(token);
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('API_ERROR:')) {
        rethrow;
      }

      // 3. Catch 401 - Robust detection
      final isUnauthorized =
          errorStr.contains('401') ||
          errorStr.toLowerCase().contains('unauthorized') ||
          errorStr.contains('Token expiré');

      if (isUnauthorized) {
        print('Session expired (detected: $errorStr), attempting refresh...');
        final newToken = await refreshToken();

        if (newToken != null) {
          print('Token refreshed successfully, retrying...');
          return await _authenticatedRequest(request, depth + 1);
        } else {
          print('Token refresh failed. Directing to login state.');
        }
      } else {
        print('Authenticated request error: $e');
      }
    }
    return null;
  }
}
