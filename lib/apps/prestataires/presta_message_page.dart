import 'dart:async';
import 'dart:ui';
import 'package:chat_plugin/chat_plugin.dart';
import 'package:demarcheur_app/apps/immo/immo_chat.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/widgets/immo_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrestaMessagePage extends StatefulWidget {
  const PrestaMessagePage({super.key});

  @override
  State<PrestaMessagePage> createState() => _ImmoMessagePageState();
}

class _ImmoMessagePageState extends State<PrestaMessagePage>
    with TickerProviderStateMixin {
  final ConstColors _colors = ConstColors();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  String _selectedFilter = 'Tous';
  bool _isSearchFocused = false;

  final List<String> _filters = ['Tous', 'Non lus', 'Favoris', 'Récents'];

  List<ChatRoom> _chatRooms = [];
  StreamSubscription? _chatRoomsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeChatRooms();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  Future<void> _initializeChatRooms() async {
    final chatService = ChatPlugin.chatService;
    await chatService.loadChatRooms();

    try {
      final stream =
          (chatService as dynamic).chatRoomsStream as Stream<List<ChatRoom>>?;
      if (stream != null) {
        _chatRoomsSubscription = stream.listen((rooms) {
          if (mounted) {
            setState(() {
              _chatRooms = rooms;
            });
          }
        });
      }
    } catch (e) {
      debugPrint("Error subscribing to chat rooms: $e");
    }
  }

  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    _searchController.dispose();
    _animationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredConversations() {
    List<dynamic> conversations = List.from(_chatRooms);

    final query = _searchController.text.trim().toLowerCase();

    // Apply search filter
    if (query.isNotEmpty) {
      conversations = conversations.where((c) {
        if (c is ChatRoom) {
          final name =
              (c as dynamic).receiverName?.toString().toLowerCase() ?? '';
          final msg =
              (c as dynamic).lastMessage?.content?.toString().toLowerCase() ??
              '';
          return name.contains(query) || msg.contains(query);
        }
        return false;
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'Non lus':
        conversations = conversations
            .where((c) => ((c as dynamic).unreadCount ?? 0) > 0)
            .toList();
        break;
      case 'Favoris':
        conversations = conversations.take(3).toList();
        break;

      case 'Récents':
        conversations = conversations.take(5).toList();
        break;
    }

    // Sort by unread count
    conversations.sort(
      (a, b) => ((b as dynamic).unreadCount ?? 0).compareTo(
        (a as dynamic).unreadCount ?? 0,
      ),
    );

    return conversations;
  }

  void _onSearchFocusChanged(bool focused) {
    setState(() => _isSearchFocused = focused);
    if (focused) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _onSearchFocusChanged(false);
      },
      child: Scaffold(
        backgroundColor: _colors.bg,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value * 50),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    ImmoHeader(auto: false),
                    _buildModernHeader(),
                    _buildSearchAndStats(),
                    _buildFilterChips(),
                    _buildConversationsList(),
                  ],
                ),
              ),
            );
          },
        ),
        // floatingActionButton: _buildNewChatFab(),
      ),
    );
  }

  Widget _buildModernHeader() {
    int safeUnread(dynamic item) {
      try {
        return item?.unreadCount is int ? item.unreadCount : 0;
      } catch (_) {
        return 0;
      }
    }

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_colors.primary, _colors.primary.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // TITLE + UNREAD IN REAL TIME
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Messages",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Builder(
                        builder: (context) {
                          int unreadCount = _chatRooms.fold<int>(
                            0,
                            (sum, c) => sum + safeUnread(c),
                          );

                          return Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Colors.white.withOpacity(0.6),
                                size: 8,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "$unreadCount messages non lus",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndStats() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isSearchFocused
                      ? _colors.primary
                      : Colors.grey.withValues(alpha: 0.3),
                  width: _isSearchFocused ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isSearchFocused
                        ? _colors.primary.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: _isSearchFocused ? 15 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onTap: () => _onSearchFocusChanged(true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Rechercher conversations, messages...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _isSearchFocused
                        ? _colors.primary
                        : Colors.grey[400],
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Builder(
      builder: (context) {
        final unreadCount = _chatRooms.fold<int>(
          0,
          (sum, c) => sum + ((c as dynamic).unreadCount as int? ?? 0),
        );

        // Simple logic for "active today" - check if last message was today
        final now = DateTime.now();
        final activeToday = _chatRooms.where((c) {
          final lastMsg = (c as dynamic).lastMessage;
          if (lastMsg == null) return false;
          final ts =
              (lastMsg as dynamic).timestamp ?? (lastMsg as dynamic).createdAt;
          if (ts == null) return false;

          DateTime? date;
          if (ts is DateTime) date = ts;
          if (ts is String) date = DateTime.tryParse(ts);
          if (ts is int) date = DateTime.fromMillisecondsSinceEpoch(ts);

          if (date == null) return false;
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).length;

        return Row(
          children: [
            Expanded(
              child: _QuickStatCard(
                icon: Icons.chat,
                count: _chatRooms.length,
                label: 'Total',
                color: _colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickStatCard(
                icon: Icons.mark_chat_unread,
                count: unreadCount,
                label: 'Non lus',
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickStatCard(
                icon: Icons.schedule,
                count: activeToday,
                label: 'Actifs',
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                        HapticFeedback.lightImpact();
                      },
                      backgroundColor: Colors.white,
                      selectedColor: _colors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _colors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? _colors.primary
                              : Colors.grey[300]!,
                        ),
                      ),
                      elevation: isSelected ? 2 : 0,
                      shadowColor: _colors.primary.withValues(alpha: 0.3),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    final filteredConversations = _getFilteredConversations();

    if (filteredConversations.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final conversation = filteredConversations[index];

        // Check if it's a real conversation or mock conversation
        if (conversation is ChatRoom) {
          return _ConversationTile(
            conversation: conversation,
            colors: _colors,
            onTap: () => _navigateToChat(conversation),
            index: index,
          );
        } else {
          return const SizedBox.shrink();
        }
      }, childCount: filteredConversations.length),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_selectedFilter) {
      case 'Non lus':
        message = "Aucun message non lu";
        icon = Icons.mark_chat_read;
        break;
      case 'Favoris':
        message = "Aucune conversation favorite";
        icon = Icons.favorite_border;
        break;

      default:
        message = _searchController.text.isNotEmpty
            ? "Aucun résultat trouvé"
            : "Aucune conversation";
        icon = Icons.chat_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _colors.primary, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _colors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? "Essayez avec d'autres termes"
                : "Commencez à discuter avec vos clients",
            style: TextStyle(color: _colors.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToChat(dynamic conversation) {
    HapticFeedback.lightImpact();

    if (conversation is ChatRoom) {
      final room = conversation;
      // Create a HouseModel from ChatRoom data
      final house = HouseModel(
        id: (room as dynamic).receiverId,
        companyName: (room as dynamic).receiverName ?? 'Utilisateur',
        imageUrl: [(room as dynamic).receiverImage ?? ''],
        // Default values for required fields
        logo: '',
        countType: '',
        postDate: '',
        rent: 0.0,
        location: '',
        type: '',
        rate: 0.0,
        status: '',
        category: '',
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImmoChat(presta: house)),
      );
    }
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ConstColors().secondary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatRoom conversation;
  final ConstColors colors;
  final VoidCallback onTap;
  final int index;

  const _ConversationTile({
    required this.conversation,
    required this.colors,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final unreadCount = (c as dynamic).unreadCount ?? 0;
    final hasUnread = unreadCount > 0;
    final receiverName = (c as dynamic).receiverName ?? 'Utilisateur';
    final receiverImage = (c as dynamic).receiverImage;
    final lastMessageContent = (c as dynamic).lastMessage?.content ?? '';

    String timeLabel = '';
    final lastMsg = (c as dynamic).lastMessage;
    if (lastMsg != null) {
      final ts =
          (lastMsg as dynamic).timestamp ?? (lastMsg as dynamic).createdAt;
      if (ts != null) {
        DateTime? date;
        if (ts is DateTime) date = ts;
        if (ts is String) date = DateTime.tryParse(ts);
        if (ts is int) date = DateTime.fromMillisecondsSinceEpoch(ts);

        if (date != null) {
          final now = DateTime.now();
          if (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day) {
            timeLabel =
                "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
          } else {
            timeLabel = "${date.day}/${date.month}";
          }
        }
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasUnread
            ? Border.all(color: colors.primary.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: hasUnread
                ? colors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: hasUnread ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        receiverImage ?? '',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (index % 3 == 0) // Placeholder for online status
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              receiverName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: hasUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: colors.secondary,
                              ),
                            ),
                          ),
                          Text(
                            timeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasUnread
                                  ? colors.primary
                                  : colors.tertiary,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.done_all,
                            size: 16,
                            color: colors.primary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lastMessageContent,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: hasUnread
                                    ? colors.secondary
                                    : colors.tertiary,
                                fontWeight: hasUnread
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$unreadCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Removed house specific info as it might not be available in ChatRoom
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
