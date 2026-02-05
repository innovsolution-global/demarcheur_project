import 'package:demarcheur_app/services/config.dart';
import 'package:image_picker/image_picker.dart';

class SendMessageModel {
  final String? id;
  final String userName;
  final String? userPhoto;
  final String content;
  final List<XFile>? attachments; // Local files being sent
  final List<String>? attachmentUrls; // Remote URLs from server
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

    // Comprehensive photo extraction
    final photo = Config.getImgUrl(
        (json['userPhoto'] ?? json['photo'] ?? json['avatar'] ?? json['profile'] ?? json['image'])?.toString() ??
        (json['user'] is Map
            ? (json['user']['image'] ??
                json['user']['photo'] ??
                json['user']['avatar'] ??
                json['user']['profile'])?.toString()
            : null));

    // Handle multiple images/files (fileUrl, image, attachments)
    List<String> urls = [];
    
    void addUrl(dynamic u) {
      if (u == null) return;
      final resolved = Config.getImgUrl(u.toString());
      if (resolved != null) urls.add(resolved);
    }
    
    // Check fileUrl
    if (json['fileUrl'] != null) {
      if (json['fileUrl'] is List) {
        for (var i in json['fileUrl']) addUrl(i);
      } else {
        addUrl(json['fileUrl']);
      }
    }
    
    // Check image
    if (json['image'] != null) {
      if (json['image'] is List) {
        for (var i in json['image']) {
          if (i is Map) {
            addUrl(i['path'] ?? i['url']);
          } else {
            addUrl(i);
          }
        }
      } else if (json['image'] is Map) {
        addUrl(json['image']['path'] ?? json['image']['url']);
      } else {
        addUrl(json['image']);
      }
    }

    // Comprehensive name extraction
    final name = json['userName'] ??
        json['name'] ??
        json['username'] ??
        (json['user'] is Map
            ? json['user']['name'] ?? json['user']['username']
            : '');

    // Comprehensive photo extraction
    final photo = Config.getImgUrl(
        (json['userPhoto'] ?? json['photo'] ?? json['avatar'] ?? json['profile'] ?? json['image'])?.toString() ??
        (json['user'] is Map
            ? (json['user']['image'] ??
                json['user']['photo'] ??
                json['user']['avatar'] ??
                json['user']['profile'])?.toString()
            : null));

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
