import 'dart:ui';
import 'package:demarcheur_app/apps/immo/immo_boost_page.dart';
import 'package:demarcheur_app/apps/immo/immo_detail_page.dart';
import 'package:demarcheur_app/apps/immo/immo_post_page.dart';
import 'package:demarcheur_app/apps/immo/immo_statistic_page.dart';
import 'package:demarcheur_app/apps/prestataires/presta_list.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  final List<String> _filterOptions = [
    'Tous',
    'Disponible',
    'Loué',
    'En vente',
    'Réservé',
  ];

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
        curve: Curves.elasticOut,
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
      final houseProvider = context.read<HouseProvider>();
      houseProvider.loadHous().then((_) {
        houseProvider.setHouseFiltered(houseProvider.housefiltered);
      });
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
          color: _color.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
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
      expandedHeight: 280,
      backgroundColor: _color.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background Image with Parallax Effect
            Positioned.fill(
              child: Image.network(
                "https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: _color.primary,
                  child: const Icon(Icons.home, size: 100, color: Colors.white),
                ),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Glass Morphism Effect
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: FadeTransition(
                opacity: _headerAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_headerAnimation),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.home,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tableau de bord",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Gérez vos biens immobiliers",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSearchBar(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onTap: () => setState(() => _isSearchFocused = true),
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Rechercher vos propriétés...",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
          prefixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSearchFocused
                ? Icon(Icons.search, color: _color.primary, size: 20)
                : Icon(Icons.search, color: Colors.grey[400]!, size: 20),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
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
          final houses = provider.housefiltered;
          final availableCount = houses
              .where((h) => h.status == "Disponible")
              .length;
          final rentedCount = houses.where((h) => h.status == "Loué").length;
          final totalRevenue = houses.fold<double>(
            0,
            (sum, house) => sum + house.rent,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: "Total",
                        value: houses.length.toString(),
                        icon: Icons.home,
                        color: _color.primary,
                        subtitle: "Propriétés",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: "Disponible",
                        value: availableCount.toString(),
                        icon: Icons.check_box,
                        color: Colors.green,
                        subtitle: "À louer",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: "Loué",
                        value: rentedCount.toString(),
                        icon: Icons.key,
                        color: Colors.orange,
                        subtitle: "Occupé",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _StatCard(
                  title: "Revenus totaux",
                  value:
                      "${NumberFormat('#,###').format(totalRevenue).replaceAll(',', '.')} GNF",
                  icon: Icons.monetization_on,
                  color: Colors.purple,
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
                        builder: (context) => const PrestaList(),
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
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                        HapticFeedback.lightImpact();
                      },
                      backgroundColor: Colors.white,
                      selectedColor: _color.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _color.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? _color.primary
                              : Colors.grey[300]!,
                        ),
                      ),
                      elevation: isSelected ? 2 : 0,
                      shadowColor: _color.primary.withOpacity(0.3),
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
            color: _color.tertiary,
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

    // Apply status filter
    if (_selectedFilter != 'Tous') {
      filtered = filtered
          .where((house) => house.status == _selectedFilter)
          .toList();
    }

    // Apply search filter
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (house) =>
                house.category.toLowerCase().contains(query) ||
                house.companyName.toLowerCase().contains(query) ||
                house.location.toLowerCase().contains(query),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isWide) const Spacer(),
              if (isWide) const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isWide ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: ConstColors().secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$title • $subtitle",
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

class _ModernPropertyCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isAvailable = house.status == "Disponible";

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Column(
          children: [
            // Property Image
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImmoDetailPage(house: house),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      house.imageUrl.first,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.home,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      house.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Price Badge
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${NumberFormat('#,###').format(house.rent).replaceAll(',', '.')} GNF",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Property Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Header
                  // Property Type
                  Text(
                    "${house.type} • ${house.category}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, color: color.primary, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          house.location,
                          style: TextStyle(fontSize: 16, color: color.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        house.rate.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Post Date
                  Text(
                    "Publié ${house.postDate}",
                    style: TextStyle(fontSize: 14, color: color.primary),
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onStatistic,
                          icon: Icon(
                            Icons.analytics,
                            color: color.primary,
                            size: 18,
                          ),
                          label: const Text("Stats"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color.primary,
                            side: BorderSide(
                              color: color.primary.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onBoost,
                          icon: const Icon(Icons.rocket_launch, size: 18),
                          label: const Text("Booster"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
