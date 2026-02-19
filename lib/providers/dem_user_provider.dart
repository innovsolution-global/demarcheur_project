import 'dart:convert';
import 'package:demarcheur_app/models/enterprise/enterprise_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dem_user_model.dart';

class DemUserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  DemUserModel? _user;
  bool _isLoading = false;

  DemUserModel? get user => _user;
  bool get isLoading => _isLoading;

  // ------------------------------
  //  SAVE USER TO SHAREDPREFERENCES
  // ------------------------------
  Future<void> saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      String jsonString = jsonEncode(_user!.toJson());
      await prefs.setString('demUser', jsonString);
    }
  }

  // ------------------------------
  //  LOAD USER (CACHE + API)
  // ------------------------------
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Try to load from cache first for immediate UI display
      // Check giver_user_data first (saved by AuthProvider for GIVER role)
      String? jsonString = prefs.getString('giver_user_data');

      // Fallback to last_user_data if giver_user_data doesn't exist
      jsonString ??= prefs.getString('last_user_data');

      if (jsonString != null) {
        try {
          final decoded = jsonDecode(jsonString);
          // Convert from login user data to DemUserModel
          _user = DemUserModel(
            id: (decoded['_id'] ?? decoded['id'] ?? decoded['userId'])
                ?.toString(),
            companyName: decoded['name'] ?? decoded['companyName'] ?? '',
            logo:
                Config.getImgUrl(
                  decoded['profile'] ?? decoded['logo'] ?? decoded['image'],
                ) ??
                '',
            domaine: decoded['specialite'] ?? decoded['domaine'] ?? '',
            rate: double.tryParse(decoded['rate']?.toString() ?? '0') ?? 0.0,
            email: decoded['email'] ?? '',
            phoneNumber: decoded['phone'] ?? decoded['phoneNumber'] ?? '',
            location:
                decoded['adress'] ??
                decoded['address'] ??
                decoded['city'] ??
                '',
            passWord: '',
            isVerified: decoded['isVerified'] ?? false,
          );
          debugPrint(
            'DEBUG DEM: Loaded user from cache (giver_user_data or last_user_data)',
          );
          notifyListeners();
        } catch (e) {
          print("Error decoding cached user data: $e");
        }
      }

      // 2. Fetch fresh data from API if role is GIVER
      final userRole = prefs.getString('role');
      final token = prefs.getString('token');

      if (userRole == 'GIVER' && token != null) {
        print("DEBUG: DemUserProvider - Fetching GIVER profile...");
        final EnterpriseModel? enterprise = await _apiService.giverProfile(
          token,
        );

        if (enterprise != null) {
          // Convert EnterpriseModel to DemUserModel
          final freshUser = DemUserModel(
            id: enterprise.id,
            companyName: enterprise.name,
            logo: enterprise.profile ?? '',
            domaine: enterprise.specialite ?? '',
            rate: enterprise.rate ?? 0.0,
            email: enterprise.email,
            phoneNumber: enterprise.phone ?? '',
            location: enterprise.adress ?? enterprise.city ?? '',
            passWord: '',
            isVerified: enterprise.isVerified,
          );

          // Merge with cached data to preserve fields that might be missing from API
          if (_user != null) {
            _user = DemUserModel(
              id: freshUser.id ?? _user!.id,
              companyName: freshUser.companyName.isNotEmpty
                  ? freshUser.companyName
                  : _user!.companyName,
              logo: freshUser.logo.isNotEmpty ? freshUser.logo : _user!.logo,
              domaine: freshUser.domaine.isNotEmpty
                  ? freshUser.domaine
                  : _user!.domaine,
              rate: freshUser.rate > 0 ? freshUser.rate : _user!.rate,
              email: freshUser.email.isNotEmpty
                  ? freshUser.email
                  : _user!.email,
              phoneNumber: freshUser.phoneNumber.isNotEmpty
                  ? freshUser.phoneNumber
                  : _user!.phoneNumber,
              location: freshUser.location.isNotEmpty
                  ? freshUser.location
                  : _user!.location,
              passWord: _user!.passWord,
              isVerified: freshUser.isVerified,
            );
            debugPrint('DEBUG DEM: Merged fresh profile with cached data');
            debugPrint(
              'DEBUG DEM: Final phone: ${_user!.phoneNumber}, location: ${_user!.location}',
            );
          } else {
            _user = freshUser;
            debugPrint('DEBUG DEM: Using fresh profile (no cache)');
          }

          await saveUser();
        }
      }
    } catch (e) {
      print('Error in loadUser (DemUserProvider): $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------
  //  MOCK LOAD (For Testing)
  // ------------------------------
  Future<void> loadMockUser() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    await saveUser();
    _isLoading = false;
    notifyListeners();
  }

  // ------------------------------
  //  TOGGLE ISVERIFIED
  // ------------------------------
  Future<void> toggleIsVerified() async {
    if (_user == null) return;
    _user = _user!.copyWith(isVerified: !_user!.isVerified);
    await saveUser();
    notifyListeners();
  }
}
