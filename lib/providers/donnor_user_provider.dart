import 'dart:convert';
import 'dart:io';
import 'package:demarcheur_app/models/donneur/donneur_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:demarcheur_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonnorUserProvider extends ChangeNotifier {
  DonneurModel? _user;
  bool _isLoading = false;
  String? _token;
  
  String? get token => _token;
  DonneurModel? get user => _user;
  bool get isLoading => _isLoading;

  // ------------------------------
  //  LOAD USER AT STARTUP
  // ------------------------------
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cached user from searcher_user_data first, then fallback to last_user_data
      String? userJson = prefs.getString('searcher_user_data');
      
      // Fallback to last_user_data if searcher_user_data doesn't exist
      userJson ??= prefs.getString('last_user_data');

      if (userJson != null) {
        try {
          final decoded = jsonDecode(userJson);
          if (decoded is Map<String, dynamic>) {
            final role = decoded['role']?.toString();
            if (role != 'GIVER') {
              _user = DonneurModel.fromJson(decoded);
              print(
                "DEBUG: DonnorUserProvider - Successfully loaded cached SEARCHER from ${prefs.getString('searcher_user_data') != null ? 'searcher_user_data' : 'last_user_data'}.",
              );
            } else {
              print(
                "WARNING: DonnorUserProvider - Found GIVER data in searcher key. Ignoring.",
              );
              _user = null;
            }
          }
          notifyListeners();
        } catch (e) {
          print('Error parsing cached searcher user: $e');
        }
      }

      final storage = StorageService();
      final tokenStr = await storage.getToken() ?? prefs.getString('token');
      if (tokenStr != null) {
        _token = tokenStr;
        
        final userRole = prefs.getString('user_role');
        print("DEBUG: DonnorUserProvider - User role: $userRole");
        
        if (userRole == 'SEARCHER') {
          print("DEBUG: DonnorUserProvider - Fetching SEARCHER profile...");
          // Try searcherProfile first (dedicated endpoint)
          final freshUser = await ApiService().searcherProfile(tokenStr);
          if (freshUser != null) {
            if (_user != null) {
              _user = _user!.mergeFrom(freshUser);
            } else {
              _user = freshUser;
            }
            final encodedUser = jsonEncode(_user!.toJson());
            await prefs.setString('searcher_user_data', encodedUser);
            // Also sync generic keys if needed
            await prefs.setString('last_user_data', encodedUser);
            if (_user?.id != null) await prefs.setString('userId', _user!.id!);
            debugPrint("DEBUG: DonnorUserProvider - Fresh profile merged for ${_user?.name}");
            notifyListeners();
          } else {
             // Fallback to getUserProfile by ID if dedicated fails
             final targetId = prefs.getString('userId') ?? _user?.id;
             if (targetId != null) {
                final fallbackUser = await ApiService().getUserProfile(targetId, tokenStr);
                if (fallbackUser != null) {
                  _user = fallbackUser;
                  await prefs.setString('searcher_user_data', jsonEncode(_user!.toJson()));
                  notifyListeners();
                }
             }
          }
        }
      }
    } catch (e) {
      print('Error in loadUser (DonnorUserProvider): $e');
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
    File? image,
  ) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Local update for immediate UI feedback
      final updatedUser = DonneurModel(
        id: _user!.id,
        name: name,
        email: _user!.email,
        phone: phone,
        adress: address,
        city: city,
        profile: _user!.profile, // placeholder, will refresh from API
      );

      final result = await ApiService().updateDonneurProfile(
        updatedUser,
        image,
      );

      if (result != null) {
        print("DEBUG: updateProfile (Donnor) - Success Body: $result");

        // Sync and Load fresh data
        await loadUser(); 

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error updating searcher profile: $e');
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

    _user = _user!.copyWith(isVerified: !_user!.isVerified);

    final prefs = await SharedPreferences.getInstance();
    final encodedUser = jsonEncode(_user!.toJson());
    await prefs.setString('searcher_user_data', encodedUser);
    await prefs.setString('last_user_data', encodedUser);
    
    _isLoading = false;
    notifyListeners();
  }
}
