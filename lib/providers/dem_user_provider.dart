import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dem_user_model.dart';

class DemUserProvider extends ChangeNotifier {
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
  //  LOAD USER AT STARTUP
  // ------------------------------
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('demUser');

    if (jsonString != null) {
      final decoded = jsonDecode(jsonString);
      _user = DemUserModel.fromJson(decoded);
      notifyListeners();
    }
  }

  // ------------------------------
  //  MOCK LOAD (API IN FUTURE)
  //final response = await http.get(Uri.parse("$baseUrl/user/profile"));
  //_user = DemUserModel.fromJson(jsonDecode(response.body));

  // ------------------------------
  Future<void> loadMockUser() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _user = DemUserModel(
      id: '111',
      companyName: 'CodeHub',
      logo:
          "https://i.pinimg.com/474x/2d/d5/2b/2dd52b8c1b437036609e307767cb9206.jpg",
      domaine: 'Web development',
      rate: 2.1,
      email: 'codehub@gmail.com',
      phoneNumber: '22222222222',
      location: 'Sonfonia',
      passWord: 'code123',
      isVerified: false,
    );

    await saveUser();

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

    _user = _user!.copyWith(isVerified: !_user!.isVerified);

    await saveUser();

    _isLoading = false;
    notifyListeners();
  }
}
