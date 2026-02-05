import 'dart:io';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/providers/chat/chat_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as ui;
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatefulWidget {
  final String pageType;
  final SendMessageModel message; // Context message (who we are talking to)

  const ChatWidget({super.key, required this.pageType, required this.message});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final colors = ConstColors();
  final Key _chatKey = UniqueKey();
  final List<XFile> _selectedAttachments = [];
  final TextEditingController _textController =
      TextEditingController(); // Added controller
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      chatProvider.setActiveConversation(
        widget.message.senderId,
        widget.message.receiverId,
      );

      final myId = authProvider.userId;
      if (myId == null) return;

      String otherId = widget.message.receiverId;
      if (otherId == myId || otherId.trim().isEmpty) {
        otherId = widget.message.senderId;
      }

      chatProvider.fetchMessages(myId, otherId, authProvider.token);
    });
  }

  Future<void> _handleAttachmentPressed() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPickerOption(
                icon: HugeIcons.strokeRoundedImage01,
                label: 'Galerie',
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile> picked = await ImagePicker()
                      .pickMultiImage();
                  if (picked.isNotEmpty) {
                    setState(() => _selectedAttachments.addAll(picked));
                  }
                },
              ),
              _buildPickerOption(
                icon: HugeIcons.strokeRoundedCamera01,
                label: 'Appareil Photo',
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? picked = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    setState(() => _selectedAttachments.add(picked));
                  }
                },
              ),
              _buildPickerOption(
                icon: HugeIcons.strokeRoundedAttachment,
                label: 'Document',
                onTap: () async {
                  Navigator.pop(context);
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(allowMultiple: true);
                  if (result != null) {
                    setState(() {
                      _selectedAttachments.addAll(
                        result.paths
                            .where((p) => p != null)
                            .map((p) => XFile(p!)),
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    } finally {
      setState(() => _isPicking = false);
    }
  }

  Widget _buildPickerOption({
    required List<List<dynamic>> icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: HugeIcon(icon: icon, color: colors.bg, size: 24),
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: colors.primary),
      ),
      onTap: onTap,
    );
  }

  // Modified to be called manually from custom input
  Future<void> _onSendTap() async {
    String text = _textController.text.trim();
    if (text.isEmpty && _selectedAttachments.isEmpty) return;

    // Use placeholder if text is empty but attachments exist
    if (text.isEmpty && _selectedAttachments.isNotEmpty) {
      text = "__FILE_ONLY__";
    }

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final myId = authProvider.userId;
    if (myId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
      );
      return;
    }

    String receiverId = widget.message.receiverId;
    if (widget.message.receiverId == myId) {
      receiverId = widget.message.senderId;
    }

    // Create a copy of attachments before clearing
    final attachmentsToSend = _selectedAttachments.isNotEmpty
        ? List<XFile>.from(_selectedAttachments)
        : null;

    final newMessage = SendMessageModel(
      content: text,
      senderId: myId,
      receiverId: receiverId,
      userName: authProvider.userName ?? 'Moi',
      userPhoto: authProvider.userPhoto,
      attachments: attachmentsToSend,
      timestamp: DateTime.now(),
    );

    // Clear UI state immediately
    _textController.clear();
    setState(() => _selectedAttachments.clear());

    final success = await chatProvider.sendNewMessage(
      newMessage,
      authProvider.token,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du message')),
      );
      // Optional: restore attachments if failed
      if (attachmentsToSend != null) {
        setState(() => _selectedAttachments.addAll(attachmentsToSend));
      }
    }
  }

  Widget _buildAttachmentPreview() {
    if (_selectedAttachments.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedAttachments.length,
        itemBuilder: (context, index) {
          final file = _selectedAttachments[index];
          final isImage =
              file.path.toLowerCase().contains('.jpg') ||
              file.path.toLowerCase().contains('.jpeg') ||
              file.path.toLowerCase().contains('.png');

          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isImage
                      ? Image.file(
                          File(file.path),
                          fit: BoxFit.cover,
                          width: 80,
                          height: 100,
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedFile01,
                              color: colors.primary,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedAttachments.removeAt(index)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Custom Input Bar to replace the default one
  Widget _buildCustomInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAttachmentPreview(), // Moving preview here above the input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.white,
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: _handleAttachmentPressed,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCamera01,
                    color: colors.primary,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: colors.primary),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Écrire un message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (val) {
                        setState(() {}); // Rebuild to toggle send icon
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed:
                      (_textController.text.trim().isNotEmpty ||
                          _selectedAttachments.isNotEmpty)
                      ? _onSendTap
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = types.User(id: authProvider.userId ?? 'user');
    final otherUserName = widget.message.userName;
    final otherUserPhoto = widget.message.userPhoto;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.primary,
        toolbarHeight: 70,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowTurnBackward,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage:
                  (otherUserPhoto != null && otherUserPhoto.isNotEmpty)
                  ? NetworkImage(otherUserPhoto)
                  : null,
              child: (otherUserPhoto == null || otherUserPhoto.isEmpty)
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.message.timestamp != null
                      ? DateFormat('HH:mm').format(widget.message.timestamp!)
                      : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isloading) {
            return Center(
              child: SpinKitPulse(color: colors.primary, size: 60.0),
            );
          }
          return ui.Chat(
            key: _chatKey,
            messages: chatProvider.chatMessages,
            onSendPressed: (_) {}, // Ignored since we use custom input
            onAttachmentPressed: _handleAttachmentPressed,
            user: user,
            customBottomWidget: _buildCustomInput(), // Use Custom Input
            emptyState: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedMessage01,
                    size: 60,
                    color: colors.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Aucune discussion",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Envoyez un message pour démarrer la conversation",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            ),
            imageMessageBuilder: (message, {required messageWidth}) {
              final isLocal = !message.uri.startsWith('http');
              if (isLocal) {
                return Image.file(File(message.uri), fit: BoxFit.cover);
              }
              return Image.network(
                message.uri,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              );
            },
            theme: ui.DefaultChatTheme(
              primaryColor: colors.primary,
              secondaryColor: Colors.grey.shade100,
              inputBackgroundColor: Colors.white,
              inputTextColor: Colors.black87,
              inputTextStyle: const TextStyle(fontSize: 16),
              inputPadding: const EdgeInsets.all(12),
              inputBorderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              sentMessageBodyTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              receivedMessageBodyTextStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
              backgroundColor: const Color(0xFFF5F7FB),
              dateDividerTextStyle: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            showUserAvatars: true,
            showUserNames: false,
          );
        },
      ),
    );
  }
}
