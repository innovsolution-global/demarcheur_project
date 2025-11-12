import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isTyping = false;
  bool _isOnline = true;
  String _lastSeen = "En ligne";

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _loadInitialMessages();
    _simulateTyping();
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

  void _loadInitialMessages() {
    final initialMessages = [
      ChatMessage(
        id: '1',
        text:
            "Bonjour ! Je suis intéressé par votre propriété ${widget.presta.category}.",
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
        senderName: "Client Intéressé",
        messageType: MessageType.text,
      ),
      ChatMessage(
        id: '2',
        text:
            "Bonjour ! Merci pour votre intérêt. Je serais ravi de vous donner plus de détails.",
        isMe: true,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 2, minutes: -5),
        ),
        status: MessageStatus.read,
        senderName: widget.presta.companyName,
        messageType: MessageType.text,
      ),
      ChatMessage(
        id: '3',
        text:
            "Pouvez-vous me dire si la propriété est encore disponible ? Et quel est le prix final ?",
        isMe: false,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 30),
        ),
        status: MessageStatus.read,
        senderName: "Client Intéressé",
        messageType: MessageType.text,
      ),
      ChatMessage(
        id: '4',
        text:
            "Oui, elle est toujours disponible ! Le prix est de ${NumberFormat('#,###').format(widget.presta.rent).replaceAll(',', '.')} GNF par mois.",
        isMe: true,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 25),
        ),
        status: MessageStatus.delivered,
        senderName: widget.presta.companyName,
        messageType: MessageType.text,
      ),
      ChatMessage(
        id: '5',
        text: "Parfait ! Pourrions-nous organiser une visite cette semaine ?",
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: MessageStatus.sent,
        senderName: "Client Intéressé",
        messageType: MessageType.text,
      ),
    ];

    setState(() {
      _messages.addAll(initialMessages);
    });
  }

  void _simulateTyping() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && Random().nextBool()) {
        setState(() {
          _isTyping = !_isTyping;
        });

        if (_isTyping) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _isTyping = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage({
    String? text,
    File? image,
    MessageType type = MessageType.text,
  }) {
    if ((text == null || text.trim().isEmpty) && image == null) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text ?? '',
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      senderName: widget.presta.companyName,
      messageType: type,
      imageFile: image,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate message delivery
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) {
            _messages[index] = message.copyWith(status: MessageStatus.sent);
          }
        });
      }
    });

    // Simulate message delivery confirmation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) {
            _messages[index] = message.copyWith(
              status: MessageStatus.delivered,
            );
          }
        });
      }
    });

    HapticFeedback.lightImpact();
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        _sendMessage(
          text: '',
          image: File(image.path),
          type: MessageType.image,
        );
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection de l\'image');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _colors.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _colors.tertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Choisir une image",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _colors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageSourceButton(
                  icon: Icons.photo_library,
                  label: "Galerie",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _ImageSourceButton(
                  icon: Icons.camera_alt,
                  label: "Caméra",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
                  return _buildMessageBubble(_messages[index]);
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
                backgroundImage: NetworkImage(widget.presta.imageUrl.first),
                backgroundColor: Colors.grey[300],
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
                  _isTyping ? "En train d'écrire..." : _lastSeen,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.presta.imageUrl.first),
              backgroundColor: Colors.grey[300],
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
                color: message.isMe ? _colors.primary : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isMe ? 18 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 18),
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
                  if (message.messageType == MessageType.image &&
                      message.imageFile != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        message.imageFile!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (message.text.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: message.isMe ? Colors.white : _colors.secondary,
                        height: 1.3,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: message.isMe
                              ? Colors.white.withOpacity(0.7)
                              : _colors.tertiary,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        _buildMessageStatusIcon(message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: _colors.primary,
              child: Text(
                widget.presta.companyName[0].toUpperCase(),
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
            backgroundImage: NetworkImage(widget.presta.imageUrl.first),
            backgroundColor: Colors.grey[300],
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
              onPressed: _showImageSourceDialog,
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

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ConstColors();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MessageStatus { sending, sent, delivered, read }

enum MessageType { text, image, file, location }

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final MessageStatus status;
  final String senderName;
  final MessageType messageType;
  final File? imageFile;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.status,
    required this.senderName,
    required this.messageType,
    this.imageFile,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isMe,
    DateTime? timestamp,
    MessageStatus? status,
    String? senderName,
    MessageType? messageType,
    File? imageFile,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      senderName: senderName ?? this.senderName,
      messageType: messageType ?? this.messageType,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
