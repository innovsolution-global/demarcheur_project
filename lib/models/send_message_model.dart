import 'package:image_picker/image_picker.dart';

class SendMessageModel {
  final String? id;
  final String userName;
  final String? userPhoto;
  final String content;
  final List<XFile>? attachments;
  final List<String>? attachmentUrls;
  final String senderId;
  final String receiverId;
  final DateTime? timestamp;

  SendMessageModel({
    this.id,
    required this.content,
    this.attachments,
    this.attachmentUrls,
    required this.senderId,
    required this.receiverId,
    required this.userName,
    this.userPhoto,
    this.timestamp,
  });

  factory SendMessageModel.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic obj, List<String> keys) {
      if (obj == null) return '';
      if (obj is String) return obj.trim();
      if (obj is Map) {
        for (var k in keys) {
          if (obj[k] != null) return obj[k].toString().trim();
        }
      }
      return '';
    }

    // Handle nested contact/lastMessage structure (Conversation Summary)
    if (json['contact'] != null) {
      final contact = json['contact'];
      final lastMsg = json['lastMessage'] ?? {};
      final partnerId = extractId(contact, ['id', '_id']) ?? '';
      
      return SendMessageModel(
        id: lastMsg['id']?.toString() ?? partnerId,
        content: lastMsg['content'] ?? lastMsg['message'] ?? '',
        senderId: lastMsg['isMe'] == true ? '' : partnerId, 
        receiverId: lastMsg['isMe'] == true ? partnerId : '',
        userName: contact['name'] ?? contact['username'] ?? '',
        userPhoto: contact['avatar'] ?? contact['image'] ?? contact['photo'],
        timestamp: lastMsg['createdAt'] != null 
            ? DateTime.tryParse(lastMsg['createdAt']) 
            : null,
      );
    }

    // Try multiple keys for sender/receiver ID
    final sId = extractId(
      json['senderId'] ?? json['sender_id'] ?? json['sender'] ?? json['from'],
      ['id', '_id', 'userId'],
    );
    final rId = extractId(
      json['receiverId'] ?? json['receiver_id'] ?? json['receiver'] ?? json['to'],
      ['id', '_id', 'userId'],
    );

    final msgId = json['id']?.toString() ?? json['_id']?.toString() ?? '';

    // Handle multiple images/files
    List<String> urls = [];
    if (json['image'] != null) {
      if (json['image'] is String) {
        urls.add(json['image']);
      } else if (json['image'] is List) {
        urls.addAll(List<String>.from(json['image'].map((i) => i is Map ? (i['path'] ?? i['url']) : i.toString())));
      } else if (json['image'] is Map) {
        urls.add(json['image']['path'] ?? json['image']['url']);
      }
    }
    
    if (json['attachments'] != null && json['attachments'] is List) {
       urls.addAll(List<String>.from(json['attachments'].map((a) => a is Map ? (a['path'] ?? a['url']) : a.toString())));
    }

    // Comprehensive name extraction
    final name = json['userName'] ??
        json['name'] ??
        json['username'] ??
        (json['user'] is Map
            ? json['user']['name'] ?? json['user']['username']
            : '');

    // Comprehensive photo extraction
    final photo =
        (urls.isNotEmpty ? urls.first : null) ??
        (json['user'] is Map
            ? json['user']['image'] ??
                json['user']['photo'] ??
                json['user']['avatar']
            : null);

    return SendMessageModel(
      id: msgId.isNotEmpty ? msgId : null,
      content: json['content'] ?? json['message'] ?? json['text'] ?? '',
      senderId: sId,
      receiverId: rId,
      userName: name.toString(),
      userPhoto: photo,
      attachmentUrls: urls.isNotEmpty ? urls : null,
      timestamp:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : (json['timestamp'] != null
                  ? DateTime.tryParse(json['timestamp'])
                  : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'senderId': senderId,
      'receiverId': receiverId,
    };
  }
}
