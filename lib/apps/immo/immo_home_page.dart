import 'dart:ui';
import 'package:demarcheur_app/apps/immo/immo_announce_page.dart';
import 'package:demarcheur_app/apps/immo/immo_boost_page.dart';
import 'package:demarcheur_app/apps/immo/immo_detail_page.dart';
import 'immo_post_page.dart';
import 'package:demarcheur_app/apps/immo/immo_statistic_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ImmoHomePage extends StatefulWidget {
  const ImmoHomePage({super.key});

  @override
  State<ImmoHomePage> createState() => _ImmoHomePageState();
}

class _ImmoHomePageState extends State<ImmoHomePage>
    with TickerProviderStateMixin {
  final ConstColors _color = ConstColors();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isFabVisible = true;
  bool _isSearchFocused = false;
  String _selectedFilter = 'Tous';

  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fabScaleAnimation;

  final List<String> _filterOptions = ['Tous', 'Disponible', 'Loué'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _loadData();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInToLinear,
      ),
    );

    _headerAnimationController.forward();
    _fabAnimationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) {
          setState(() => _isFabVisible = false);
          _fabAnimationController.reverse();
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) {
          setState(() => _isFabVisible = true);
          _fabAnimationController.forward();
        }
      }
    });
  }

  void _loadData() {
    Future.microtask(() {
      final authProvider = context.read<AuthProvider>();
      final houseProvider = context.read<HouseProvider>();

      final token = authProvider.token;
      final companyId = authProvider.userId;

      houseProvider.loadHous(token: token, companyId: companyId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _isSearchFocused = false);
      },
      child: Scaffold(
        backgroundColor: _color.bg,
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: _color.bg,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernHeader(),
              _buildQuickStats(),
              _buildFilterSection(),
              _buildPropertyList(),
            ],
          ),
        ),
        floatingActionButton: _buildAnimatedFab(),
      ),
    );
  }

  Widget _buildModernHeader() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: 220,
      backgroundColor: _color.primary,
      systemOverlayStyle: SystemUiOverlayStyle.light,

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/background.png'),
            ),
          ),
          child: Stack(
            children: [
              // Background with Gradient Mesh Effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _color.primary.withOpacity(0.8),
                        _color.primary.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
              // Decorative Spheres

              // Header Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bienvenue sur",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                "Espace Immo",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _color.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onTap: () => setState(() => _isSearchFocused = true),
        onChanged: (value) => setState(() {}),
        style: TextStyle(
          color: _color.secondary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: "Rechercher une propriété...",
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _color.primary,
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _color.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: _color.primary,
                    size: 20,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: Consumer<HouseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Container(
              margin: const EdgeInsets.all(20),
              child: _StatsShimmer(),
            );
          }
          final houses = provider.housefiltered;
          final availableCount = houses
              .where((h) => h.status == "Disponible" || h.status == "AVAILABLE")
              .length;
          final rentedCount = houses
              .where((h) => h.status == "Loué" || h.status == "RENTED")
              .length;
          final totalRevenue = houses.fold<double>(
            0,
            (sum, house) => sum + (house.rent ?? 0.0),
          );

          return Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWidget(
                  text: "Aperçu",
                  fontSize: 22,
                  color: _color.secondary,
                ),
                const SizedBox(height: 12),
                _StatCard(
                  title: "Revenus totaux",
                  value:
                      "${NumberFormat('#,###').format(totalRevenue).replaceAll(',', '.')} GNF",
                  icon: Icons.monetization_on,
                  color: const Color(0xFF1A237E),
                  subtitle: "Par mois",
                  isWide: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleWidget(
                  text: "Mes propriétés",
                  fontSize: 22,
                  color: _color.secondary,
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImmoAnnouncePage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    color: _color.primary,
                    size: 16,
                  ),
                  label: Text(
                    "Voir tout",
                    style: TextStyle(
                      color: _color.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                        HapticFeedback.selectionClick();
                      },
                      backgroundColor: Colors.white,
                      selectedColor: _color.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _color.secondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? _color.primary
                              : Colors.grey[200]!,
                        ),
                      ),
                      showCheckmark: false,
                      elevation: isSelected ? 4 : 0,
                      shadowColor: _color.primary.withOpacity(0.2),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyList() {
    return Consumer<HouseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _PropertyShimmer(),
              childCount: 3,
            ),
          );
        }

        List<HouseModel> filteredHouses = _getFilteredHouses(
          provider.housefiltered,
        );

        if (filteredHouses.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final house = filteredHouses[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutCubic,
              child: _ModernPropertyCard(
                house: house,
                color: _color,
                onBoost: () => _navigateToBoost(house),
                onStatistic: () => _navigateToStats(house),
              ),
            );
          }, childCount: filteredHouses.length),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _color.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, color: _color.primary, size: 48),
          ),
          const SizedBox(height: 20),
          TitleWidget(
            text: "Aucun résultat",
            fontSize: 20,
            color: _color.secondary,
          ),
          const SizedBox(height: 8),
          SubTitle(
            text:
                "Essayez d'ajuster vos filtres ou ajoutez de nouvelles propriétés",
            fontsize: 16,
            color: _color.secondary,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ImmoPostPage()),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Ajouter une propriété"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _color.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFab() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ImmoPostPage()),
          );
        },
        backgroundColor: _color.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          "Ajouter",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  List<HouseModel> _getFilteredHouses(List<HouseModel> houses) {
    List<HouseModel> filtered = houses;

    // Apply status filter mapping UI labels to backend Enums
    if (_selectedFilter != 'Tous') {
      String backendStatus = _selectedFilter;
      switch (_selectedFilter) {
        case 'Disponible':
          backendStatus = 'AVAILABLE';
          break;
        case 'Loué':
          backendStatus = 'RENTED';
          break;
      }
      filtered = filtered
          .where(
            (house) =>
                house.status == backendStatus ||
                house.statusProperty == backendStatus,
          )
          .toList();
    }

    // Apply search filter
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (house) =>
                (house.category?.toLowerCase().contains(query) ?? false) ||
                (house.companyName?.toLowerCase().contains(query) ?? false) ||
                (house.location?.toLowerCase().contains(query) ?? false) ||
                (house.title?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    return filtered;
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadData();
  }

  void _navigateToBoost(HouseModel house) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImmoBoostPage(boost: house)),
    );
  }

  void _navigateToStats(HouseModel house) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImmoStatisticPage(house: house)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final bool isWide;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (isWide)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.green[700],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "+12%",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: isWide ? 26 : 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A0B2E),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernPropertyCard extends StatefulWidget {
  final HouseModel house;
  final ConstColors color;
  final VoidCallback onBoost;
  final VoidCallback onStatistic;

  const _ModernPropertyCard({
    required this.house,
    required this.color,
    required this.onBoost,
    required this.onStatistic,
  });

  @override
  State<_ModernPropertyCard> createState() => _ModernPropertyCardState();
}

class _ModernPropertyCardState extends State<_ModernPropertyCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.house.imageUrl;
    final hasMultipleImages = images.length > 1;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Property Image Section with Carousel
            Stack(
              children: [
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: images.isEmpty
                      ? Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.home_work_rounded,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                        )
                      : PageView.builder(
                          itemCount: images.length,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return Hero(
                              tag: index == 0
                                  ? 'house_${widget.house.id}'
                                  : 'house_${widget.house.id}_$index',
                              child: Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[100],
                                      child: Icon(
                                        Icons.broken_image_rounded,
                                        size: 40,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                              ),
                            );
                          },
                        ),
                ),

                // Image Counter Indicator - Repositioned to Bottom-Right of image area
                if (hasMultipleImages)
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1} / ${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                // Dots indicator
                if (hasMultipleImages)
                  Positioned(
                    bottom: 70, // Above price overlay
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentImageIndex == index ? 12 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Action Menu (Edit/Delete) - Top Right
                Positioned(
                  top: 12,
                  right: 12,
                  child: PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ImmoPostPage(propertyToEdit: widget.house),
                          ),
                        ).then(
                          (_) => context.read<HouseProvider>().loadHous(
                            token: context.read<AuthProvider>().token,
                            companyId: context.read<AuthProvider>().userId,
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 20),
                            SizedBox(width: 12),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge - Top Left (Interactive Toggle)
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () async {
                      print('=== UI: Availability Toggle Tap - START ===');
                      final currentStatus =
                          widget.house.statusProperty ??
                          widget.house.status ??
                          'AVAILABLE';
                      final newStatus = currentStatus == 'AVAILABLE'
                          ? 'RENTED'
                          : 'AVAILABLE';

                      print(
                        'DEBUG: UI - Current Status: $currentStatus, New Target: $newStatus',
                      );
                      print('DEBUG: UI - Property ID: ${widget.house.id}');

                      // Show confirmation or just toggle? Toggle is faster for UX.
                      HapticFeedback.mediumImpact();

                      final provider = context.read<HouseProvider>();
                      final auth = context.read<AuthProvider>();

                      print('DEBUG: UI - Calling provider.updateHouse...');
                      // Update local state temporarily for snappy UI (Provider does this via notifyListeners)
                      final success = await provider.updateHouse(
                        widget.house.id!,
                        HouseModel(
                          id: widget.house.id,
                          statusProperty: newStatus,
                          status: newStatus,
                        ),
                        auth.token,
                      );

                      print(
                        'DEBUG: UI - provider.updateHouse result: $success',
                      );

                      if (success && mounted) {
                        print('=== UI: Availability Toggle Tap - SUCCESS ===');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Propriété marquée comme ${newStatus == 'AVAILABLE' ? 'Disponible' : 'Louée'}',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else if (mounted) {
                        print('=== UI: Availability Toggle Tap - FAILED ===');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Erreur lors de la mise à jour du statut',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (widget.house.statusProperty == 'AVAILABLE' ||
                                widget.house.status == 'AVAILABLE')
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        (widget.house.statusProperty == 'AVAILABLE' ||
                                widget.house.status == 'AVAILABLE')
                            ? 'DISPONIBLE'
                            : 'LOUÉE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Price Gradient Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImmoDetailPage(house: widget.house),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${NumberFormat('#,###').format(widget.house.rent ?? 0).replaceAll(',', '.')} GNF",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.house.countType ?? "Par mois",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Property Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.house.title ?? 'Propriété immobilière',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A237E),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.color.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.house.category ?? "Immo",
                          style: TextStyle(
                            color: widget.color.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: widget.color.primary.withOpacity(0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.house.location ?? "Lieu non spécifié",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[100], height: 1),
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onStatistic,
                          icon: const Icon(Icons.analytics_outlined, size: 18),
                          label: const Text("Détails"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: widget.color.primary,
                            elevation: 0,
                            side: BorderSide(
                              color: widget.color.primary.withOpacity(0.1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1A237E).withValues(alpha: 0.5),
                                ConstColors().primary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1A237E).withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: widget.onBoost,
                            icon: const Icon(Icons.bolt_rounded, size: 18),
                            label: const Text("Booster"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la propriété'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette propriété ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<HouseProvider>();
              final auth = context.read<AuthProvider>();
              final success = await provider.deleteHouse(
                widget.house.id!,
                auth.token,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Propriété supprimée')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.white,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

class _PropertyShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              height: 240,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
}
