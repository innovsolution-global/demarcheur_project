import 'package:demarcheur_app/apps/donneurs/inner_screens/houses/house_detail.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ImmoPage extends StatefulWidget {
  const ImmoPage({super.key});

  @override
  _ImmoPageState createState() => _ImmoPageState();
}

class _ImmoPageState extends State<ImmoPage> with TickerProviderStateMixin {
  final ConstColors color = ConstColors();
  int currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    Future.microtask(() async {
      await context.read<HouseProvider>().loadHous();
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildModernAppBar(),
            _buildSearchAndFilters(),
            _buildResultsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: color.primary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: color.secondary, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background Mesh
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.primary,
                    color.primary.withOpacity(0.8),
                    color.secondary,
                  ],
                ),
              ),
            ),
            // Decorative Spheres
            Positioned(
              top: -40,
              right: -40,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Propriétés',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Trouvez votre futur chez-vous',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final provider = context.watch<HouseProvider>();
    final categories = provider.categories;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => provider.searchHouse(value),
                decoration: InputDecoration(
                  hintText: 'Rechercher ville, quartier...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: color.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          // Category Chips
          SizedBox(
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = currentIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(categories[index] ?? "Tout"),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => currentIndex = index),
                    selectedColor: color.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : color.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isSelected ? color.primary : Colors.grey[200]!),
                    ),
                    showCheckmark: false,
                    elevation: isSelected ? 4 : 0,
                    shadowColor: color.primary.withOpacity(0.3),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    final provider = context.watch<HouseProvider>();
    final houses = provider.housefiltered;
    final selectedCategory = currentIndex == 0 ? null : provider.categories[currentIndex];
    
    final filteredHouses = selectedCategory == null
        ? houses
        : houses.where((h) => h.category?.toLowerCase() == selectedCategory.toLowerCase()).toList();

    if (filteredHouses.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[200]),
              const SizedBox(height: 16),
              Text(
                'Aucune propriété trouvée',
                style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _ModernPropertyRow(house: filteredHouses[index], color: color),
                ),
              ),
            );
          },
          childCount: filteredHouses.length,
        ),
      ),
    );
  }
}

class _ModernPropertyRow extends StatelessWidget {
  final HouseModel house;
  final ConstColors color;

  const _ModernPropertyRow({required this.house, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailHouse(
              house: house,
              houseLenth: context.read<HouseProvider>(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    house.imageUrl.isNotEmpty ? house.imageUrl.first : "",
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Icon(Icons.home_outlined, size: 40, color: Colors.grey[300]),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: house.status == 'AVAILABLE' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      house.status == 'AVAILABLE' ? 'Disponible' : 'Occupé',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${NumberFormat('#,###').format(house.rent).replaceAll(',', '.')} GNF",
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    house.title ?? house.countType ?? "Bien Immobilier",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color.secondary, letterSpacing: -0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: color.primary.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          house.location ?? "Localisation...",
                          style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MiniSpec(icon: Icons.meeting_room_outlined, val: "${house.rooms ?? 0}"),
                      _MiniSpec(icon: Icons.weekend_outlined, val: "${house.livingRooms ?? 0}"),
                      _MiniSpec(icon: Icons.square_foot_outlined, val: "${house.area ?? 0}m²"),
                      _MiniSpec(icon: Icons.garage_outlined, val: "${house.garage ?? 0}"),
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

class _MiniSpec extends StatelessWidget {
  final IconData icon;
  final String val;
  const _MiniSpec({required this.icon, required this.val});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ConstColors().secondary)),
      ],
    );
  }
}
