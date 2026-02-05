import 'dart:convert';
import 'package:demarcheur_app/services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = Config.baseUrl;
  Future<bool> loginUser(String item, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'item': item, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['userId'] != null) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString("userId", data["userId"]);
          await pref.setString("token", data["token"]);

          //CHAT PLUGIN
         // await initilizedChatPlugin();
          await Future.delayed(Duration(milliseconds: 500));
          return true;
        }
      }
      return false;
    } catch (ex) {
      return false;
    }
  }

  Future<bool> registerUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['userId'] != null) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString("userId", data["userId"]);
          await pref.setString("token", data["token"]);
          return true;
        }
      }
      return false;
    } catch (ex) {
      return false;
    }
  }

  static Future<String?> getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("userId");
  }

  static Future<bool?> logedUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("userId") != null ? true : false;
  }

  static Future<String?> getUserToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("token");
  }

  static Future<void> logout(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove("userId");
    await pref.remove("token");
    await pref.clear();

    Navigator.of(context).pushNamedAndRemoveUntil("/intro_onboarding", (route) => false);
  }


  Future<List<dynamic>> fetchUser() async {
    var getUser = getUserToken();
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/api/user/users"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'BEARER $getUser',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return [];
    } catch (ex) {
      return [];
    }
  }
}
