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
import 'package:demarcheur_app/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  //load the givers
  Future<DonneurModel?> searcherProfile(String? token) async {
    final headers = await _getAuthHeaders(token);
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile-searcher'),
      headers: headers,
    );
    try {
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
        final headers = await _getAuthHeaders(token);
        final response = await http.get(Uri.parse(url), headers: headers);

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

      final headers = await _getAuthHeaders(token);

      final response = await http.post(
        Uri.parse('$baseUrl/job-offers'),
        headers: headers,
        body: body,
      );

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
      final headers = await _getAuthHeaders(token);
      final response = await http.get(
        Uri.parse(
          '$baseUrl/job-offers',
        ), // Assuming this endpoint exists, or fallback to /job-offers
        headers: headers,
      );

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

      final headers = await _getAuthHeaders(token);
      request.headers.addAll(headers);

      request.fields['JobId'] = candidate.jobId;
      request.fields['appliquantId'] = candidate.appliquantId;

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
    try {
      final url = '$baseUrl/candidatures/job/$jobId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

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

        final candidates = data.map((json) {
          return CandidateModel.fromJson(json);
        }).toList();
        return candidates;
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
      // First, get all jobs for this enterprise
      final allJobs = await getMyVacancies(token);

      // Filter to only jobs that belong to this specific enterprise
      final jobs = allJobs
          .where((job) => job.companyId == enterpriseId)
          .toList();

      if (jobs.isEmpty) {
        return [];
      }

      // Then, fetch candidates for each job
      List<CandidateModel> allCandidates = [];

      for (var job in jobs) {
        if (job.id != null && job.id!.isNotEmpty) {
          final jobCandidates = await getJobApplicants(job.id!, token);
          allCandidates.addAll(jobCandidates);
        }
      }
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

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

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

        final candidates = data.map((json) {
          return CandidateModel.fromJson(json);
        }).toList();
        return candidates;
      }
    } catch (e) {
      print('ApiService.getJobApplicants error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> updateStatus(
    String candidatureId,
    String newStatus, [
    String? token,
  ]) async {
    final headers = await _getAuthHeaders(token);
    final response = await http.patch(
      Uri.parse('$baseUrl/candidatures/$candidatureId'),
      headers: headers,
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
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

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
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
      final headers = await _getAuthHeaders(token);
      final response = await http.get(
        Uri.parse('$baseUrl/type-properties'),
        headers: headers,
      );

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
      print('DEBUG: types exception: $e');
    }
    return [];
  }

  Future<List<HouseModel>> getProperties(
    String? token, {
    String? companyId,
  }) async {
    try {
      final headers = await _getAuthHeaders(token);
      final response = await http.get(
        Uri.parse('$baseUrl/properties'),
        headers: headers,
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
        List<HouseModel> all = body.map((e) => HouseModel.fromJson(e)).toList();

        if (companyId != null) {
          return all
              .where((h) => h.companyId == companyId || h.ownerId == companyId)
              .toList();
        }
        return all;
      }
    } catch (e) {
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

      final headers = await _getAuthHeaders(token);
      request.headers.addAll(headers);

      // Required fields as per doc: senderId, receiverId, content
      request.fields['senderId'] = chat.senderId;
      request.fields['receiverId'] = chat.receiverId;
      request.fields['content'] = chat.content;

      // Optional property: image (array of files, max 15)
      if (chat.attachments != null && chat.attachments!.isNotEmpty) {
        // Enforce max 15 files as mentioned in doc
        final filesToSend = chat.attachments!.take(15).toList();
        if (chat.attachments!.length > 15) {
          print(
            'WARNING: ApiService.sendMessage - More than 15 images provided. Only the first 15 will be sent.',
          );
        }

        for (var file in filesToSend) {
          final mimeType = lookupMimeType(file.path);
          final contentType = mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType('image', 'jpeg');

          request.files.add(
            await http.MultipartFile.fromPath(
              'image', // Field name 'image' as per documentation
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
        print('DEBUG: sendMessage error body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during message sending: $e');
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
      } else {
        print('Failed to fetch message by ID: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching message by ID: $e');
    }
    return [];
  }

  Future<List<SendMessageModel>?> allConversation(
    String userId, {
    String? token,
  }) async {
    try {
      print(
        'DEBUG: ApiService.allConversation - Requesting for userId: $userId',
      );
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

      // Fallback Strategy: If targeted fetch empty or failed, try more exhaustive search
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
          } else if (e is SendMessageModel) {
            fallbackModels.add(e);
          }
        }
        return fallbackModels;
      }

      // Grouping Logic: If endpoint returned raw messages, we must group them by conversation partner
      final Map<String, SendMessageModel> conversationsMap = {};

      print(
        'DEBUG: ApiService.allConversation - Total messages to group: ${allMessages.length}',
      );
      for (var msg in allMessages) {
        // Identify the partner ID.
        // Logic: The partner is the ID that is NOT mine.
        // If one is empty, the other is the partner.
        String partnerId = '';
        if (msg.senderId.isNotEmpty && msg.senderId != userId) {
          partnerId = msg.senderId;
        } else if (msg.receiverId.isNotEmpty && msg.receiverId != userId) {
          partnerId = msg.receiverId;
        }

        print(
          'DEBUG: ApiService.allConversation - msg: s="${msg.senderId}", r="${msg.receiverId}", partnerId="$partnerId"',
        );

        if (partnerId.isEmpty || partnerId == userId) {
          continue;
        }

        // Identify if I was the sender of the last message
        final wasMe = (msg.senderId == userId || msg.senderId.trim().isEmpty);

        // Create a normalized message where IDs are guaranteed for the UI
        final normalizedMsg = SendMessageModel(
          id: msg.id,
          content: msg.content,
          senderId: wasMe ? userId : partnerId,
          receiverId: wasMe ? partnerId : userId,
          userName: msg.userName,
          userPhoto: msg.userPhoto,
          timestamp: msg.timestamp,
        );

        print(
          'DEBUG: ApiService.allConversation - Produced normalized: s="${normalizedMsg.senderId}", r="${normalizedMsg.receiverId}"',
        );

        if (!conversationsMap.containsKey(partnerId)) {
          conversationsMap[partnerId] = normalizedMsg;
        } else {
          // Keep the newest message for the conversation
          final existing = conversationsMap[partnerId]!;
          if (normalizedMsg.timestamp != null &&
              (existing.timestamp == null ||
                  normalizedMsg.timestamp!.isAfter(existing.timestamp!))) {
            conversationsMap[partnerId] = normalizedMsg;
          }
        }
      }

      final result = conversationsMap.values.toList();
      // Sort newest first
      result.sort(
        (a, b) =>
            (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)),
      );

      print(
        'DEBUG: ApiService.allConversation - Final grouped conversations: ${result.length}',
      );
      return result;
    } catch (e) {
      print('DEBUG: ApiService.allConversation - Exception: $e');
    }
    return [];
  }

  Future<List<dynamic>> fetchConversations(
    String? token, {
    String? userId,
  }) async {
    try {
      // Since there is no DIRECT conversation endpoint in Swagger, we simulate it
      // by fetching ALL messages for the user and grouping them.

      List<SendMessageModel> allMessages = [];

      Future<void> fetchAndAdd(String url) async {
        try {
          print('DEBUG: fetchConversations - Requesting $url');
          final headers = await _getAuthHeaders(token);
          final resp = await http.get(Uri.parse(url), headers: headers);
          if (resp.statusCode == 200) {
            final d = jsonDecode(resp.body);
            List l = [];
            if (d is List) {
              l = d;
            } else if (d is Map) {
              l =
                  d['data'] ??
                  d['messages'] ??
                  d['chats'] ??
                  d['results'] ??
                  [];
            }
            print(
              'DEBUG: fetchConversations - Fetched ${l.length} messages from $url',
            );
            if (l.isEmpty) {
              print('DEBUG: fetchConversations - Empty Body: ${resp.body}');
            }

            allMessages.addAll(l.map((e) => SendMessageModel.fromJson(e)));
          } else {
            print(
              'DEBUG: fetchConversations - Failed $url status: ${resp.statusCode} Body: ${resp.body}',
            );
          }
        } catch (e) {
          print('Error fetching messages: $e');
        }
      }

      // Use CamelCase parameters as per Swagger documentation
      // Swagger says /chats requires senderId and receiverId.
      // We try to request with just one to get all conversations.
      await fetchAndAdd('$baseUrl/chats?senderId=$userId&limit=100');
      await fetchAndAdd('$baseUrl/chats?receiverId=$userId&limit=100');

      if (allMessages.isEmpty) {
        // Fallback: Fetch ALL chats for the user (assuming /chats returns the authenticated user's messages)
        print(
          'DEBUG: fetchConversations - Targeted fetch empty. Trying generic /chats endpoint',
        );
        await fetchAndAdd('$baseUrl/chats?limit=100');

        // If still empty, try without limit
        if (allMessages.isEmpty) {
          await fetchAndAdd('$baseUrl/chats');
        }
      }

      if (allMessages.isEmpty && userId == null) {
        // Fallback if userId wasn't provided, try the old endpoint just in case it exists undocumented
        print('DEBUG: fetchConversations - userId null, trying /chat fallback');
        final fallbackUrl = '$baseUrl/chat';
        try {
          final resp = await http.get(
            Uri.parse(fallbackUrl),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );
          if (resp.statusCode == 200) {
            final decoded = jsonDecode(resp.body);
            List<dynamic> list = (decoded is List)
                ? decoded
                : (decoded['data'] ?? []);
            return list;
          }
        } catch (_) {}
        return [];
      }

      // Group by partner ID
      final Map<String, Map<String, dynamic>> conversations = {};

      for (var msg in allMessages) {
        String partnerId;
        String partnerName = "Utilisateur"; // Default

        // Determine who is the partner
        if (msg.senderId == userId) {
          partnerId = msg.receiverId;
        } else {
          partnerId = msg.senderId;
        }

        if (partnerId.isEmpty || partnerId == 'null') continue;

        // Add to map if not present or update if this message is newer
        if (!conversations.containsKey(partnerId)) {
          conversations[partnerId] = {
            'id': partnerId,
            'name': msg.userName.isNotEmpty ? msg.userName : partnerName,
            'lastMessage': msg.content,
            'timestamp': msg.timestamp?.toIso8601String(),
            'receiverId': partnerId,
            'otherUserId': partnerId,
            'image': msg.userPhoto,
          };
        } else {
          // Update if newer
          final existing = conversations[partnerId];
          final oldTime = DateTime.tryParse(existing?['timestamp'] ?? '');
          final newTime = msg.timestamp;
          if (oldTime == null ||
              (newTime != null && newTime.isAfter(oldTime))) {
            conversations[partnerId]!['lastMessage'] = msg.content;
            conversations[partnerId]!['timestamp'] = msg.timestamp
                ?.toIso8601String();
          }
        }
      }

      print(
        'DEBUG: fetchConversations - Constructed ${conversations.length} conversations from messages',
      );
      return conversations.values.toList();
    } catch (e) {
      print('ApiService.fetchConversations error: $e');
    }
    return [];
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
      // Normalize IDs
      final String myId = senderId.trim();
      final String otherId = receiverId.trim();
      final headers = await _getAuthHeaders(token);
      print(
        'DEBUG: fetchMessages - Starting fetch for Me=$myId, Other=$otherId',
      );

      List<SendMessageModel> allRelevantMessages = [];

      Future<void> fetchAndAdd(String url) async {
        try {
          print('DEBUG: fetchMessages - Requesting $url');
          final resp = await http.get(Uri.parse(url), headers: headers);
          if (resp.statusCode == 200) {
            final d = jsonDecode(resp.body);
            List l = [];
            if (d is List) {
              l = d;
            } else if (d is Map) {
              l =
                  d['data'] ??
                  d['messages'] ??
                  d['chats'] ??
                  d['results'] ??
                  [];
            }
            if (l.isEmpty && d is Map) {
              print(
                'DEBUG: fetchMessages - Empty list from $url. Body keys: ${d.keys}',
              );
            } else {
              print(
                'DEBUG: fetchMessages - Fetched ${l.length} messages from $url',
              );
            }
            if (l.isEmpty) {
              print('DEBUG: fetchMessages - Empty Body: ${resp.body}');
            }

            if (l.isNotEmpty) {
              print('DEBUG: fetchMessages - Sample JSON from $url: ${l.first}');
            }
            allRelevantMessages.addAll(
              l.map((e) => SendMessageModel.fromJson(e)),
            );
          } else {
            print(
              'DEBUG: fetchMessages - Failed $url status: ${resp.statusCode}',
            );
          }
        } catch (e) {
          print('DEBUG: fetchMessages - Error fetching from $url: $e');
        }
      }

      // Use confirmed parameters from Swagger
      // 1. Direction Me -> Other
      await fetchAndAdd(
        '$baseUrl/chats?senderId=$myId&receiverId=$otherId&limit=100',
      );

      // 2. Direction Other -> Me (just in case the endpoint is directional)
      await fetchAndAdd(
        '$baseUrl/chats?senderId=$otherId&receiverId=$myId&limit=100',
      );

      // PROBE: If still empty, try to fetch ANY messages to debug the endpoint
      if (allRelevantMessages.isEmpty) {
        print(
          'DEBUG: fetchMessages - Targeted fetch empty. Trying generic /chats endpoint and filtering locally.',
        );

        List<SendMessageModel> genericList = [];
        // Use a temporary list to fetch generic
        Future<void> fetchGeneric(String url) async {
          try {
            final resp = await http.get(Uri.parse(url), headers: headers);
            if (resp.statusCode == 200) {
              final d = jsonDecode(resp.body);
              List l = [];
              if (d is List)
                l = d;
              else if (d is Map)
                l = d['data'] ?? d['messages'] ?? d['chats'] ?? [];
              if (l.isNotEmpty) {
                print(
                  'DEBUG: fetchMessages - Generic fetch found ${l.length} messages',
                );
                genericList.addAll(l.map((e) => SendMessageModel.fromJson(e)));
              }
            }
          } catch (e) {
            print('DEBUG: fetchMessages - Generic error $e');
          }
        }

        await fetchGeneric('$baseUrl/chats?limit=300'); // Fetch more to be safe
        if (genericList.isEmpty) await fetchGeneric('$baseUrl/chats');

        // Filter locally
        final filtered = genericList.where((m) {
          final s = m.senderId;
          final r = m.receiverId;
          return (s == myId && r == otherId) || (s == otherId && r == myId);
        }).toList();

        print(
          'DEBUG: fetchMessages - Locally filtered ${filtered.length} relevant messages from ${genericList.length} total.',
        );
        allRelevantMessages.addAll(filtered);
      }

      // 3. Filter for the specific conversation partner
      print(
        'DEBUG: fetchMessages - Filtering ${allRelevantMessages.length} candidates...',
      );

      final filtered = allRelevantMessages.where((msg) {
        final s = msg.senderId.trim();
        final r = msg.receiverId.trim();

        // Check for direction 1: Me -> Other
        final match1 = (s == myId && r == otherId);
        // Check for direction 2: Other -> Me
        final match2 = (s == otherId && r == myId);

        if (match1 || match2) {
          return true;
        }
        return false;
      }).toList();

      // Deduplicate based on ID
      final uniqueMessages = {for (var m in filtered) m.id: m}.values.toList();

      // Sort by timestamp (newest first)
      uniqueMessages.sort((a, b) {
        final tA = a.timestamp ?? DateTime(0);
        final tB = b.timestamp ?? DateTime(0);
        return tB.compareTo(tA);
      });

      print(
        'DEBUG: fetchMessages - Found ${uniqueMessages.length} final messages for conversation',
      );
      return uniqueMessages;
    } catch (e) {
      print('ApiService.fetchMessagesBetweenUsers error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> upDateProfile(String userId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/auth/update-profile/$userId'),
      headers: _headers,
      
    );
    return null;
  }
}
