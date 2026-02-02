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
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
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
          color: colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: HugeIcon(icon: icon, color: colors.primary, size: 24),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final text = message.text.trim();
    if (text.isEmpty && _selectedAttachments.isEmpty) return;

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

    // Clear local selection immediately for better UX
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
          icon: const Icon(
            Icons.chevron_left_rounded,
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
            Expanded(
              child: Text(
                otherUserName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ui.Chat(
                  key: _chatKey,
                  messages: chatProvider.chatMessages,
                  onSendPressed: _handleSendPressed,
                  onAttachmentPressed: _handleAttachmentPressed,
                  user: user,
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
                  inputOptions: ui.InputOptions(
                    sendButtonVisibilityMode: _selectedAttachments.isNotEmpty
                        ? ui.SendButtonVisibilityMode.always
                        : ui.SendButtonVisibilityMode.editing,
                  ),
                );
              },
            ),
          ),
          _buildAttachmentPreview(),
        ],
      ),
    );
  }
}
