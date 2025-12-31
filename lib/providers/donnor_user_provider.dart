import 'dart:convert';
import 'package:demarcheur_app/models/donneur/donneur_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
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
      final userJson = prefs.getString('searcher_user_data');
      if (userJson != null) {
        try {
          final cachedUser = DonneurModel.fromJson(jsonDecode(userJson));
          if (cachedUser.phone != null) {
            _user = cachedUser;
            notifyListeners();
          }
        } catch (e) {
          print('Error parsing cached user: $e');
        }
      }

      final token = prefs.getString('token');
      if (token != null) {
        _token = token;
        final freshUser = await ApiService().searcherProfile(token);
        if (freshUser != null) {
          _user = freshUser;
          // Update cache
          await prefs.setString('searcher_user_data', jsonEncode(_user!.toJson()));
        }
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
