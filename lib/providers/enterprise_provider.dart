import 'dart:convert';
import 'dart:io';
import 'package:demarcheur_app/models/enterprise/enterprise_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnterpriseProvider extends ChangeNotifier {
  EnterpriseModel? _user;
  bool _isLoading = false;
  String? _token;

  EnterpriseModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get token => _token;

  // ------------------------------
  //  LOAD USER AT STARTUP
  // ------------------------------
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cached user ONLY from giver key
      String? userJson = prefs.getString('giver_user_data');
      if (userJson != null) {
        try {
          final decoded = jsonDecode(userJson);
          if (decoded is Map<String, dynamic> && decoded['role'] == 'GIVER') {
            _user = EnterpriseModel.fromJson(decoded);
            print("DEBUG: EnterpriseProvider - Successfully loaded cached GIVER.");
          }
          notifyListeners();
        } catch (e) {
          print('Error parsing cached giver user: $e');
        }
      }

      final tokenStr = prefs.getString('token');
      if (tokenStr != null) {
        _token = tokenStr;
        final userRole = prefs.getString('user_role');

        // This provider only fetches if user is a GIVER
        if (userRole == 'GIVER') {
          print("DEBUG: EnterpriseProvider - Fetching fresh GIVER profile...");
          final freshUser = await ApiService().giverProfile(tokenStr);
          if (freshUser != null) {
            if (_user != null) {
              _user = _user!.mergeFrom(freshUser);
            } else {
              _user = freshUser;
            }
            final encodedUser = jsonEncode(_user!.toJson());
            await prefs.setString('giver_user_data', encodedUser);
            // Sync with generic key for shared usage
            await prefs.setString('last_user_data', encodedUser);
            if (_user?.id != null) await prefs.setString('userId', _user!.id!);

            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error in loadUser (EnterpriseProvider): $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ------------------------------
  //  UPDATE PROFILE
  // ------------------------------
  Future<bool> updateProfile(
    String name,
    String? phone,
    String? address,
    String? city,
    File? image, // Optional image
  ) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Create a temporary updated model to send
      final updatedUser = _user!.copyWith(
        name: name,
        phone: phone,
        adress: address,
        city: city,
        image: image,
      );

      final result = await ApiService().updateEnterpriseProfile(
        updatedUser,
        image,
      );

      if (result != null) {
        print("DEBUG: updateProfile (EnterpriseProvider) - Success");

        // Sync and Load fresh data
        await loadUser();

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error updating giver profile: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ------------------------------
  //  TOGGLE ISVERIFIED (Mock/Placeholder)
  // ------------------------------
  Future<void> toggleIsVerified() async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));

    //_user = _user!.copyWith(isVerified: !_user!.isVerified);

    final prefs = await SharedPreferences.getInstance();
    final encodedUser = jsonEncode(_user!.toJson());
    await prefs.setString('giver_user_data', encodedUser);
    await prefs.setString('last_user_data', encodedUser);

    _isLoading = false;
    notifyListeners();
  }
}
