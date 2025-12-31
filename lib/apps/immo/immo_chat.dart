import 'dart:async';
import 'dart:io';
import 'package:chat_plugin/chat_plugin.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum MessageStatus { sending, sent, delivered, read }

enum MessageType { text, image, file }

class ImmoChat extends StatefulWidget {
  final HouseModel presta;
  const ImmoChat({super.key, required this.presta});

  @override
  State<ImmoChat> createState() => _ImmoChatState();
}

class _ImmoChatState extends State<ImmoChat>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ConstColors _colors = ConstColors();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isTyping = false;
  bool _isOnline = false;
  String _lastSeen = "Hors ligne";

  final List<dynamic> _messages = [];
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _statusSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _initializeChat();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _initializeChat() async {
    if (widget.presta.id == null) return;

    final chatService = ChatPlugin.chatService;

    // Set the receiver
    try {
      chatService.setReceiverId(widget.presta.id!);
    } catch (_) {
      // ignore if setReceiverId not implemented
    }

    // Load initial messages
    try {
      await chatService.loadMessages();
    } catch (_) {}

    // Subscribe to streams
    try {
      final messagesStream =
          (chatService as dynamic).messagesStream as Stream<List<ChatMessage>>?;
      if (messagesStream != null) {
        _messageSubscription = messagesStream.listen((messages) {
          if (mounted) {
            setState(() {
              _messages.clear();
              _messages.addAll(messages);
            });
            _scrollToBottom();
          }
        });
      }
    } catch (_) {
      // messagesStream not available on this ChatService implementation; ignore.
    }

    try {
      final typingStream =
          (chatService as dynamic).typingStream as Stream<bool>?;
      if (typingStream != null) {
        _typingSubscription = typingStream.listen((isTyping) {
          if (mounted) {
            setState(() {
              _isTyping = isTyping;
            });
          }
        });
      }
    } catch (_) {
      // typingStream not available on this ChatService implementation; ignore.
    }

    try {
      final statusStream =
          (chatService as dynamic).userStatusStream as Stream<dynamic>?;
      if (statusStream != null) {
        _statusSubscription = statusStream.listen((status) {
          if (mounted) {
            setState(() {
              _isOnline = (status is Map && status['isOnline'] != null)
                  ? status['isOnline'] as bool
                  : false;
              _lastSeen = (status is Map && status['lastSeen'] != null)
                  ? status['lastSeen'].toString()
                  : "Hors ligne";
            });
          }
        });
      }
    } catch (_) {
      // userStatusStream not available on this ChatService implementation; ignore.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _statusSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage({
    String? text,
    File? image,
    MessageType type = MessageType.text,
  }) async {
    if ((text == null || text.trim().isEmpty) && image == null) return;

    final chatService = ChatPlugin.chatService;

    try {
      await chatService.sendMessage(
        text ?? '',
        attachmentName: type
            .toString()
            .split('.')
            .last, // convert enum to string: 'text' or 'image'
        //file: image,
      );

      _messageController.clear();
      _scrollToBottom();
      HapticFeedback.lightImpact();
    } catch (e) {
      _showSnackBar('Erreur lors de l\'envoi du message');
    }
  }

  void _onTypingChanged(String text) {
    try {
      ChatPlugin.chatService.sendTypingIndicator(text.isNotEmpty);
    } catch (_) {}
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- Helpers for safe message handling ---

  /// Safely get message type from dynamic message objects.
  /// Handles enum `MessageType` or plugin returning a String like "image" / "text".
  MessageType? _safeMessageType(dynamic msg) {
    try {
      final t = msg?.type;
      if (t is MessageType) return t;
      if (t is String) {
        switch (t.toLowerCase()) {
          case 'image':
            return MessageType.image;
          case 'text':
            return MessageType.text;
          default:
            return null;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Safely get a file/object attached to the message.
  dynamic _safeMessageFile(dynamic msg) {
    try {
      return msg?.file;
    } catch (_) {
      return null;
    }
  }

  ImageProvider? _safeNetworkImage(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    try {
      return NetworkImage(trimmed);
    } catch (_) {
      return null;
    }
  }

  Widget _imageFromDynamic(
    dynamic file, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    // file may be: File, String (url or path), Uri, or already an ImageProvider
    if (file == null) return const SizedBox.shrink();

    if (file is ImageProvider) {
      return Image(image: file, width: width, height: height, fit: fit);
    }
    if (file is File) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          );
        },
      );
    }
    if (file is String) {
      final trimmed = file.trim();
      // If it's a valid URL (basic check)
      if (trimmed.startsWith('http') || trimmed.startsWith('https')) {
        return Image.network(
          trimmed,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image),
            );
          },
        );
      } else {
        // try as local file path
        try {
          final f = File(trimmed);
          if (f.existsSync()) {
            return Image.file(
              f,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                );
              },
            );
          }
        } catch (_) {}
        // fallback to an empty container
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        );
      }
    }
    if (file is Uri) {
      final s = file.toString();
      return Image.network(
        s,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          );
        },
      );
    }

    // unknown type
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors.bg,
      appBar: _buildModernAppBar(),
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  final msg = _messages[index];
                  // protect against invalid list entries
                  if (msg == null) return const SizedBox.shrink();
                  return _buildMessageBubble(msg);
                },
              ),
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    final avatarProvider = widget.presta.imageUrl.isNotEmpty
        ? _safeNetworkImage(widget.presta.imageUrl.first)
        : null;

    return AppBar(
      elevation: 0,
      backgroundColor: _colors.primary,
      foregroundColor: Colors.white,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: avatarProvider,
                backgroundColor: Colors.grey[300],
                child: avatarProvider == null
                    ? (widget.presta.companyName.isNotEmpty
                          ? Text(widget.presta.companyName[0])
                          : const SizedBox.shrink())
                    : null,
              ),
              if (_isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.presta.companyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isTyping
                      ? "En train d'écrire..."
                      : (_isOnline ? "En ligne" : _lastSeen),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showSnackBar('Appel vidéo bientôt disponible'),
          icon: const Icon(Icons.videocam, color: Colors.white),
        ),
        IconButton(
          onPressed: () => _showSnackBar('Appel vocal bientôt disponible'),
          icon: const Icon(Icons.call, color: Colors.white),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'info':
                _showSnackBar('Informations sur la propriété');
                break;
              case 'block':
                _showSnackBar('Utilisateur bloqué');
                break;
              case 'report':
                _showSnackBar('Signalement envoyé');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Informations'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block),
                  SizedBox(width: 8),
                  Text('Bloquer'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report),
                  SizedBox(width: 8),
                  Text('Signaler'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // use safe helpers to avoid crashes if plugin changes shape
    final msgType = _safeMessageType(message);
    final msgFile = _safeMessageFile(message);

    final isMe = (message as dynamic).isMe ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.presta.imageUrl.isNotEmpty
                  ? _safeNetworkImage(widget.presta.imageUrl.first)
                  : null,
              backgroundColor: Colors.grey[300],
              child: widget.presta.imageUrl.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? _colors.primary : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image handling: support File, String (URL/path), ImageProvider
                  if (msgType == MessageType.image && msgFile != null) ...[
                    _imageFromDynamic(msgFile, width: 200, height: 200),
                    if (((message as dynamic).content?.isNotEmpty) ?? false)
                      const SizedBox(height: 8),
                  ],
                  if ((message as dynamic).content?.isNotEmpty ?? false)
                    Text(
                      (message as dynamic).content ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.white : _colors.secondary,
                        height: 1.3,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat(
                          'HH:mm',
                        ).format(_getMessageTimestamp(message)),
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : _colors.tertiary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildMessageStatusIcon(
                          _parseMessageStatus(
                            (message as dynamic).status ?? 'sent',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: _colors.primary,
              child: Text(
                "M", // Placeholder for "Me" or user initial
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  DateTime _getMessageTimestamp(ChatMessage message) {
    try {
      final dynamic ts =
          (message as dynamic).timestamp ??
          (message as dynamic).createdAt ??
          (message as dynamic).sentAt;
      if (ts == null) return DateTime.now();
      if (ts is DateTime) return ts;
      if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
      if (ts is String) {
        final parsed = DateTime.tryParse(ts);
        if (parsed != null) return parsed;
        final ms = int.tryParse(ts);
        if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    } catch (_) {}
    return DateTime.now();
  }

  MessageStatus _parseMessageStatus(dynamic status) {
    final statusStr = status?.toString() ?? 'sent';
    switch (statusStr.toLowerCase()) {
      case 'sending':
      case 'messagestatus.sending':
        return MessageStatus.sending;
      case 'sent':
      case 'messagestatus.sent':
        return MessageStatus.sent;
      case 'delivered':
      case 'messagestatus.delivered':
        return MessageStatus.delivered;
      case 'read':
      case 'messagestatus.read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.white.withOpacity(0.5);
        break;
      case MessageStatus.sent:
        icon = Icons.done;
        color = Colors.white.withOpacity(0.7);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white.withOpacity(0.7);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: widget.presta.imageUrl.isNotEmpty
                ? _safeNetworkImage(widget.presta.imageUrl.first)
                : null,
            backgroundColor: Colors.grey[300],
            child: widget.presta.imageUrl.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _colors.tertiary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _colors.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => _showSnackBar(
                'Image sending not implemented yet',
              ), // Placeholder for image sending
              icon: Icon(Icons.attach_file, color: _colors.primary),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Tapez votre message...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (t) {
                    _onTypingChanged(t);
                    setState(() {}); // to update clear button if any in future
                  },
                  onSubmitted: (text) => _sendMessage(text: text),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _colors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => _sendMessage(text: _messageController.text),
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
