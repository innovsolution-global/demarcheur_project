import 'dart:convert';
import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/models/donneur/donneur_model.dart';
import 'package:demarcheur_app/models/enterprise/enterprise_model.dart';
import 'package:demarcheur_app/models/services/service_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final apiService = ApiService();
  String? _token;
  String? get token => _token;
  String? _role;
  String? get role => _role;
  bool _isLoading = false;
  EnterpriseModel? _enterprise;
  EnterpriseModel? get enterprise => _enterprise;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? _service;
  Map<String, dynamic>? get service => _service;
  List<ServiceModel> _serviceList = [];
  List<ServiceModel> get serviceList => _serviceList;
  bool get isEnterprise => _role == 'GIVER' && _enterprise != null;

  //list of service

  void loadService() async {
    _isLoading = true;
    notifyListeners();
    _serviceList = await apiService.serviceList();
    print(_serviceList);
    _isLoading = false;
    notifyListeners();
  }

  //for adding service
  Future<bool> services(ServiceModel service) async {
    _isLoading = true;
    notifyListeners();
    try {
      print('START CALLING SERVICE');
      final response = await apiService.serviceRegister(service);
      if (response != null) {
        print('Added successfully ');

        return true;
      }
    } catch (e) {
      print('Exception occured');
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
      print('START CALLING REGISTRATION');
      final response = await apiService.registerGiver(enterprise);
      if (response != null) {
        print('Added successfully ');
        return true;
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> registerDonneur(DonneurModel donneur) async {
    _isLoading = true;
    notifyListeners();
    try {
      print('START CALLING REGISTRATION');
      final response = await apiService.donneurRegistration(donneur);
      if (response != null) {
        return true;
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> authentification(String item, String password) async {
    _isLoading = true;
    notifyListeners();
    print('START CALLING LOGIN');

    final response = await apiService.setLogin(item, password);

    if (response != null) {
      print('connected successfully');

      final prefs = await SharedPreferences.getInstance();

      // 1. Save token
      final token = response['token'];
      if (token != null) {
        _token = token;
        await prefs.setString('token', token);
      }

      // 2. Handle connected user
      if (response['user'] != null) {
        final userMap = response['user'];
        final role = userMap['role'];

        // ✅ Store enterprise in memory
        if (role == 'GIVER') {
          _enterprise = EnterpriseModel.fromJson(userMap);
        }

        // ✅ Persist user
        await prefs.setString('last_user_data', jsonEncode(userMap));

        await prefs.setString('role', role);

        _role = role;
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
    _token = null;
    _role = null;
    notifyListeners();

    // Navigate back to login
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  //adding job vancy
  Future<bool> addVancyJob(AddVancyModel vancy) async {
    _isLoading = true;
    notifyListeners();
    print('START CALLING ADDING VANCY');
    final response = await apiService.addVancy(vancy, _token);
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
}
