import 'package:demarcheur_app/models/presta/presta_model.dart';
import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:demarcheur_app/services/socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

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
  
  String? _activeConversationId;
  bool _isLoading = false;

  void clearMessages() {
    _messageMap.clear();
    _messages = [];
    _chatMessages = [];
    _activeConversationId = null;
    notifyListeners();
  }

  void _syncDerivedLists() {
    _messages = _messageMap.values.where((m) {
      if (_activeConversationId == null) return true;
      final ids = [m.senderId, m.receiverId]..sort();
      return ids.join('_') == _activeConversationId;
    }).toList();
    
    // Map to UI types and sort
    final mapped = _messages.map((m) => _mapToChatType(m)).toList();
    mapped.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    _chatMessages = mapped;
  }

  void setActiveConversation(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    final conversationId = ids.join('_');
    
    if (_activeConversationId != conversationId) {
      print('DEBUG: ChatProvider - Switching active conversation to: $conversationId');
      _activeConversationId = conversationId;
      _messageMap.clear();
      _messages = [];
      _chatMessages = [];
      notifyListeners();
    }
  }

  ChatProvider() {
    _listenToSocket();
  }

  void _listenToSocket() {
    _socketService.messageStream.listen((payload) {
      print('DEBUG: ChatProvider - RECEIVED SOCKET PAYLOAD: $payload');
      final data = payload['data'];

      // Attempt to parse as message if it looks like one
      try {
        if (data is Map<String, dynamic>) {
          final message = SendMessageModel.fromJson(data);
          final msgId = message.id;
          
          if (msgId != null && msgId.isNotEmpty) {
            if (!_messageMap.containsKey(msgId)) {
              print('DEBUG: ChatProvider - Adding message from socket: $msgId');
              _messageMap[msgId] = message;
              _syncDerivedLists();
              notifyListeners();
            }
          }
        }
      } catch (e) {
        print('DEBUG: ChatProvider - Error parsing socket data: $e');
      }
    });
  }

  void initSocket(String? token, String? userId) {
    if (token != null && userId != null) {
      _socketService.connect(token, userId);
    }
  }

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  List<dynamic> get conversationsData => List.unmodifiable(_conversationsData);
  List<SendMessageModel> get messages => List.unmodifiable(_messages);
  List<types.Message> get chatMessages => List.unmodifiable(_chatMessages);

  bool get isLoading => _isLoading;

  void seedFromJobs(List<PrestaModel> jobs) {
    if (_conversations.isNotEmpty) return;
    final samples = [
      "Bonjour, êtes-vous disponible cette semaine ?",
      "Merci pour votre retour.",
      "Pouvez-vous partager un devis ?",
      "Nous pouvons intervenir demain.",
      "Je vous appelle dans 10 minutes.",
    ];
    final times = ["09:41", "Hier", "09 Nov", "08 Nov", "07 Nov"];
    for (int i = 0; i < jobs.length; i++) {
      _conversations.add(
        Conversation(
          presta: jobs[i],
          lastMessage: samples[i % samples.length],
          timeLabel: i < times.length ? times[i] : "Récemment",
          unreadCount: i % 3 == 0 ? 2 : 0,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> fetchConversations(String? token, {String? userId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawData = await _apiService.fetchConversations(
        token,
        userId: userId,
      );
      
      // Normalize conversation data to ensure consistent structure
      _conversationsData = _normalizeConversations(rawData, userId);
      print('Fetched ${_conversationsData.length} conversations');
    } catch (e) {
      print('ChatProvider.fetchConversations error: $e');
      _conversationsData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Normalizes conversation data from API to ensure consistent structure
  /// that all message pages can use
  List<Map<String, dynamic>> _normalizeConversations(
    List<dynamic> rawData,
    String? currentUserId,
  ) {
    if (rawData.isEmpty) return [];

    final Map<String, Map<String, dynamic>> conversationsMap = {};

    for (var item in rawData) {
      if (item is! Map<String, dynamic>) continue;

      // Check if it's already a normalized conversation object
      if (item.containsKey('receiverId') && item.containsKey('receiverName')) {
        conversationsMap[item['receiverId']?.toString() ?? ''] = Map<String, dynamic>.from(item);
        continue;
      }

      // If it's a message, extract conversation info
      String? senderId = _extractId(item, ['senderId', 'sender_id', 'sender']);
      String? receiverId = _extractId(item, ['receiverId', 'receiver_id', 'receiver']);
      
      if (senderId == null || receiverId == null) continue;

      // Determine the "other" user in the conversation
      final String otherUserId;
      if (currentUserId != null) {
        otherUserId = senderId == currentUserId ? receiverId : senderId;
      } else {
        otherUserId = receiverId; // Default to receiver if no current user
      }

      // Get or create conversation entry
      if (!conversationsMap.containsKey(otherUserId)) {
        conversationsMap[otherUserId] = {
          'receiverId': otherUserId,
          'receiverName': _extractName(item, otherUserId == senderId ? 'sender' : 'receiver') ?? 'Utilisateur',
          'receiverImage': _extractImage(item, otherUserId == senderId ? 'sender' : 'receiver'),
          'senderId': senderId,
          'lastMessage': {
            'content': item['content'] ?? item['message'] ?? item['text'] ?? '',
            'timestamp': item['timestamp'] ?? item['createdAt'],
            'createdAt': item['createdAt'] ?? item['timestamp'],
          },
          'unreadCount': (item['isRead'] == false || item['read'] == false) ? 1 : 0,
        };
      } else {
        // Update with latest message if this one is newer
        final existing = conversationsMap[otherUserId]!;
        final existingTime = existing['lastMessage']?['createdAt'] ?? existing['lastMessage']?['timestamp'];
        final newTime = item['createdAt'] ?? item['timestamp'];
        
        if (_isNewer(newTime, existingTime)) {
          existing['lastMessage'] = {
            'content': item['content'] ?? item['message'] ?? item['text'] ?? '',
            'timestamp': item['timestamp'] ?? item['createdAt'],
            'createdAt': item['createdAt'] ?? item['timestamp'],
          };
          if (item['isRead'] == false || item['read'] == false) {
            existing['unreadCount'] = (existing['unreadCount'] as int? ?? 0) + 1;
          }
        }
      }
    }

    return conversationsMap.values.toList();
  }

  String? _extractId(dynamic item, List<String> keys) {
    if (item is! Map) return null;
    for (var key in keys) {
      final value = item[key];
      if (value == null) continue;
      if (value is String) return value;
      if (value is Map) {
        return value['id']?.toString() ?? value['_id']?.toString();
      }
    }
    return null;
  }

  String? _extractName(Map<String, dynamic> item, String type) {
    final userKey = type == 'sender' ? 'senderName' : 'receiverName';
    final userObj = item[type] ?? item[userKey];
    
    if (userObj is String) return userObj;
    if (userObj is Map) {
      return userObj['name']?.toString() ?? 
             userObj['userName']?.toString() ?? 
             userObj['companyName']?.toString();
    }
    return item[userKey]?.toString();
  }

  String? _extractImage(Map<String, dynamic> item, String type) {
    final userObj = item[type];
    if (userObj is Map) {
      return userObj['image']?.toString() ?? 
             userObj['imageUrl']?.toString() ?? 
             userObj['photo']?.toString();
    }
    return item['${type}Image']?.toString() ?? 
           item['${type}_image']?.toString();
  }

  bool _isNewer(dynamic newTime, dynamic existingTime) {
    if (newTime == null) return false;
    if (existingTime == null) return true;

    DateTime? newDate = _parseDateTime(newTime);
    DateTime? existingDate = _parseDateTime(existingTime);

    if (newDate == null) return false;
    if (existingDate == null) return true;

    return newDate.isAfter(existingDate);
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
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
      print('DEBUG: ChatProvider - Fetching messages for $userId and $otherUserId');
      final rawMessages = await _apiService.fetchMessagesBetweenUsers(
        userId,
        otherUserId,
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
      final ids = [userId, otherUserId]..sort();
      _activeConversationId = ids.join('_');
      
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

    // The ID MUST be stable and unique. If SendMessageModel has no ID,
    // we should have generated one before adding to the map.
    final msgId = msg.id ?? 'msg_${timestamp}_${msg.content.hashCode}';

    return types.TextMessage(
      author: types.User(id: authorId),
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
}
