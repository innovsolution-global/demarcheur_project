import 'dart:convert';
import 'package:demarcheur_app/models/enterprise/enterprise_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnterpriseProvider extends ChangeNotifier {
  EnterpriseModel? _user;
  bool _isLoading = false;
  String? _token;
  String? get token => _token;
  EnterpriseModel? get user => _user;
  bool get isLoading => _isLoading;

  // ------------------------------
  //  SAVE USER TO SHAREDPREFERENCES
  // ------------------------------
  // Future<void> saveUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (_user != null) {
  //     String jsonString = jsonEncode(_user!.toJson());
  //     await prefs.setString('demUser', jsonString);
  //   }
  // }

  // ------------------------------
  //  LOAD USER AT STARTUP
  // ------------------------------
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cached user first
      final userJson = prefs.getString('giver_user_data');
      if (userJson != null) {
        print("DEBUG: EnterpriseProvider - Cached JSON mapping from: $userJson");
        try {
          final cachedUser = EnterpriseModel.fromJson(jsonDecode(userJson));
          _user = cachedUser;
          print("DEBUG: EnterpriseProvider - ID from cache: ${_user?.id}");
          notifyListeners();
        } catch (e) {
          print('Error parsing cached user: $e');
        }
      }

      final token = prefs.getString('token');
      if (token != null) {
        _token = token;
        print("DEBUG: EnterpriseProvider - Fetching fresh profile from /auth/profile-giver...");
        final freshUser = await ApiService().giverProfile(token);
        if (freshUser != null) {
          print("DEBUG: EnterpriseProvider - freshUser DETAILS: ID=${freshUser.id}, Name=${freshUser.name}");
          
          // CRITICAL: Merge data to avoid overwriting good login/cache data with nulls from profile endpoint
          if (_user != null) {
            _user = _user!.mergeFrom(freshUser);
            print("DEBUG: EnterpriseProvider - ID after merge: ${_user?.id}");
          } else {
            _user = freshUser;
          }
          
          // Update cache
          final updatedJson = jsonEncode(_user!.toJson());
          print("DEBUG: EnterpriseProvider - Final merged user saved to cache: $updatedJson");
          await prefs.setString('giver_user_data', updatedJson);
          notifyListeners();
        } else {
          print("DEBUG: EnterpriseProvider - freshUser is NULL from ApiService");
        }
      } else {
        print("DEBUG: EnterpriseProvider - No token found in SharedPreferences");
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  // ------------------------------
  //  MOCK LOAD (API IN FUTURE)
  //final response = await http.get(Uri.parse("$baseUrl/user/profile"));
  //_user = DonnorUserModel.fromJson(jsonDecode(response.body));

  // ------------------------------
  Future<void> loadMockUser() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // _user = DonnorUserModel(
    //   id: '111',
    //   companyName: 'CodeHub',
    //   logo:
    //       "https://i.pinimg.com/474x/2d/d5/2b/2dd52b8c1b437036609e307767cb9206.jpg",
    //   domaine: 'Web development',
    //   rate: 2.1,
    //   email: 'codehub@gmail.com',
    //   phoneNumber: '22222222222',
    //   location: 'Sonfonia',
    //   passWord: 'code123',
    //   isVerified: false,
    // );

    //await saveUser();

    _isLoading = false;
    notifyListeners();
  }

  // ------------------------------
  //  TOGGLE ISVERIFIED + SAVE
  // ------------------------------
  Future<void> toggleIsVerified() async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));

    // _user = _user!.copyWith(isVerified: !_user!.isVerified);

    //await saveUser();

    _isLoading = false;
    notifyListeners();
  }
}
