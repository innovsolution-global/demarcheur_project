import 'package:demarcheur_app/apps/donneurs/inner_screens/houses/house_detail.dart';
import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/job_detail.dart';
import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/search_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/houses/immo_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/providers/compa_profile_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:demarcheur_app/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _showClear = false;
  ConstColors color = ConstColors();

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _filterController;
  late Animation<double> _scaleAnimation;

  int currentIndex = 0;
  // late AnimationController _houseanimationController;
  // late AnimationController _housefabController;
  // late Animation<double> _housefadeAnimation;
  // late Animation<Offset> _houseslideAnimation;
  // late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // houseControllerInitialization();
    // Load data and start animations
    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      context.read<CompaProfileProvider>().loadVancies(token);

      final searchProvider = context.read<SearchProvider>();
      searchProvider.loadJobs().then((_) {
        if (!mounted) return;
        searchProvider.setJobs(searchProvider.filteredJobs);
        _animationController.forward();
        final provider = context.read<HouseProvider>();
        provider.loadHous();
        _animationController.forward();
        Future.delayed(
          const Duration(milliseconds: 800),
          // _housefabController.forward,
        );
      });
    });

    _searchController.addListener(() {
      setState(() {
        _showClear = _searchController.text.isNotEmpty;
      });
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _filterController = AnimationController(
      vsync: this,
      duration: Duration(microseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _filterController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _filterController.dispose();
    // _houseanimationController.dispose();
    // _housefabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = Provider.of<CompaProfileProvider>(context);
    final houses = Provider.of<HouseProvider>(context);
    final auth = Provider.of<AuthProvider>(
      context,
      listen: false,
    ); // Get AuthProvider

    // Filter jobs logic
    final bool isSearcher = auth.role == 'SEARCHER';
    final displayedJobs = search.filterVancy.where((job) {
      if (!isSearcher) return true;
      // Heuristic: SEARCHERs should not see jobs from other SEARCHERs (assumed to be those without companyName)
      return job.companyName != null && job.companyName!.trim().isNotEmpty;
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildModernAppBar(),
            SliverToBoxAdapter(child: _buildSearchSection(search, houses)),

            // Check if both lists are empty (using filtered jobs)
            if (displayedJobs.isEmpty && houses.housefiltered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
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
                          style: TextStyle(
                            color: color.secondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Jobs Section
              if (displayedJobs.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'Boulots en vedette',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                  showButton: displayedJobs.length > 2,
                ),
                _buildJobResults(displayedJobs, search.isLoading, limit: 2),
              ],

              // Houses Section
              if (houses.housefiltered.isNotEmpty) ...[
                _buildSectionHeader(
                  title: 'Maisons en vedette',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ImmoPage()),
                    );
                  },
                  showButton: houses.housefiltered.length > 2,
                ),
                _buildHouseResults(houses, search, limit: 2),
              ],
            ],
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
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.primary, color.primary.withValues(alpha: 0.8)],
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/background.png"),
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.4),
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
                      color.primary.withValues(alpha: 0.8),
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
                        color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildSearchSection(CompaProfileProvider search, HouseProvider house) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar with filter button
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      search.search(value);
                      house.searchHouse(value);
                    },
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
                                house.clearSearch();
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
                      color: color.primary.withValues(alpha: 0.3),
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
        ],
      ),
    );
  }

  Widget _buildJobResults(
    List<AddVancyModel> jobs,
    bool isLoading, {
    int? limit,
  }) {
    // Empty check removed, handled in build method

    if (isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 100,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 80,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    final total = jobs.length;
    final count = limit != null ? math.min(limit, total) : total;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.builder(
        itemCount: count,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildModernJobCard(job),
          );
        },
      ),
    );
  }

  Widget _buildModernJobCard(AddVancyModel job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetail(job: job)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
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
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        (job.companyImage != null &&
                                job.companyImage!.isNotEmpty)
                            ? job.companyImage!
                            : "https://via.placeholder.com/150",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.work, color: color.bgSubmit),
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
                          job.companyName ?? 'Entreprise',
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
                      color: job.typeJobe == 'Disponible'
                          ? color.accepted.withValues(alpha: 0.2)
                          : color.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.typeJobe,
                      style: TextStyle(
                        color: job.typeJobe == 'Disponible'
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

              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    job.city.trim().isNotEmpty ? job.city : 'Non spécifié',
                  ),
                  _buildInfoChip(Icons.work_outline, job.typeJobe),
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
                    job.createdAt != null
                        ? job.createdAt!.split('T')[0]
                        : 'Recemment',
                    style: TextStyle(color: color.secondary, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.primary.withValues(alpha: 0.1),
                  ),
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
                    Flexible(
                      child: Text(
                        "${NumberFormat('#,###').format(job.salary)} GNF",
                        style: TextStyle(
                          color: color.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
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

  void _showFilterBottomSheet(CompaProfileProvider search) {
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
                            // _buildFilterSection(
                            //   'Type d\'emploi',
                            //   [
                            //     'Tout',
                            //     'Temps-plein',
                            //     'Temps-partiel',
                            //     'En ligne',
                            //   ],
                            //   // selectedType,
                            //   // (value) {
                            //   //   setState(() => selectedType = value);
                            //   //   search.filterByType(value ?? 'Tout');
                            //   // },
                            // ),
                            const SizedBox(height: 20),
                            // _buildFilterSection(
                            //  // 'Localisation',
                            //  // ['Tout', 'Conakry', 'Kindia', 'Labé'],
                            //   // selectedLocation,
                            //   // (value) {
                            //   //   setState(() => selectedLocation = value);
                            //   //   search.filterByLocation(value ?? 'Tout');
                            //   // },
                            // ),
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

  Widget _buildHouseResults(
    HouseProvider house,
    CompaProfileProvider search, {
    int? limit,
  }) {
    // Empty check removed, handled in build method

    if (search.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 200,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 200,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 80,
                                  height: 16,
                                  color: Colors.white,
                                ),
                                Container(
                                  width: 100,
                                  height: 16,
                                  color: Colors.white,
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
          },
        ),
      );
    }

    final total = house.housefiltered.length;
    final count = limit != null ? math.min(limit, total) : total;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.builder(
        itemCount: count,
        itemBuilder: (context, index) {
          final houses = house.housefiltered[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildModernHouseCard(houses),
          );
        },
      ),
    );
  }

  Widget _buildModernHouseCard(HouseModel house) {
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    house.imageUrl.isNotEmpty ? house.imageUrl.first : "",
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.home_outlined,
                        size: 50,
                        color: Colors.grey[400],
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
                      color: house.status == 'AVAILABLE'
                          ? Colors.green
                          : Colors.red,
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
                      house.status == 'AVAILABLE' ? 'Disponible' : 'Occupé',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Price Badge Overlay
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.primary.withOpacity(0.9),
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          house.title ?? house.countType ?? "Bien Immobilier",
                          style: TextStyle(
                            color: color.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    house.companyName ?? "Agence Immobilière",
                    style: TextStyle(
                      color: color.secondary.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: color.primary.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          house.location ?? "Localisation non spécifiée",
                          style: TextStyle(
                            color: color.secondary,
                            fontSize: 14,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniFeature(
                        Icons.meeting_room_outlined,
                        "${house.rooms ?? 0}",
                      ),
                      _buildMiniFeature(
                        Icons.weekend_outlined,
                        "${house.livingRooms ?? 0}",
                      ),
                      _buildMiniFeature(
                        Icons.square_foot_outlined,
                        "${house.area ?? 0}m²",
                      ),
                      _buildMiniFeature(
                        Icons.garage_outlined,
                        "${house.garage ?? 0}",
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

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onPressed,
    bool showButton = true,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            if (showButton)
              TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  backgroundColor: color.primary.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tout voir',
                      style: TextStyle(
                        color: color.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: color.primary,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniFeature(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color.secondary,
          ),
        ),
      ],
    );
  }
}
