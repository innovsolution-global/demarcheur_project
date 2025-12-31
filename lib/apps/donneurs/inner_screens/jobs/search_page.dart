import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/job_detail.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/compa_profile_provider.dart';
import 'package:demarcheur_app/providers/search_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _showClear = false;
  ConstColors color = ConstColors();

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _filterController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Load data and start animations
    // Future.microtask(() {
    //   final searchProvider = context.read<CompaProfileProvider>();
    //   searchProvider.loadVancies().then((_) {
    //     searchProvider.setJobs(searchProvider.filterVancy);
    //     _animationController.forward();
    //   });
    // });

    _searchController.addListener(() {
      setState(() {
        _showClear = _searchController.text.isNotEmpty;
      });
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    final search = Provider.of<SearchProvider>(context);
    final categories = search.categories;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: search.isLoading
            ? _buildLoadingState()
            : CustomScrollView(
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
                            child: _buildSearchSection(search),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildButtonSection(categories)),
                  SliverToBoxAdapter(child: _buildJobResults(search)),
                ],
              ),
      ),
    );
  }

  Widget _buildButtonSection(List<String> categories) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleWidget(text: "Categories", fontSize: 20),
          SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == categories.length - 1 ? 0 : 12,
                  ),
                  child: _buildMenuSection(categories[index], index),
                );
              },
            ),
          ),
          SizedBox(height: 16),

          SubTitle(
            text: "Recommandé pour vous",
            fontWeight: FontWeight.w700,
            fontsize: 18,
          ),
        ],
      ),
    );
  }

  int currentIndex = 0;
  Widget _buildMenuSection(String label, int index) {
    bool selected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(microseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: (selected ? color.primary : Colors.black).withOpacity(
                selected ? 0.2 : 0.05,
              ),
              blurRadius: selected ? 12 : 8,
              offset: const Offset(0, .2),
            ),
          ],
          color: selected ? color.primary : color.bg,
          border: Border.all(
            color: selected ? color.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitPulse(color: color.primary, size: 60.0),
            const SizedBox(height: 16),
            Text(
              'Recherche des offres...',
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

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: color.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowTurnBackward,
            color: color.primary,
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
                    image: const NetworkImage(
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
                      'Recherche d\'emploi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trouvez l\'opportunité parfaite',
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
      ),
    );
  }

  Widget _buildSearchSection(SearchProvider search) {
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
                    onChanged: search.searchJobs,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un emploi...',
                      hintStyle: TextStyle(color: color.secondary),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: color.primary,
                        size: 24,
                      ),
                      suffixIcon: _showClear
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                search.clearSearch();
                                FocusScope.of(context).unfocus();
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
                  onPressed: () => _showFilterBottomSheet(search),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedFilterHorizontal,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Results header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résultats',
                      style: TextStyle(
                        color: color.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Emplois disponibles',
                      style: TextStyle(color: color.secondary, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${search.allJob.length} trouvé${search.allJob.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: color.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: color.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobResults(SearchProvider search) {
    final provider = context.watch<SearchProvider>();
    final categories = provider.categories;
    final houses = provider.filteredJobs;

    if (houses.isEmpty) {
      return _buildEmptyState('Aucune offre disponible pour le moment.');
    }

    final selectedCategory = currentIndex == 0
        ? null
        : categories[currentIndex];
    final filteredHouses = selectedCategory == null
        ? houses
        : houses
              .where(
                (h) =>
                    h.category.toLowerCase() == selectedCategory.toLowerCase(),
              )
              .toList();

    if (filteredHouses.isEmpty) {
      return _buildEmptyState('Aucune offre trouvée dans cette catégorie.');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          filteredHouses.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildModernJobCard(filteredHouses[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildModernJobCard(dynamic job) {
    return GestureDetector(
      onTap: () {
        // Navigate to job detail
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetail(job: job)),
        );
      },
      child: AnimatedContainer(
        duration: Duration(microseconds: 1000),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.tertiary,
                      border: Border.all(color: color.tertiary),
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(job.imageUrl),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(
                            color: color.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.companyName,
                          style: TextStyle(
                            color: color.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: job.status == 'Disponible'
                          ? color.accepted.withOpacity(0.1)
                          : color.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        color: job.status == 'Disponible'
                            ? color.accepted
                            : color.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _buildInfoChip(Icons.location_on_outlined, job.location),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.work_outline, job.type),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    color: color.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.postDate,
                    style: TextStyle(color: color.secondary, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.primary.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Salaire',
                      style: TextStyle(
                        color: color.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${NumberFormat('#,###').format(job.salary)} GNF",
                      style: TextStyle(
                        color: color.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.primary, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(SearchProvider search) {
    _filterController.forward();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? selectedType;
        String? selectedLocation;

        return StatefulBuilder(
          builder: (context, setState) {
            return ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
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
                            'Filtres de recherche',
                            style: TextStyle(
                              color: color.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedType = null;
                                selectedLocation = null;
                              });
                              search.clearSearch();
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterSection(
                              'Type d\'emploi',
                              [
                                'Tout',
                                'Temps-plein',
                                'Temps-partiel',
                                'En ligne',
                              ],
                              selectedType,
                              (value) {
                                setState(() => selectedType = value);
                                search.filterByType(value ?? 'Tout');
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildFilterSection(
                              'Localisation',
                              ['Tout', 'Conakry', 'Kindia', 'Labé'],
                              selectedLocation,
                              (value) {
                                setState(() => selectedLocation = value);
                                search.filterByLocation(value ?? 'Tout');
                              },
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
