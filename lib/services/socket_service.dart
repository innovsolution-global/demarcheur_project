import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:demarcheur_app/services/config.dart';
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  final _messageController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get messageStream => _messageController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect(String? token, String? userId) {
    if (socket != null && _isConnected) {
      print('DEBUG: SocketService - Already connected, skipping.');
      return;
    }

    // Determine Socket URL (usually domain without /api/v1)
    final socketUrl = Config.baseUrl.replaceAll('/api/v1', '');
    print('DEBUG: SocketService - Connecting to $socketUrl');

    socket = IO.io(socketUrl, IO.OptionBuilder()
      .setTransports(['websocket', 'polling']) 
      .setAuth({'token': token})
      .setExtraHeaders({
        if (token != null) 'Authorization': 'Bearer $token',
      })
      .enableAutoConnect()
      .setTimeout(20000) // Increase timeout to 20s
      .build());

    print('DEBUG: SocketService - Initializing listeners');

    socket!.onConnect((_) {
      print('DEBUG: SocketService - CONNECTED EVENT');
      _isConnected = true;
      
      if (userId != null) {
        print('DEBUG: SocketService - EMITTING identity/join for user: $userId');
        socket!.emit('join', userId);
        socket!.emit('subscribe', userId);
        socket!.emit('identity', userId);
      }
    });

    socket!.on('ping', (_) => print('DEBUG: SocketService - PING received'));
    socket!.on('pong', (data) => print('DEBUG: SocketService - PONG received: $data'));

    socket!.onDisconnect((data) {
      print('DEBUG: SocketService - DISCONNECTED EVENT: $data');
      _isConnected = false;
    });

    socket!.onConnectError((data) {
      print('DEBUG: SocketService - Connect Error Detail: $data');
      // Try to re-fallback or log specifically
    });
    socket!.onError((data) => print('DEBUG: SocketService - Error Detail: $data'));

    // --- DISCOVERY / SNIFFING ---
    // Listen to common event names
    final commonEvents = [
      'message', 'newMessage', 'new_message', 
      'chat', 'chat_message', 'receive_message',
      'notification', 'private_message'
    ];

    for (var event in commonEvents) {
      socket!.on(event, (data) {
        print('DEBUG: SocketService - RECEIVED EVENT [$event]: $data');
        _messageController.add({'event': event, 'data': data});
      });
    }

    // Wildcard listener (if supported by the version)
    try {
      socket!.onAny((event, data) {
        // Suppress common internal events to reduce log noise
        final noisyEvents = ['connect', 'disconnect', 'error', 'connect_error'];
        if (noisyEvents.contains(event)) return;

        print('DEBUG: SocketService - SNIFFED ANY EVENT [$event]: $data');
        if (!commonEvents.contains(event)) {
          _messageController.add({'event': event, 'data': data});
        }
      });
    } catch (e) {
      print('DEBUG: SocketService - onAny not supported: $e');
    }
  }

  void sendMessage(String event, dynamic data) {
    if (socket != null && _isConnected) {
      print('DEBUG: SocketService - EMITTING [$event]: $data');
      socket!.emit(event, data);
    } else {
      print('DEBUG: SocketService - Cannot emit, socket not connected');
    }
  }

  void disconnect() {
    socket?.disconnect();
    _isConnected = false;
  }

  void dispose() {
    socket?.dispose();
    _messageController.close();
  }
}
