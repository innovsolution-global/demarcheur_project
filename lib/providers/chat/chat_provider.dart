import 'package:demarcheur_app/models/presta/presta_model.dart';
import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:demarcheur_app/services/socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Conversation {
  final PrestaModel presta;
  String lastMessage;
  String timeLabel;
  int unreadCount;
  Conversation({
    required this.presta,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
  });
}

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  List<Conversation> _conversations = [];
  List<dynamic> _conversationsData = [];

  // Use a map to guarantee uniqueness by ID
  final Map<String, SendMessageModel> _messageMap = {};

  // Derived lists for UI
  List<SendMessageModel> _messages = [];
  List<types.Message> _chatMessages = [];

  // List of conversations for the message list page
  List<SendMessageModel> _conversationList = [];
  List<SendMessageModel> get conversations => _conversationList;

  String? _activeConversationId;
  bool _isLoading = false;

  bool get isloading => _isLoading;
  List<types.Message> get chatMessages => _chatMessages;

  ChatProvider() {
    print(
      'DEBUG: ChatProvider - Constructor called, setting up socket listener',
    );
    _loadMessagesFromCache();

    // Subscribe to socket messages
    _socketService.messageStream.listen((event) {
      try {
        print('DEBUG: ChatProvider - Received socket event: $event');

        if (event == null) {
          print('DEBUG: ChatProvider - Event is null, skipping');
          return;
        }

        final eventName = event['event'];
        final data = event['data'];

        print(
          'DEBUG: ChatProvider - Event name: $eventName, Data type: ${data.runtimeType}',
        );

        if (eventName == 'receive_message' && data is Map<String, dynamic>) {
          print('DEBUG: ChatProvider - Processing receive_message from socket');
          final message = SendMessageModel.fromJson(data);
          final msgId = message.id;

          if (msgId != null && msgId.isNotEmpty) {
            if (!_messageMap.containsKey(msgId)) {
              print(
                'DEBUG: ChatProvider - Adding NEW message from socket: $msgId',
              );
              _messageMap[msgId] = message;
              _saveMessagesToCache();
              _syncDerivedLists();
              notifyListeners();
            } else {
              print(
                'DEBUG: ChatProvider - Message already exists in map: $msgId',
              );
            }
          } else {
            print('DEBUG: ChatProvider - Message has no ID, skipping');
          }
        } else {
          print(
            'DEBUG: ChatProvider - Event not receive_message or data not Map (event: $eventName)',
          );
        }
      } catch (e, stackTrace) {
        print('DEBUG: ChatProvider - Error processing socket event: $e');
        print('DEBUG: ChatProvider - Stack trace: $stackTrace');
      }
    });
  }

  void clearMessages() {
    _messageMap.clear();
    _messages = [];
    _chatMessages = [];
    _conversationList = [];
    _activeConversationId = null;
    notifyListeners();
  }

  void _syncDerivedLists() {
    print('DEBUG: ChatProvider._syncDerivedLists - Map keys: ${_messageMap.keys.length}, ActiveConv: $_activeConversationId');
    _messages = _messageMap.values.where((m) {
      if (_activeConversationId == null) return true;
      final ids = [m.senderId.trim(), m.receiverId.trim()]..sort();
      final currentConvId = ids.join('_');
      final match = currentConvId == _activeConversationId;
      if (!match && _messageMap.length < 5) {
         print('DEBUG: ChatProvider._syncDerivedLists - Mismatch: msgConv=$currentConvId vs active=$_activeConversationId');
      }
      return match;
    }).toList();
    print('DEBUG: ChatProvider._syncDerivedLists - Filtered count: ${_messages.length}');

    // Map to types.Message and sort descending
    final mapped = _messages.map((m) => _mapToChatType(m)).toList();
    mapped.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    _chatMessages = mapped;
  }

  void setActiveConversation(String userId1, String userId2) {
    final ids = [userId1.trim(), userId2.trim()]..sort();
    final conversationId = ids.join('_');

    if (_activeConversationId != conversationId) {
      print(
        'DEBUG: ChatProvider - Switching active conversation to: $conversationId',
      );
      _activeConversationId = conversationId;
      // We don't necessarily clear _messageMap here to allow caching,
      // but we do need to refresh derived lists
      _messages = [];
      _chatMessages = [];
      _syncDerivedLists(); // Re-filter based on new ID
      notifyListeners();
    }
  }

  Future<void> fetchMessages(
    String userId,
    String otherUserId,
    String? token, {
    int page = 1,
    int limit = 30,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final uId = userId.trim();
      final oId = otherUserId.trim();

      print('DEBUG: ChatProvider - Fetching messages for $uId and $oId');
      final rawMessages = await _apiService.fetchMessagesBetweenUsers(
        uId,
        oId,
        token,
        page: page,
        limit: limit,
      );

      // Add to map (handling duplicates)
      for (final msg in rawMessages) {
        final id = msg.id;
        if (id != null && id.isNotEmpty) {
          _messageMap[id] = msg;
        }
      }

      // Ensure active conversation ID is set if we just fetched messages for a specific pair
      final ids = [uId, oId]..sort();
      final newConvId = ids.join('_');

      if (_activeConversationId != newConvId) {
        print(
          'DEBUG: ChatProvider - Updating active conversation ID to $newConvId',
        );
        _activeConversationId = newConvId;
      }

      _syncDerivedLists();
    } catch (e) {
      print('ChatProvider.fetchMessages error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendNewMessage(SendMessageModel message, String? token) async {
    // API Call
    final result = await _apiService.sendMessage(message, token);

    if (result != null) {
      final sentMsg = SendMessageModel.fromJson(result);
      final msgId = sentMsg.id;

      if (msgId != null && msgId.isNotEmpty) {
        if (!_messageMap.containsKey(msgId)) {
          print('DEBUG: ChatProvider - Adding message from API: $msgId');
          _messageMap[msgId] = sentMsg;
          _saveMessagesToCache();
          _syncDerivedLists();
          notifyListeners();
        }
      }
      return true;
    }
    return false;
  }

  types.Message _mapToChatType(SendMessageModel msg) {
    final authorId = msg.senderId.isNotEmpty ? msg.senderId : 'unknown';
    final timestamp =
        msg.timestamp?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;

    final msgId = msg.id ?? 'msg_${timestamp}_${msg.content.hashCode}';
    final author = types.User(id: authorId);

    // If we have attachment URLs, check if it's an image or other file
    if (msg.attachmentUrls != null && msg.attachmentUrls!.isNotEmpty) {
      final url = msg.attachmentUrls!.first; // For now handle first; UI can be improved for carousel
      final isImage = url.toLowerCase().contains('.jpg') || 
                      url.toLowerCase().contains('.jpeg') || 
                      url.toLowerCase().contains('.png') || 
                      url.toLowerCase().contains('.gif') ||
                      url.toLowerCase().contains('.webp');

      if (isImage) {
        return types.ImageMessage(
          author: author,
          createdAt: timestamp,
          id: msgId,
          name: url.split('/').last,
          size: 0,
          uri: url,
        );
      } else {
        return types.FileMessage(
          author: author,
          createdAt: timestamp,
          id: msgId,
          name: url.split('/').last,
          size: 0,
          uri: url,
        );
      }
    }

    return types.TextMessage(
      author: author,
      createdAt: timestamp,
      id: msgId,
      text: msg.content,
    );
  }

  void updateLastMessage(PrestaModel presta, String message, String timeLabel) {
    final idx = _conversations.indexWhere(
      (c) => c.presta.title == presta.title,
    );
    if (idx != -1) {
      _conversations[idx].lastMessage = message;
      _conversations[idx].timeLabel = timeLabel;
      notifyListeners();
    }
  }

  Future<void> fetchConversations(String userId, {String? token}) async {
    _isLoading = true;
    notifyListeners();
    try {
      print('DEBUG: ChatProvider.fetchConversations - Fetching for $userId');
      final parsedList = await _apiService.allConversation(userId, token: token);
      
      _conversationList = parsedList;
      print('DEBUG: ChatProvider.fetchConversations - Loaded ${_conversationList.length} conversations');
    } catch (e) {
      print('DEBUG: ChatProvider.fetchConversations error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveMessagesToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messageMap.values.map((m) {
        return {
          'id': m.id,
          'content': m.content,
          'senderId': m.senderId,
          'receiverId': m.receiverId,
          'userName': m.userName,
          'userPhoto': m.userPhoto,
          'attachmentUrls': m.attachmentUrls,
          'timestamp': m.timestamp?.toIso8601String(),
        };
      }).toList();

      await prefs.setString('cached_messages', jsonEncode(messagesJson));
      print(
        'DEBUG: ChatProvider - Saved ${messagesJson.length} messages to cache',
      );
    } catch (e) {
      print('DEBUG: ChatProvider - Error saving messages to cache: $e');
    }
  }

  Future<void> _loadMessagesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_messages');

      if (cachedData != null) {
        final List<dynamic> messagesJson = jsonDecode(cachedData);
        print(
          'DEBUG: ChatProvider - Loading ${messagesJson.length} messages from cache',
        );

        for (var msgData in messagesJson) {
          final message = SendMessageModel(
            id: msgData['id'],
            content: msgData['content'] ?? '',
            senderId: msgData['senderId'] ?? '',
            receiverId: msgData['receiverId'] ?? '',
            userName: msgData['userName'] ?? '',
            userPhoto: msgData['userPhoto'],
            attachmentUrls: msgData['attachmentUrls'] != null ? List<String>.from(msgData['attachmentUrls']) : null,
            timestamp: msgData['timestamp'] != null
                ? DateTime.tryParse(msgData['timestamp'])
                : null,
          );

          if (message.id != null && message.id!.isNotEmpty) {
            _messageMap[message.id!] = message;
          }
        }

        _syncDerivedLists();
        notifyListeners();
        print(
          'DEBUG: ChatProvider - Loaded ${_messageMap.length} messages from cache',
        );
      } else {
        print('DEBUG: ChatProvider - No cached messages found');
      }
    } catch (e) {
      print('DEBUG: ChatProvider - Error loading messages from cache: $e');
    }
  }
}
