import 'package:demarcheur_app/apps/demandeurs/main_screens/user_cv_view.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/add_vacancy_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/enterprise_provider.dart';
import 'package:demarcheur_app/providers/user_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Vancy extends StatefulWidget {
  const Vancy({super.key});

  @override
  State<Vancy> createState() => _VancyState();
}

class _VancyState extends State<Vancy> with TickerProviderStateMixin {
  ConstColors colors = ConstColors();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isFabExtended = true;

  String selectedFilter = 'Tous';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> statusFilters = [
    'Tous',
    'En cours',
    'Interview',
    'Accepté',
    'Rejeté',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("DEBUG: Vancy initState - initializing data load");
      final enterpriseProvider = context.read<EnterpriseProvider>();

      // If data is missing (e.g., after Hot Restart), try loading it
      if (enterpriseProvider.user?.id == null) {
        print("DEBUG: Vancy - Enterprise data missing, calling loadUser()");
        await enterpriseProvider.loadUser();
      }

      final token = enterpriseProvider.token;
      final enterpriseId = enterpriseProvider.user?.id;

      print(
        "DEBUG: Vancy - Initial attempt IDs: token=${token != null}, entId=$enterpriseId",
      );

      if (enterpriseId != null) {
        context.read<UserProvider>().loadCandidates(
          token,
          enterpriseId: enterpriseId,
        );
      } else {
        print(
          "DEBUG: Vancy - Still no enterpriseId after loadUser(), waiting for build/watch",
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Logic Methods ---

  List<dynamic> _getFilteredApplicants(List<dynamic> allApplicants) {
    if (allApplicants.isEmpty) return [];

    return allApplicants.where((applicant) {
      // 1. Filter by Status
      bool matchesStatus = true;
      final status = applicant.status.toString().toUpperCase();

      if (selectedFilter != 'Tous') {
        if (selectedFilter == 'Accepté' &&
            (status == 'ACCEPTE' || status == 'ACCEPTED')) {
          matchesStatus = true;
        } else if (selectedFilter == 'Rejeté' &&
            (status == 'REJETE' || status == 'REJECTED')) {
          matchesStatus = true;
        } else if (selectedFilter == 'Interview' && status == 'INTERVIEW') {
          matchesStatus = true;
        } else if (selectedFilter == 'En cours' &&
            (status == 'EN COURS' || status == 'PENDING')) {
          matchesStatus = true;
        } else {
          matchesStatus = false;
        }
      }

      // 2. Filter by Search Query
      bool matchesSearch = true;
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final name = applicant.name.toLowerCase();
        final type = applicant.speciality.toLowerCase();
        matchesSearch = name.contains(query) || type.contains(query);
      }

      return matchesStatus && matchesSearch;
    }).toList();
  }

  void _updateApplicantStatus(dynamic applicant, String newStatus) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            'Statut changé en $newStatus ',
            style: TextStyle(color: colors.bg),
          ),
        ),
        backgroundColor: colors.accepted,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- UI Building Methods ---

  void _showStatusChangeModal(dynamic applicant) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.secondary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modifier le statut',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: colors.secondary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mise à jour pour ${applicant.name}',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.secondary.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildStatusOption(
              applicant,
              'INTERVIEW',
              'Planifier un entretien',
              HugeIcons.strokeRoundedCalendar03,
              colors.cour,
            ),
            const SizedBox(height: 16),
            _buildStatusOption(
              applicant,
              'ACCEPTED',
              'Accepter la candidature',
              HugeIcons.strokeRoundedCheckmarkCircle01,
              colors.accepted,
            ),
            const SizedBox(height: 16),
            _buildStatusOption(
              applicant,
              'REJECTED',
              'Rejeter le dossier',
              HugeIcons.strokeRoundedCancel01,
              colors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    dynamic applicant,
    String status,
    String label,
    dynamic icon,
    Color color,
  ) {
    bool isSelected =
        applicant.status.toString().toUpperCase() == status.toUpperCase();

    return InkWell(
      onTap: () async {
        print("DEBUG: Status option tapped for status: $status");
        print("DEBUG: Applicant CandidatureID: ${applicant.candidatureId}");

        if (applicant.candidatureId != null) {
          final auth = context.read<AuthProvider>();
          print("DEBUG: Auth Token available: ${auth.token != null}");

          final success = await auth.changeCandidatureStatus(
            applicant.candidatureId!,
            status,
          );

          print("DEBUG: Status change success: $success");

          if (success && mounted) {
            _updateApplicantStatus(applicant, status);
            setState(() {
              applicant.status = status;
            });
          }
        } else {
          print("DEBUG: Cannot change status - candidatureId is NULL");
        }
        if (mounted) Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : colors.bgSubmit.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : colors.secondary.withOpacity(0.04),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(icon: icon, color: color, size: 20),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colors.secondary
                      : colors.secondary.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantCard(dynamic applicant) {
    Color statusColor;
    String statusText;

    switch (applicant.status.toString().toUpperCase()) {
      case 'ACCEPTE':
      case 'ACCEPTED':
        statusColor = const Color(0xFF10B981); // Green
        statusText = 'Accepté';
        break;
      case 'INTERVIEW':
        statusColor = const Color(0xFFF59E0B); // Amber
        statusText = 'Entretien';
        break;
      case 'REJETE':
      case 'REJECTED':
        statusColor = const Color(0xFFEF4444); // Red
        statusText = 'Refusé';
        break;
      default:
        statusColor = const Color(0xFF3B82F6); // Blue
        statusText = 'En cours';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserCvView(userCv: applicant),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withOpacity(0.05),
                            image: () {
                              final photoUrl = applicant.photo;
                              if (photoUrl != null && photoUrl.isNotEmpty) {
                                print(
                                  "DEBUG: Vancy - Rendering image for ${applicant.name}: '$photoUrl'",
                                );
                                return DecorationImage(
                                  image: NetworkImage(photoUrl),
                                  fit: BoxFit.cover,
                                  onError: (obj, stack) {
                                    print(
                                      "ERROR: Failed to load image for ${applicant.name}: $photoUrl\n$obj",
                                    );
                                  },
                                );
                              }
                              return null;
                            }(),
                          ),
                          child:
                              (applicant.photo == null ||
                                  applicant.photo.isEmpty)
                              ? Center(
                                  child: Text(
                                    applicant.name.length > 0
                                        ? applicant.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: colors.primary,
                                      fontSize: 24,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  applicant.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: colors.secondary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (applicant.email != null &&
                              applicant.email != 'Non renseigné')
                            Row(
                              children: [
                                // Mail Icon Removed per user request change
                                Flexible(
                                  child: Text(
                                    applicant.email!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.secondary.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          // Speciality Commented out per user request change
                          // const SizedBox(height: 6),
                          // Text(
                          //   applicant.speciality,
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.w600,
                          //     color: colors.primary,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildIdentityBadge(
                            HugeIcons.strokeRoundedLocation01,
                            applicant.location,
                          ),
                          const SizedBox(width: 8),
                          _buildIdentityBadge(
                            HugeIcons.strokeRoundedTime01,
                            applicant.postDate.contains('T')
                                ? applicant.postDate.split('T').first
                                : applicant.postDate,
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => _showStatusChangeModal(applicant),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            size: 16,
                            color: colors.secondary,
                          ),
                        ),
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

  // CORRECTED TYPE to dynamic/IconData because List<List<dynamic>> is likely an error
  Widget _buildIdentityBadge(dynamic icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bgSubmit.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon, // Expecting IconData
            size: 12,
            color: colors.secondary.withOpacity(0.4),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.secondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: colors.secondary.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty ? 'Aucun résultat' : 'Aucune candidature',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.secondary.withOpacity(0.3),
              ),
            ),
            if (searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Essayez d\'autres mots-clés',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondary.withOpacity(0.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enterpriseProvider = context.watch<EnterpriseProvider>();
    final userProvider = context.watch<UserProvider>();

    // Safety fallback: if userProvider has not fetched data yet and we have enterprise ID, trigger load
    if (!userProvider.isLoading &&
        !userProvider.hasFetchedCandidates &&
        enterpriseProvider.user?.id != null &&
        enterpriseProvider.token != null) {
      print(
        "DEBUG: Vancy build - Triggering deferred load for enterprise: ${enterpriseProvider.user?.id}",
      );
      Future.microtask(() {
        userProvider.loadCandidates(
          enterpriseProvider.token,
          enterpriseId: enterpriseProvider.user?.id,
        );
      });
    }

    final apps = userProvider.allusers;
    print("DEBUG: Vancy build - apps count: ${apps.length}, isLoading: ${userProvider.isLoading}");
    final filteredApplicants = _getFilteredApplicants(apps);

    final isLoading = userProvider.isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: RefreshIndicator(
          color: colors.primary,
          onRefresh: () async {
            final enterpriseProvider = context.read<EnterpriseProvider>();
            await context.read<UserProvider>().loadCandidates(
              enterpriseProvider.token,
              enterpriseId: enterpriseProvider.user?.id,
            );
          },
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar.large(
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/background.png'),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 110,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Candidatures',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: colors.bg,
                                  fontSize: 25,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                apps.length == 1
                                    ? '${apps.length} dossier actif'
                                    : '${apps.length} dossiers actifs',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors.bg.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                automaticallyImplyLeading: false,
                backgroundColor: colors.primary,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                expandedHeight: 150,
              ),
            ],
            body: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: colors.secondary),
                          onChanged: (val) => setState(() => searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Rechercher un candidat...',
                            hintStyle: TextStyle(
                              color: colors.secondary.withOpacity(0.4),
                              fontWeight: FontWeight.w500,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                              icon: _searchController.text.isNotEmpty
                                  ? Icon(Icons.clear)
                                  : SizedBox.shrink(),
                            ),
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: statusFilters.map((filter) {
                            final isSelected = selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () =>
                                    setState(() => selectedFilter = filter),
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? colors.primary
                                          : colors.secondary.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : colors.secondary.withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? _buildShimmerLoading()
                      : filteredApplicants.isEmpty
                      ? CustomScrollView(slivers: [_buildEmptyState()])
                      : NotificationListener<UserScrollNotification>(
                          onNotification: (notification) {
                            if (notification.direction ==
                                ScrollDirection.reverse) {
                              if (_isFabExtended) {
                                setState(() => _isFabExtended = false);
                              }
                            } else if (notification.direction ==
                                ScrollDirection.forward) {
                              if (!_isFabExtended) {
                                setState(() => _isFabExtended = true);
                              }
                            }
                            return true;
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 100),
                            itemCount: filteredApplicants.length,
                            itemBuilder: (context, index) {
                              final applicant = filteredApplicants[index];
                              return _buildApplicantCard(applicant);
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _isFabExtended
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddVacancyPage(),
                    ),
                  );
                },
                backgroundColor: colors.primary,
                elevation: 4,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  "Publier une offre",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              )
            : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddVacancyPage(),
                    ),
                  );
                },
                backgroundColor: colors.primary,
                elevation: 4,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 100),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[100]!,
        highlightColor: Colors.grey[50]!,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
