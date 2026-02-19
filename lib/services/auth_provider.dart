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
import 'package:demarcheur_app/services/api_service.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:demarcheur_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  final apiService = ApiService();
  String? _token;
  String? get token => _token;
  String? _role;
  String? get role => _role;
  String? _userId;
  String? get userId => _userId;
  bool _isLoading = false;
  EnterpriseModel? _enterprise;
  EnterpriseModel? get enterprise => _enterprise;

  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _service;
  Map<String, dynamic>? get service => _service;
  List<ServiceModel> _serviceList = [];
  List<ServiceModel> get serviceList => _serviceList;
  List<TypeProperties> _propertyTypes = [];
  List<TypeProperties> get propertyTypes => _propertyTypes;
  bool get isEnterprise => _role == 'GIVER' && _enterprise != null;

  Map<String, dynamic>? _userData;

  String? get userName =>
      _userData?['username'] ??
      _userData?['name'] ??
      _userData?['companyName'] ??
      _enterprise?.name;

  String? get userPhoto =>
      _userData?['image'] ??
      _userData?['photo'] ??
      _userData?['logo'] ??
      _enterprise?.image;

  //list of service

  void loadService() async {
    _isLoading = true;
    notifyListeners();
    _serviceList = await apiService.serviceList();
    debugPrint(_serviceList.toString());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPropertyTypes() async {
    debugPrint("DEBUG: AuthProvider.loadPropertyTypes started");
    _isLoading = true;
    notifyListeners();
    try {
      _propertyTypes = await apiService.typeProperties(_token);
      debugPrint(
        "DEBUG: AuthProvider.loadPropertyTypes finished. Count: ${_propertyTypes.length}",
      );
    } catch (e) {
      debugPrint("DEBUG: AuthProvider.loadPropertyTypes error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  //for adding service
  Future<bool> services(ServiceModel service) async {
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('START CALLING SERVICE');
      final response = await apiService.serviceRegister(service);
      if (response != null) {
        debugPrint('Added successfully ');

        return true;
      }
    } catch (e) {
      debugPrint('Exception occured');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  //for giver of opportinuity
  Future<bool> registerGiver(EnterpriseModel enterprise) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('START CALLING REGISTRATION');
      final response = await apiService.registerGiver(enterprise);
      if (response != null) {
        debugPrint('Added successfully ');
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> registerDonneur(DonneurModel donneur) async {
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('START CALLING REGISTRATION');
      final response = await apiService.donneurRegistration(donneur);
      if (response != null) {
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> authentification(String item, String password) async {
    _isLoading = true;
    notifyListeners();
    debugPrint('START CALLING LOGIN');

    final response = await apiService.setLogin(item, password);

    if (response != null) {
      debugPrint('connected successfully');
      // ... (omitting some parts for brevity but tool will handle based on targetContent)

      final prefs = await SharedPreferences.getInstance();

      // 1. Save token
      final token = response['token'];
      if (token != null) {
        _token = token;
        final StorageService storage = StorageService();
        await storage.saveToken(token);
        await prefs.setString(
          'token',
          token,
        ); // Keep for compat if needed, but primary is storage.saveToken
      }

      // 2. Handle connected user
      if (response['user'] != null) {
        final userMap = response['user'];
        final role = userMap['role'];

        // ✅ Store enterprise in memory
        if (role == 'GIVER') {
          _enterprise = EnterpriseModel.fromJson(userMap);
        }
        _userData = userMap;
        print(
          'DEBUG: AuthProvider.authentification - User keys: ${userMap.keys}',
        );
        print('DEBUG: AuthProvider.authentification - User raw: $userMap');

        // Capture user ID
        _userId =
            (userMap['_id'] ??
                    userMap['id'] ??
                    userMap['user_id'] ??
                    userMap['userId'])
                ?.toString();

        // ✅ Persist user for both AuthProvider and specific Providers
        await prefs.setString('last_user_data', jsonEncode(userMap));
        
        if (role == 'GIVER') {
          await prefs.setString('giver_user_data', jsonEncode(userMap));
        } else {
          await prefs.setString('searcher_user_data', jsonEncode(userMap));
        }

        _role = role;
        await prefs.setString('role', role ?? '');
        await prefs.setString('user_role', role ?? '');

        // ✅ Store user_id explicitly for easier loading
        if (_userId != null) {
          await prefs.setString('user_id', _userId!);
        }

        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear SharedPreferences (tokens, user data, etc.)
    await StorageService().clearAll(); // Clear secure storage
    _token = null;
    _role = null;
    notifyListeners();

    // Navigate back to login
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/intro_onboarding', (route) => false);
  }

  //adding job vancy
  Future<bool> addVancyJob(AddVancyModel vancy, List<File> images) async {
    _isLoading = true;
    notifyListeners();
    print('START CALLING ADDING VANCY');
    print('DEBUG: AuthProvider.addVancyJob - Token present: ${_token != null}');
    print('DEBUG: AuthProvider.addVancyJob - Role: $_role');
    print('DEBUG: AuthProvider.addVancyJob - UserID: $_userId');
    print('DEBUG: AuthProvider.addVancyJob - EnterpriseID: ${_enterprise?.id}');
    print('DEBUG: AuthProvider.addVancyJob - Images count: ${images.length}');
    final response = await apiService.addVancy(vancy, images, _token);
    try {
      if (response != null) {
        print('added successfully');
        return true;
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateJobOffer(String id, AddVancyModel vancy) async {
    _isLoading = true;
    notifyListeners();
    print('START CALLING UPDATE JOB OFFER');

    final success = await apiService.updateJobOffer(id, vancy, _token);
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> sendCandidature(CandidateModel candidature) async {
    _isLoading = true;
    notifyListeners();
    print('STARTED CALLING');

    final response = await apiService.addCandidate(candidature, token);
    try {
      if (response != null) {
        print('added successfully');
        return true;
      }
    } catch (e) {
      print('Exception $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final StorageService storage = StorageService();

    _token = await storage.getToken() ?? prefs.getString('token');
    _role = prefs.getString('role');
    _userId = prefs.getString('user_id');

    final userData = prefs.getString('last_user_data');
    if (userData != null) {
      final userMap = jsonDecode(userData);

      if (_role == 'GIVER') {
        _enterprise = EnterpriseModel.fromJson(userMap);
      }
      _userData = userMap;

      print(
        'DEBUG: AuthProvider.loadAuthData - Loaded User keys: ${userMap.keys}',
      );

      // If _userId is still null after reading prefs, extract it from userData
      _userId ??=
          (userMap['_id'] ??
                  userMap['id'] ??
                  userMap['user_id'] ??
                  userMap['userId'])
              ?.toString();
    }

    notifyListeners();
  }

  String? getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'PENDING':
        return 'REVIEWED';
      case 'INTERVIEW':
        return 'accepted';
      default:
        return null; // accepted has no next step
    }
  }

  Future<bool> changeCandidatureStatus(
    String candidatureId,
    String currentStatus,
  ) async {
    print(
      "DEBUG: AuthProvider.changeCandidatureStatus - ID: $candidatureId, Status: $currentStatus",
    );

    if (_token == null) {
      print("DEBUG: Token is null, attempting to load from prefs...");
      await loadAuthData();
    }

    if (_token == null) {
      print("DEBUG: Token still null after loading. Cannot proceed.");
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.updateStatus(
        candidatureId,
        currentStatus,
        _token!,
      );

      print("DEBUG: API Response received: ${response != null}");

      _isLoading = false;
      notifyListeners();
      return response != null;
    } catch (e) {
      print("DEBUG: Exception in changeCandidatureStatus: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPropertiesForCompany(
    HouseModel addProperties,
    List<File> images,
  ) async {
    print('START CALLING ADD PROPERTIES');
    // For property creation, send only the FIRST image
    final initialImages = images.isNotEmpty ? [images.first] : <File>[];

    final response = await apiService.addProperties(
      addProperties,
      initialImages,
      token,
    );

    if (response != null) {
      print('Property created successfully with ID: ${response['id']}');

      // If there are more images, add them to the gallery via PATCH
      if (images.length > 1) {
        final remainingImages = images.sublist(1);
        print('Uploading ${remainingImages.length} additional images to gallery...');

        final galleryResponse = await apiService.updateGalleryImage(
          response['id'].toString(),
          remainingImages,
          token,
        );

        if (galleryResponse != null) {
          print('Gallery images added successfully');
        } else {
          print('WARNING: Failed to add some gallery images');
          // We still return true because the property was created
        }
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteProperty(String propertyId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await apiService.deleteProperty(propertyId, _token);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print("Error deleting property: $e");
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProperty(
    String propertyId,
    HouseModel property, {
    List<File>? newImages,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = property.toUpdateJson();
      final response = await apiService.updateProperty(
        propertyId,
        data,
        _token,
      );
      
      if (response != null && newImages != null && newImages.isNotEmpty) {
        print('DEBUG: Property updated, now updating gallery images...');
        final galleryResult = await apiService.updateGalleryImages(
          propertyId,
          newImages,
          _token,
        );
        if (!galleryResult) {
          print('WARNING: Gallery update failed');
          // We still consider the property update success, but maybe warn user?
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return response != null;
    } catch (e) {
      print("Error updating property: $e");
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  //send message part
  Future<bool> sendMessage(SendMessageModel message) async {
    _isLoading = true;
    notifyListeners();
    print('START CALLING SEND MESSAGE');

    final response = await apiService.sendMessage(message, token);
    try {
      if (response != null) {
        print('message sent successfully');
        return true;
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  List<SendMessageModel> _messageList = [];
  List<SendMessageModel> get messageList => _messageList;

  //display the conversation between two users
  Future<List<SendMessageModel>> getConversation(
    String senderId,
    String receiverId,
  ) async {
    print('START CALLING GET CONVERSATION');
    final response = await apiService.fetchMessagesBetweenUsers(
      senderId,
      receiverId,
      token,
    );
    _messageList = response;
    print('Conversation retrieved successfully');
    return response;
  }

  Future<List<SendMessageModel>> fetchMessageById(String messageId) async {
    print('START CALLING FETCH MESSAGE BY ID');
    final response = await apiService.fetchMessagesById(messageId, token);
    if (response != null) {
      print('Message retrieved successfully');
      return response;
    }
  }

  Future<bool> allConversation(String userId) async {
    final response = await apiService.allConversation(userId);
    if (response != null) {
      return true;
    }
    return false;
  }

  Future<bool> sendOtp(String email) async {
    _isLoading = true;
    _errorMessage = null; // Reset error message
    notifyListeners();
    try {
      final response = await apiService.sendOtpByMail(email);
      _isLoading = false;
      if (response != null && response['error'] == true) {
        _errorMessage = response['message']; // Capture error message from API
        notifyListeners();
        return false;
      }
      notifyListeners();
      return response != null; // Return true if response is not null and no error
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString(); // Capture exception message
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await apiService.verifyOtp(email, otp);
      _isLoading = false;
      notifyListeners();
      return response != null && response['error'] != true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String password,
    String confirmPassword,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await apiService.createNewPassword(
        email,
        password,
        confirmPassword,
      );
      _isLoading = false;
      notifyListeners();
      return response != null && response['error'] != true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
