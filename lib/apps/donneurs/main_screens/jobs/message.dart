import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/providers/chat/chat_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Load conversations from API via ChatProvider (real data)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(
        context,
        listen: false,
      ); // Changed to ChatProvider

      final userId = authProvider.userId;
      final token = authProvider.token;

      print('DEBUG: MessagePage - Initializing chat for userId: $userId');

      if (userId != null) {
        chatProvider.fetchConversations(userId, token: token);
      }
    });
  }

  final colors = ConstColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [_buildHeader(), _builMessageCard()],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar.large(
      automaticallyImplyLeading: false,
      title: Text('Messages', style: TextStyle(color: colors.bg)),
      backgroundColor: colors.primary,
    );
  }

  Widget _builMessageCard() {
    return Consumer<ChatProvider>(
      // Changed to ChatProvider
      builder: (context, chatProvider, child) {
        final conversations = chatProvider.conversations;

        print(
          'DEBUG: MessagePage (Donneurs) - Rendering builder. Count: ${conversations.length}, Loading: ${chatProvider.isloading}',
        );

        if (chatProvider.isloading && conversations.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: colors.primary),
              ),
            ),
          );
        }

        return conversations.isEmpty
            ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(80),
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedMessageSearch01,
                          color: colors.primary,
                          size: 70,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Vous n\'avez aucun message',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SliverList.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return GestureDetector(
                    onTap: () {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final myId = authProvider.userId ?? '';
                      // Logic: Ensure we identify the partner ID correctly.
                      // If sender is me, other is receiver. Otherwise sender is other.
                      final otherId =
                          (conversation.senderId == myId ||
                              conversation.senderId.trim().isEmpty)
                          ? conversation.receiverId.trim()
                          : conversation.senderId.trim();

                      print(
                        'DEBUG: Message (Donneur) - Navigating to chat. myId: $myId, otherId: $otherId (from s=${conversation.senderId}, r=${conversation.receiverId})',
                      );

                      // Construct the context message for ChatWidget
                      final message = SendMessageModel(
                        id: otherId,
                        content: conversation.content,
                        senderId: myId,
                        receiverId: otherId,
                        userName: conversation.userName,
                        userPhoto: conversation.userPhoto,
                        timestamp: conversation.timestamp,
                      );

                      if (_isNavigating) return;
                      setState(() => _isNavigating = true);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatWidget(
                            pageType: 'Searcher',
                            message: message,
                          ),
                        ),
                      ).then((_) {
                        if (mounted) setState(() => _isNavigating = false);
                        // Optional: refresh logic on return
                        // chatProvider.fetchConversations(authProvider.token, myId);
                      });
                    },
                    child: _buildListTile(conversation),
                  );
                },
              );
      },
    );
  }

  DateTime? _parseTimestamp(dynamic lastMessage) {
    if (lastMessage == null) return null;
    if (lastMessage is DateTime) return lastMessage; // Should be DateTime now

    // Fallback if model still has loose typing
    final ts = lastMessage['timestamp'] ?? lastMessage['createdAt'];
    if (ts == null) return null;

    if (ts is DateTime) return ts;
    if (ts is String) return DateTime.tryParse(ts);
    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);

    return null;
  }

  Widget _buildListTile(SendMessageModel conversation) {
    // Logic: In the conversation list, 'userName' and 'userPhoto' are the Other Person's details
    final receiverName = conversation.userName;
    final receiverImage =
        conversation.userPhoto; // Corrected from userName to userPhoto
    final lastMessageContent = conversation.content;
    final timestamp = conversation.timestamp; // Should be DateTime

    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white, // Ensure a background color for the card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 0.8),
          ),
        ],
      ),
      child: ListTile(
        horizontalTitleGap: 10,
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: colors.primary.withOpacity(0.2),
          child: receiverImage != null && receiverImage.isNotEmpty
              ? ClipOval(
                  // Added ClipOval for better image rendering
                  child: Image.network(
                    receiverImage,
                    width: 80, // matched to radius * 2
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, color: colors.primary),
                  ),
                )
              : Icon(Icons.person, color: colors.primary),
        ),
        title: Text(
          receiverName,
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          lastMessageContent,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          timestamp != null
              ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
              : '',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
