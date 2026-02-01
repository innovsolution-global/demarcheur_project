import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SearchHome extends StatefulWidget {
  const SearchHome({super.key});

  @override
  _SearchHomeState createState() => _SearchHomeState();
}

class _SearchHomeState extends State<SearchHome> with TickerProviderStateMixin {
  ConstColors color = ConstColors();
  int currentCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Filter variables
  String? selectedPriceRange;
  String? selectedType;
  String? selectedLocation;
  String? selectedStatus;

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _filterController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Filter options
  final List<String> priceRanges = [
    'Tout',
    'Moins de 500,000 GNF',
    '500,000 - 1,000,000 GNF',
    '1,000,000 - 5,000,000 GNF',
    'Plus de 5,000,000 GNF',
  ];

  final List<String> propertyTypes = [
    'Tout',
    'Appartement',
    'Villa',
    'Hôtel',
    'Industrie',
  ];

  final List<String> locations = [
    'Toute',
    'Conakry',
    'Coyah',
    'Sonfonia',
    'Kaloum',
    'Kindia',
  ];

  final List<String> statusOptions = ['Tout', 'Disponible', 'Plus disponible'];

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _filterController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _filterController, curve: Curves.elasticOut),
    );

    // Load data and start animations
    Future.microtask(() {
      final houseProvider = context.read<HouseProvider>();
      if (houseProvider.allhouses.isEmpty) {
        houseProvider.loadHous().then((_) {
          _animationController.forward();
        });
      } else {
        _animationController.forward();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final houseProvider = context.read<HouseProvider>();
    _filterHouses(houseProvider);
  }

  void _filterHouses(HouseProvider provider) {
    List<HouseModel> filtered = provider.allhouses;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((house) {
        return house.companyName!.toLowerCase().contains(query) ||
            house.location!.toLowerCase().contains(query) ||
            house.type!.toLowerCase().contains(query);
      }).toList();
    }

    // Apply category filter
    final categories = provider.categories;
    if (currentCategoryIndex > 0 && currentCategoryIndex < categories.length) {
      final selectedCategory = categories[currentCategoryIndex];
      filtered = filtered
          .where(
            (house) =>
                house.category!.toLowerCase() ==
                selectedCategory!.toLowerCase(),
          )
          .toList();
    }

    // Apply price filter
    if (selectedPriceRange != null && selectedPriceRange != 'Tout') {
      filtered = filtered.where((house) {
        if (selectedPriceRange == 'Moins de 500,000 GNF') {
          return house.rent! < 500000;
        } else if (selectedPriceRange == '500,000 - 1,000,000 GNF') {
          return house.rent! >= 500000 && house.rent! <= 1000000;
        } else if (selectedPriceRange == '1,000,000 - 5,000,000 GNF') {
          return house.rent! >= 1000000 && house.rent! <= 5000000;
        } else if (selectedPriceRange == 'Plus de 5,000,000 GNF') {
          return house.rent! > 5000000;
        }
        return true;
      }).toList();
    }

    // Apply type filter
    if (selectedType != null && selectedType != 'Tout') {
      filtered = filtered
          .where(
            (house) => house.type!.toLowerCase() == selectedType!.toLowerCase(),
          )
          .toList();
    }

    // Apply location filter
    if (selectedLocation != null && selectedLocation != 'Toute') {
      filtered = filtered
          .where(
            (house) =>
                house.location!.toLowerCase() ==
                selectedLocation!.toLowerCase(),
          )
          .toList();
    }

    // Apply status filter
    if (selectedStatus != null && selectedStatus != 'Tout') {
      filtered = filtered
          .where(
            (house) =>
                house.status!.toLowerCase() == selectedStatus!.toLowerCase(),
          )
          .toList();
    }

    provider.setHouseFiltered(filtered);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _filterController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final houseProvider = context.watch<HouseProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildModernAppBar(),
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildSearchSection(houseProvider),
                    ),
                  );
                },
              ),
            ),
            if (houseProvider.isLoading)
              _buildLoadingState()
            else
              _buildSearchResults(houseProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      floating: false,
      pinned: true,
      backgroundColor: color.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowTurnBackward,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.primary, color.primary.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
                    ),
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      color.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recherche avancée',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trouvez la propriété parfaite',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(HouseProvider houseProvider) {
    final categories = houseProvider.categories;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar with filter button
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, lieu, type...',
                      hintStyle: TextStyle(color: color.secondary),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: color.primary,
                        size: 24,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterHouses(houseProvider);
                              },
                              icon: Icon(
                                Icons.clear_rounded,
                                color: color.secondary,
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: color.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _showFilterBottomSheet(houseProvider),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedFilterHorizontal,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Categories
          Text(
            'Catégories',
            style: TextStyle(
              color: color.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == categories.length - 1 ? 0 : 12,
                  ),
                  child: _buildCategoryChip(categories[index]!, index),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Results header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Résultats de recherche',
                style: TextStyle(
                  color: color.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${houseProvider.housefiltered.length} résultat${houseProvider.housefiltered.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: color.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, int index) {
    bool isSelected = currentCategoryIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentCategoryIndex = index;
        });
        _filterHouses(context.read<HouseProvider>());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.primary : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? color.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : color.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitPulse(color: color.primary, size: 60.0),
            const SizedBox(height: 16),
            Text(
              'Recherche en cours...',
              style: TextStyle(
                color: color.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(HouseProvider houseProvider) {
    final filteredHouses = houseProvider.housefiltered;

    if (filteredHouses.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Aucun résultat trouvé',
                style: TextStyle(
                  color: color.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Essayez de modifier vos critères de recherche',
                style: TextStyle(color: color.secondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final house = filteredHouses[index];
          return _buildHouseGridCard(house);
        }, childCount: filteredHouses.length),
      ),
    );
  }

  Widget _buildHouseGridCard(HouseModel house) {
    return GestureDetector(
      onTap: () {
        // Navigate to detail page
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Image.network(
                      house.imageUrl.first,
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
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        color: color.primary,
                        size: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: house.status == "Disponible"
                            ? color.accepted
                            : color.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        house.status!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      house.type!,
                      style: TextStyle(
                        color: color.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: color.secondary,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            house.location!,
                            style: TextStyle(
                              color: color.secondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${NumberFormat().format(house.rent)} GNF",
                            style: TextStyle(
                              color: color.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                house.rate.toString(),
                                style: TextStyle(
                                  color: Colors.amber.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(HouseProvider houseProvider) {
    _filterController.forward();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtres avancés',
                        style: TextStyle(
                          color: color.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedPriceRange = null;
                            selectedType = null;
                            selectedLocation = null;
                            selectedStatus = null;
                          });
                          _filterHouses(houseProvider);
                        },
                        child: Text(
                          'Effacer',
                          style: TextStyle(color: color.error),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterSection(
                          'Gamme de prix',
                          priceRanges,
                          selectedPriceRange,
                          (value) => setState(() => selectedPriceRange = value),
                        ),
                        const SizedBox(height: 20),
                        _buildFilterSection(
                          'Type de propriété',
                          propertyTypes,
                          selectedType,
                          (value) => setState(() => selectedType = value),
                        ),
                        const SizedBox(height: 20),
                        _buildFilterSection(
                          'Localisation',
                          locations,
                          selectedLocation,
                          (value) => setState(() => selectedLocation = value),
                        ),
                        const SizedBox(height: 20),
                        _buildFilterSection(
                          'Statut',
                          statusOptions,
                          selectedStatus,
                          (value) => setState(() => selectedStatus = value),
                        ),
                      ],
                    ),
                  ),
                ),

                // Apply button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _filterHouses(houseProvider);
                        Navigator.pop(context);
                        _filterController.reset();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Appliquer les filtres',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text('Sélectionner $title'),
              isExpanded: true,
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
