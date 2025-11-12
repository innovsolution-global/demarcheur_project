import 'dart:convert';
import 'package:chat_plugin/chat_plugin.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.url}/api"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['userId'] != null) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString("userId", data["userId"]);
          await pref.setString("token", data["token"]);

          //CHAT PLUGIN
          await initilizedChatPlugin();
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
        Uri.parse("${Config.url}/api"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['userId'] != null) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString("userId", data["userId"]);
          await pref.setString("token", data["token"]);

          //CHAT PLUGIN
          await initilizedChatPlugin();
          await Future.delayed(Duration(milliseconds: 500));
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
    try {
      if (ChatConfig.instance.userId != null) {
        ChatPlugin.chatService.fullDisconnect();
      }
    } catch (ex) {}
    await pref.remove("userId");
    await pref.remove("token");
    await pref.clear();

    Navigator.of(context).pushNamed("onloading");
  }

  static Future<void> initilizedChatPlugin() async {
    final userId = await AuthService.getUser();
    final token = await AuthService.getUserToken();

    await ChatPlugin.initialize(
      config: ChatConfig(
        apiUrl: Config.url,
        userId: userId,
        token: token,
        enableOnlineStatus: true,
        enableReadReceipts: true,
        enableTypingIndicators: true,
        autoMarkAsRead: true,
        maxReconnectionAttempts: 5,
        debugMode: true,
      ),
    );
    await setupChatApiHandler(userId!, token!);
    await ChatPlugin.chatService.initialize();
    await ChatPlugin.chatService.loadChatRooms();
  }

  static Future<void> setupChatApiHandler(String userId, String token) async {
    final apiHandler = ChatApiHandlers(
      loadMessagesHandler: ({limit = 20, page = 1, searchText = ""}) async {
        final receiverId = ChatPlugin.chatService.receiverId;
        if (receiverId.isEmpty) return [];
        try {
          var url =
              "${Config.url}/api/chat/messages?currentUserId=$userId&receiverId=$receiverId&page=$page&limit=$limit";
          if (searchText.isNotEmpty) {
            url += "&searchText=${Uri.encodeComponent(searchText)}";
          }
          final response = await http.get(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $token",
              "Content=Type": "application/json",
            },
          );
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            return data.map((msg) => ChatMessage.fromMap(msg, userId)).toList();
          }
          return [];
        } catch (ex) {
          return [];
        }
      },
      loadChatRoomsHandler: () async {
        try {
          var url = "${Config.url}/api/chat/chat-room";

          final response = await http.get(
            Uri.parse(url),
            headers: {
              "Authorization": "Bearer $token",
              "Content=Type": "application/json",
            },
          );
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            return data.map((room) => ChatRoom.fromMap(room)).toList();
          }
          return [];
        } catch (ex) {
          return [];
        }
      },
    );
    ChatPlugin.chatService.setApiHandlers(apiHandler);
  }

  Future<List<dynamic>> fetchUser() async {
    var getUser = getUserToken();
    try {
      final response = await http.get(
        Uri.parse("${Config.url}/api/user/users"),
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
