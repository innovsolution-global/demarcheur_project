import 'package:demarcheur_app/apps/demandeurs/main_screens/user_cv_view.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/compa_profile_provider.dart';
import 'package:demarcheur_app/providers/user_provider.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Load data and start animations
    Future.microtask(() {
      final userProvider = context.read<UserProvider>();
      userProvider.loadUsers();

      final compaProvider = context.read<CompaProfileProvider>();
      compaProvider.loadVancies();

      // Start animations after a delay
      Future.delayed(const Duration(milliseconds: 100), () {
        _fadeController.forward();
        _slideController.forward();
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredApplicants(List<dynamic> applicants) {
    var filtered = applicants.where((applicant) {
      // Filter by search query
      bool matchesSearch =
          searchQuery.isEmpty ||
          applicant.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          applicant.speciality.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      // Filter by status
      bool matchesStatus =
          selectedFilter == 'Tous' ||
          applicant.status.toLowerCase() == selectedFilter.toLowerCase() ||
          (selectedFilter == 'Accepté' && applicant.status == 'Accepte');

      return matchesSearch && matchesStatus;
    }).toList();

    return filtered;
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: colors.bg,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.bg,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? colors.error : colors.accepted,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  void _updateApplicantStatus(dynamic applicant, String newStatus) {
    setState(() {
      applicant.status = newStatus;
    });

    String message = '';
    switch (newStatus) {
      case 'Interview planifie':
        message = 'Entretien planifié pour ${applicant.name}';
        break;
      case 'Accepte':
        message = '${applicant.name} a été accepté(e)';
        break;
      case 'Rejete':
        message = '${applicant.name} a été rejeté(e)';
        break;
    }

    if (message.isNotEmpty) {
      _showMessage(message);
    }
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: colors.bgSubmit,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.tertiary),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un candidat...',
                hintStyle: TextStyle(
                  color: colors.secondary.withOpacity(0.6),
                  fontSize: 16,
                ),
                prefixIcon: Icon(Icons.search, color: colors.secondary),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          color: colors.secondary,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statusFilters.map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: colors.primary.withOpacity(0.2),
                    checkmarkColor: colors.primary,
                    backgroundColor: colors.bgSubmit,
                    labelStyle: TextStyle(
                      color: isSelected ? colors.primary : colors.secondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.tertiary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<dynamic> applicants) {
    final totalCount = applicants.length;
    final pendingCount = applicants.where((a) => a.status == 'En cours').length;
    final interviewCount = applicants
        .where((a) => a.status == 'Interview')
        .length;
    final acceptedCount = applicants.where((a) => a.status == 'Accepte').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Total',
            totalCount.toString(),
            HugeIcons.strokeRoundedUser,
            colors.primary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'En cours',
            pendingCount.toString(),
            HugeIcons.strokeRoundedClock02,
            colors.impression,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Entretiens',
            interviewCount.toString(),
            HugeIcons.strokeRoundedUserGroup,
            colors.cour,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Acceptés',
            acceptedCount.toString(),
            HugeIcons.strokeRoundedCheckmarkCircle01,
            colors.accepted,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String count,
    List<List<dynamic>> icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: color, size: 24),
            const SizedBox(height: 4),
            TitleWidget(text: count, fontSize: 18, color: color),
            SubTitle(
              text: label,
              fontsize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantCard(dynamic applicant) {
    Color statusColor;
    Color statusBgColor;
    String statusText = applicant.status;

    switch (applicant.status) {
      case 'Accepte':
        statusColor = colors.accepted;
        statusBgColor = colors.bgA;
        statusText = 'Accepté';
        break;
      case 'Interview':
        statusColor = colors.cour;
        statusBgColor = colors.bgcour;
        break;
      case 'En cours':
        statusColor = colors.impression;
        statusBgColor = colors.errorBg;
        break;
      default:
        statusColor = colors.error;
        statusBgColor = colors.errorBg;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.tertiary),
        boxShadow: [
          BoxShadow(
            color: colors.secondary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                // Profile Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.tertiary, width: 2),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(applicant.photo),
                      onError: (error, stackTrace) {},
                    ),
                  ),
                  child: applicant.photo.isEmpty
                      ? Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            color: colors.primary,
                            size: 24,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),

                // Applicant Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleWidget(text: applicant.name, fontSize: 18),
                      const SizedBox(height: 4),
                      SubTitle(
                        text: applicant.speciality,
                        fontsize: 14,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedLocation01,
                            color: colors.secondary.withOpacity(0.7),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          SubTitle(
                            text: applicant.location,
                            fontsize: 11,
                            color: colors.secondary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 12),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedTime02,
                            color: colors.secondary.withOpacity(0.7),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          SubTitle(
                            text: "il y a ${applicant.postDate}",
                            fontsize: 11,
                            color: colors.secondary.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 12,
                //     vertical: 6,
                //   ),
                //   decoration: BoxDecoration(
                //     color: statusBgColor,
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     statusText,
                //     style: TextStyle(
                //       color: statusColor,
                //       fontSize: 12,
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
              ],
            ),

            const SizedBox(height: 16),

            // Experience Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.bgSubmit,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedBriefcase01,
                    color: colors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  SubTitle(
                    text: applicant.exp,
                    fontsize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.secondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // View CV Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserCvView(userCv: applicant),
                        ),
                      );
                      // TODO: Navigate to CV view
                      _showMessage("Ouverture du CV de ${applicant.name}");
                    },
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedFile02,
                      color: colors.primary,
                      size: 16,
                    ),
                    label: Text(
                      "Voir CV",
                      style: TextStyle(color: colors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Status Dropdown
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.bgSubmit,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.tertiary),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        hintText: 'Changer le statut',
                        hintStyle: TextStyle(
                          color: colors.secondary.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      value: null,
                      items: ['Interview planifie', 'Accepte', 'Rejete'].map((
                        status,
                      ) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: status == 'Interview planifie'
                                    ? HugeIcons.strokeRoundedCalendar03
                                    : status == 'Accepte'
                                    ? HugeIcons.strokeRoundedCheckmarkCircle01
                                    : HugeIcons.strokeRoundedCancel01,
                                color: status == 'Interview planifie'
                                    ? colors.cour
                                    : status == 'Accepte'
                                    ? colors.accepted
                                    : colors.error,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                status == 'Interview planifie'
                                    ? 'Planifier entretien'
                                    : status == 'Accepte'
                                    ? 'Accepter'
                                    : 'Rejeter',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _updateApplicantStatus(applicant, value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedSearch01,
            color: colors.secondary.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: 20),
          TitleWidget(
            text: searchQuery.isNotEmpty
                ? 'Aucun résultat trouvé'
                : selectedFilter != 'Tous'
                ? 'Aucun candidat avec ce statut'
                : 'Aucun candidat',
            fontSize: 18,
            color: colors.secondary,
          ),
          const SizedBox(height: 8),
          SubTitle(
            text: searchQuery.isNotEmpty
                ? 'Essayez d\'autres mots-clés'
                : 'Les candidatures apparaîtront ici',
            fontsize: 14,
            color: colors.secondary.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final applicants = userProvider.allusers;
    final filteredApplicants = _getFilteredApplicants(applicants);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: CustomScrollView(
          slivers: [
            Header(auto: false),

            // Header Section
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleWidget(
                        text: 'Gestion des Candidatures',
                        fontSize: 24,
                        color: colors.secondary,
                      ),
                      const SizedBox(height: 4),
                      SubTitle(
                        text: 'Gérez et suivez vos candidats',
                        fontsize: 16,
                        color: colors.secondary.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading State
            if (userProvider.isLoading)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(60),
                  child: Center(
                    child: Column(
                      children: [
                        SpinKitFadingCircle(color: colors.primary, size: 50.0),
                        const SizedBox(height: 16),
                        SubTitle(
                          text: 'Chargement des candidatures...',
                          fontsize: 16,
                          color: colors.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Search and Filter
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildSearchAndFilter(),
                  ),
                ),
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildStatsCards(applicants),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Applicants List or Empty State
              if (filteredApplicants.isEmpty)
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildEmptyState(),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: filteredApplicants.length,
                  itemBuilder: (context, index) {
                    final applicant = filteredApplicants[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: Offset(0, 0.1 * (index + 1)),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: Interval(
                                  (index * 0.1).clamp(0.0, 1.0),
                                  ((index + 1) * 0.1).clamp(0.0, 1.0),
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                        child: _buildApplicantCard(applicant),
                      ),
                    );
                  },
                ),

              // Bottom Padding
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }
}
