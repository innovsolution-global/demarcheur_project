import 'dart:ui';
import 'package:demarcheur_app/apps/immo/immo_chat.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:demarcheur_app/providers/immo/immo_chat_provider.dart';
import 'package:demarcheur_app/widgets/immo_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ImmoMessagePage extends StatefulWidget {
  const ImmoMessagePage({super.key});

  @override
  State<ImmoMessagePage> createState() => _ImmoMessagePageState();
}

class _ImmoMessagePageState extends State<ImmoMessagePage>
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

  // Mock data for when provider is not available
  final List<MockConversation> _mockConversations = [
    MockConversation(
      companyName: "Immobilier Premium",
      lastMessage:
          "Merci pour votre intérêt, quand pouvons-nous planifier la visite ?",
      timeLabel: "10:30",
      unreadCount: 2,
      imageUrl: "https://example.com/image1.jpg",
      type: "Appartement",
      location: "Conakry, Kaloum",
    ),
    MockConversation(
      companyName: "Habitat Plus",
      lastMessage: "Le prix est négociable pour un achat rapide",
      timeLabel: "Hier",
      unreadCount: 0,
      imageUrl: "https://example.com/image2.jpg",
      type: "Villa",
      location: "Dixinn, Conakry",
    ),
    MockConversation(
      companyName: "Vision Immobilier",
      lastMessage: "Oui, la propriété est encore disponible",
      timeLabel: "14:20",
      unreadCount: 1,
      imageUrl: "https://example.com/image3.jpg",
      type: "Maison",
      location: "Ratoma, Conakry",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadConversations();
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

  void _loadConversations() {
    Future.microtask(() {
      try {
        final houses = context.read<HouseProvider>().allhouses;
        context.read<ImmoChatProvider>().seedFromJobs(houses);
      } catch (e) {
        // Provider not available, we'll use mock data
        setState(() {
          // Mock data is already loaded in _mockConversations
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredConversations() {
    List<dynamic> conversations;

    try {
      // Try to get real conversations from provider and create a copy
      conversations = List<dynamic>.from(
        context.watch<ImmoChatProvider>().conversations,
      );
    } catch (e) {
      // Fallback to mock conversations and create a copy
      conversations = List<dynamic>.from(_mockConversations);
    }

    final query = _searchController.text.trim().toLowerCase();

    // Apply search filter
    if (query.isNotEmpty) {
      conversations = conversations
          .where(
            (c) =>
                c.companyName?.toLowerCase().contains(query) == true ||
                c.type?.toLowerCase().contains(query) == true ||
                c.lastMessage?.toLowerCase().contains(query) == true ||
                (c.house?.companyName?.toLowerCase().contains(query) == true) ||
                (c.house?.type?.toLowerCase().contains(query) == true),
          )
          .toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'Non lus':
        conversations = conversations
            .where((c) => (c.unreadCount ?? 0) > 0)
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
      (a, b) => (b.unreadCount ?? 0).compareTo(a.unreadCount ?? 0),
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
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_colors.primary, _colors.primary.withOpacity(0.8)],
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
                      Consumer<ImmoChatProvider>(
                        builder: (context, provider, child) {
                          try {
                            final conversations = List.from(
                              provider.conversations,
                            );
                            final unreadCount = conversations.fold<int>(
                              0,
                              (sum, c) => sum + ((c.unreadCount ?? 0) as int),
                            );
                            return Text(
                              unreadCount > 0
                                  ? "$unreadCount nouveau${unreadCount > 1 ? 'x' : ''} message${unreadCount > 1 ? 's' : ''}"
                                  : "Toutes les conversations",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            );
                          } catch (e) {
                            final conversations = List<MockConversation>.from(
                              _mockConversations,
                            );
                            final unreadCount = conversations.fold<int>(
                              0,
                              (sum, c) => sum + c.unreadCount,
                            );
                            return Text(
                              unreadCount > 0
                                  ? "$unreadCount nouveau${unreadCount > 1 ? 'x' : ''} message${unreadCount > 1 ? 's' : ''}"
                                  : "Toutes les conversations",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            );
                          }
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
                      : Colors.grey.withOpacity(0.3),
                  width: _isSearchFocused ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isSearchFocused
                        ? _colors.primary.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
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
    return Consumer<ImmoChatProvider>(
      builder: (context, provider, child) {
        try {
          final conversations = List.from(provider.conversations);
          final unreadCount = conversations.fold<int>(
            0,
            (sum, c) => sum + ((c.unreadCount ?? 0) as int),
          );
          final activeToday = conversations
              .where(
                (c) => c.timeLabel.contains('min') || c.timeLabel.contains('h'),
              )
              .length;

          return Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.chat,
                  count: conversations.length,
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
        } catch (e) {
          // Fallback to mock data stats
          final conversations = List<MockConversation>.from(_mockConversations);
          final unreadCount = conversations.fold<int>(
            0,
            (sum, c) => sum + c.unreadCount,
          );
          final activeToday = conversations
              .where(
                (c) => c.timeLabel.contains('min') || c.timeLabel.contains(':'),
              )
              .length;

          return Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.chat,
                  count: conversations.length,
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
        }
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
                      shadowColor: _colors.primary.withOpacity(0.3),
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
        if (conversation is MockConversation) {
          return _ConversationTileFallback(
            conversation: conversation,
            colors: _colors,
            onTap: () => _navigateToChat(conversation),
            index: index,
          );
        } else {
          // Real conversation from provider
          return _ConversationTile(
            conversation: conversation,
            colors: _colors,
            onTap: () => _navigateToChat(conversation),
            index: index,
          );
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
              color: _colors.primary.withOpacity(0.1),
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

  Widget _buildNewChatFab() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Nouvelle conversation"),
            backgroundColor: _colors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      backgroundColor: _colors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text("Nouveau"),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _navigateToChat(dynamic conversation) {
    HapticFeedback.lightImpact();

    try {
      // Try to navigate with real conversation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImmoChat(presta: conversation.house),
        ),
      );
    } catch (e) {
      // Handle mock conversation or show message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chat avec ${conversation.companyName ?? 'Client'}"),
          backgroundColor: _colors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
            color: Colors.black.withOpacity(0.05),
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
  final dynamic conversation;
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
    final hasUnread = c.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasUnread
            ? Border.all(color: colors.primary.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: hasUnread
                ? colors.primary.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
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
                        c.house.imageUrl.first,
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
                          child: const Icon(Icons.home, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (index % 3 == 0)
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
                              c.house.companyName,
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
                            c.timeLabel,
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
                            color: colors.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              c.lastMessage,
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
                                "${c.unreadCount}",
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
                      Text(
                        "${c.house.type} • ${c.house.location}",
                        style: TextStyle(fontSize: 12, color: colors.primary),
                      ),
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

class _ConversationTileFallback extends StatelessWidget {
  final MockConversation conversation;
  final ConstColors colors;
  final VoidCallback onTap;
  final int index;

  const _ConversationTileFallback({
    required this.conversation,
    required this.colors,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final hasUnread = c.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasUnread
            ? Border.all(color: colors.primary.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: hasUnread
                ? colors.primary.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
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
                      child: Container(
                        width: 56,
                        height: 56,
                        color: colors.primary.withOpacity(0.1),
                        child: Icon(Icons.home, color: colors.primary),
                      ),
                    ),
                    if (index % 3 == 0)
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
                              c.companyName,
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
                            c.timeLabel,
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
                            color: colors.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              c.lastMessage,
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
                                "${c.unreadCount}",
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
                      Text(
                        "${c.type} • ${c.location}",
                        style: TextStyle(fontSize: 12, color: colors.tertiary),
                      ),
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

class MockConversation {
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final String companyName;
  final String imageUrl;
  final String type;
  final String location;

  MockConversation({
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.companyName,
    required this.imageUrl,
    required this.type,
    required this.location,
  });
}
