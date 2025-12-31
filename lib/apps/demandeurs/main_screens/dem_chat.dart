// chat_page.dart
import 'dart:async';
import 'dart:io';
import 'package:chat_plugin/chat_plugin.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/dem_job_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum MessageTypeLocal { text, image, file }

enum MessageStatus { sending, sent, delivered, read }

class DemChat extends StatefulWidget {
  final DemJobModel presta;
  const DemChat({super.key, required this.presta});

  @override
  State<DemChat> createState() => _DemChatState();
}

class _DemChatState extends State<DemChat> with WidgetsBindingObserver {
  final ConstColors _colors = ConstColors();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<dynamic> _messages = [];
  bool _isTyping = false;
  bool _isOnline = false;
  String _lastSeen = "Hors ligne";

  File? _selectedImage; // preview before send
  StreamSubscription? _messagesSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscribeToChatPlugin();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _statusSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- SUBSCRIPTIONS ----------
  void _subscribeToChatPlugin() {
    final chatService = ChatPlugin.chatService;
    try {
      final messagesStream =
          (chatService as dynamic).messagesStream as Stream<List<dynamic>>?;
      if (messagesStream != null) {
        _messagesSub = messagesStream.listen((rooms) {
          if (!mounted) return;
          setState(() {
            _messages = rooms;
          });
          _scrollToBottom();
        }, onError: (_) {});
      }
    } catch (_) {}

    try {
      final typingStream =
          (chatService as dynamic).typingStream as Stream<bool>?;
      if (typingStream != null) {
        _typingSub = typingStream.listen((isTyping) {
          if (!mounted) return;
          setState(() => _isTyping = isTyping);
        }, onError: (_) {});
      }
    } catch (_) {}

    try {
      final statusStream =
          (chatService as dynamic).userStatusStream as Stream<dynamic>?;
      if (statusStream != null) {
        _statusSub = statusStream.listen((status) {
          if (!mounted) return;
          setState(() {
            _isOnline = (status is Map && status['isOnline'] != null)
                ? status['isOnline'] as bool
                : false;
            _lastSeen = (status is Map && status['lastSeen'] != null)
                ? status['lastSeen'].toString()
                : "Hors ligne";
          });
        }, onError: (_) {});
      }
    } catch (_) {}
  }

  // ---------- SAFE PARSING HELPERS ----------
  MessageTypeLocal _safeMessageType(dynamic msg) {
    try {
      final dynamic raw = msg?.type;
      if (raw == null) return MessageTypeLocal.text;
      if (raw is MessageTypeLocal) return raw;
      if (raw is String) {
        final s = raw.toLowerCase();
        if (s.contains('image')) return MessageTypeLocal.image;
        if (s.contains('file')) return MessageTypeLocal.file;
      }
    } catch (_) {}
    return MessageTypeLocal.text;
  }

  dynamic _safeMessageFile(dynamic msg) {
    try {
      final dynamic f =
          msg?.file ??
          msg?.attachment ??
          msg?.payload ??
          msg?.imageUrl ??
          msg?.image;
      return f;
    } catch (_) {
      return null;
    }
  }

  String _safeMessageContent(dynamic msg) {
    try {
      final dynamic c = msg?.content ?? msg?.text ?? msg?.message;
      return c?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  bool _safeIsMe(dynamic msg) {
    try {
      final dynamic v = msg?.isMe ?? msg?.fromCurrentUser ?? msg?.mine;
      if (v is bool) return v;
    } catch (_) {}
    return false;
  }

  DateTime _safeTimestamp(dynamic msg) {
    try {
      final dynamic ts = msg?.timestamp ?? msg?.createdAt ?? msg?.sentAt;
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
    try {
      final s = status?.toString()?.toLowerCase() ?? 'sent';
      if (s.contains('sending')) return MessageStatus.sending;
      if (s.contains('delivered')) return MessageStatus.delivered;
      if (s.contains('read')) return MessageStatus.read;
      return MessageStatus.sent;
    } catch (_) {
      return MessageStatus.sent;
    }
  }

  // ---------- SCROLL ----------
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!_scrollController.hasClients) return;
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (_) {}
    });
  }

  // ---------- SENDING MESSAGE (robust) ----------
  Future<void> _sendMessage({
    String? text,
    File? image,
    MessageTypeLocal type = MessageTypeLocal.text,
  }) async {
    if ((text == null || text.trim().isEmpty) && image == null) return;

    final chatService = ChatPlugin.chatService;
    final String typeStr = type == MessageTypeLocal.image
        ? 'image'
        : (type == MessageTypeLocal.file ? 'file' : 'text');

    try {
      final dynamic s = chatService;

      // Try common signature: (String, {file, type})
      try {
        await s.sendMessage(text ?? '', file: image, type: typeStr);
      } catch (_) {
        // Try alternate parameter name 'attachmentName'
        try {
          await s.sendMessage(text ?? '', file: image, attachmentName: typeStr);
        } catch (_) {
          // Try minimal signature (positional)
          try {
            await s.sendMessage(text ?? '', image);
          } catch (_) {
            // Final fallback: positional text only
            await s.sendMessage(text ?? '');
          }
        }
      }

      // Clear input & preview
      if (mounted) {
        _messageController.clear();
        setState(() => _selectedImage = null);
      }

      HapticFeedback.lightImpact();
      _scrollToBottom();
    } catch (e) {
      debugPrint('sendMessage error: $e');
      if (mounted) _showSnackBar("Erreur lors de l'envoi du message");
    }
  }

  // ---------- IMAGE PICKER & PREVIEW ----------
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null) return;
      final file = File(picked.path);
      setState(() => _selectedImage = file);
      _showImagePreview(file);
    } catch (e) {
      debugPrint('pickImage error: $e');
      _showSnackBar("Impossible de sélectionner l'image");
    }
  }

  void _showImagePreview(File file) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    'Aperçu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _colors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(file, width: 320),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          setState(() => _selectedImage = null);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Annuler'),
                      ),
                      ElevatedButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _sendMessage(
                            image: file,
                            type: MessageTypeLocal.image,
                          );
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Envoyer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- IMAGE FULLSCREEN ZOOM ----------
  void _openFullImage(dynamic fileOrUrl) {
    final tag = fileOrUrl is File ? fileOrUrl.path : fileOrUrl.toString();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.black),
            body: Center(
              child: Hero(
                tag: tag,
                child: InteractiveViewer(
                  child: _buildImageWidget(fileOrUrl, fit: BoxFit.contain),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(
    dynamic fileOrUrl, {
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    if (fileOrUrl == null) return const SizedBox.shrink();
    try {
      if (fileOrUrl is File) {
        return Image.file(
          fileOrUrl,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      }
      final s = fileOrUrl.toString();
      if (s.startsWith('http') || s.startsWith('https')) {
        return Image.network(
          s,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      }
      // fallback try local file
      final f = File(s);
      if (f.existsSync())
        return Image.file(
          f,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
        );
    } catch (_) {}
    return const Icon(Icons.broken_image);
  }

  // ---------- UI Helpers ----------
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  // ---------- BUILD UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors.bg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessagesList()),
            if (_selectedImage != null) _buildSelectedImagePreview(),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final avatar = (widget.presta.imageUrl.isNotEmpty
        ? NetworkImage(widget.presta.imageUrl)
        : null);
    return AppBar(
      elevation: 0,
      backgroundColor: _colors.primary,
      titleSpacing: 0,
      leading: IconButton(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowTurnBackward,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: avatar,
            child: avatar == null ? Text(widget.presta.companyName[0]) : null,
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
                  ),
                ),
                Text(
                  _isTyping
                      ? 'En train d\'écrire...'
                      : (_isOnline ? 'En ligne' : _lastSeen),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showSnackBar('Video call non implémenté'),
          icon: const Icon(Icons.videocam),
        ),
        IconButton(
          onPressed: () => _showSnackBar('Voice call non implémenté'),
          icon: const Icon(Icons.call),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _messages.isEmpty
          ? Center(
              child: Text(
                'Aucune conversation',
                style: TextStyle(color: _colors.secondary),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isMe = _safeIsMe(msg);
                final type = _safeMessageType(msg);
                final content = _safeMessageContent(msg);
                final file = _safeMessageFile(msg);
                final ts = _formatTime(_safeTimestamp(msg));

                // Image message
                if (type == MessageTypeLocal.image && file != null) {
                  final tag = file is File ? file.path : file.toString();
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => _openFullImage(file),
                      child: Hero(
                        tag: tag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 180,
                            child: _buildImageWidget(
                              file,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Text message
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isMe) const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? _colors.primary : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  content,
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white
                                        : _colors.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ts,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (isMe)
                                    Icon(
                                      Icons.done_all,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isMe) const SizedBox(width: 6),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSelectedImagePreview() {
    final File file = _selectedImage!;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Image sélectionnée',
              style: TextStyle(color: _colors.secondary),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _selectedImage = null),
            icon: const Icon(Icons.close),
          ),
          ElevatedButton(
            onPressed: () =>
                _sendMessage(image: file, type: MessageTypeLocal.image),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: _colors.bg,
      child: Row(
        children: [
          // Attach (gallery / camera)
          PopupMenuButton<int>(
            icon: Icon(Icons.add_circle_outline, color: _colors.primary),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 1, child: Text('Galerie')),
              const PopupMenuItem(value: 2, child: Text('Caméra')),
            ],
            onSelected: (v) {
              if (v == 1) _pickImage(ImageSource.gallery);
              if (v == 2) _pickImage(ImageSource.camera);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Tapez un message...',
                        border: InputBorder.none,
                      ),
                      onChanged: (t) {
                        try {
                          ChatPlugin.chatService.sendTypingIndicator(
                            t.isNotEmpty,
                          );
                        } catch (_) {}
                      },
                      onSubmitted: (t) {
                        _sendMessage(
                          text: t.trim(),
                          type: MessageTypeLocal.text,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final t = _messageController.text.trim();
                      if (t.isNotEmpty)
                        _sendMessage(text: t, type: MessageTypeLocal.text);
                    },
                    icon: Icon(Icons.send, color: _colors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
