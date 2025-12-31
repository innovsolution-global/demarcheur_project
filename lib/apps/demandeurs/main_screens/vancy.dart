import 'package:demarcheur_app/apps/demandeurs/main_screens/user_cv_view.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/add_vacancy_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/compa_profile_provider.dart';
import 'package:demarcheur_app/providers/enterprise_provider.dart';
import 'package:demarcheur_app/providers/user_provider.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
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
      //compaProvider.loadVancies();

      context.read<EnterpriseProvider>().loadUser();

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.bgSubmit.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.secondary.withOpacity(0.05)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              style: TextStyle(color: colors.secondary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Chercher par nom ou spécialité...',
                hintStyle: TextStyle(color: colors.secondary.withOpacity(0.4)),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.primary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: statusFilters.map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => selectedFilter = filter);
                    },
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : colors.secondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                    selectedColor: colors.primary,
                    backgroundColor: colors.bg,
                    elevation: 0,
                    pressElevation: 0,
                    side: BorderSide(
                      color: isSelected
                          ? colors.primary
                          : colors.secondary.withOpacity(0.1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
    final total = applicants.length;
    final enCours = applicants.where((a) => a.status == 'En cours').length;
    final interview = applicants.where((a) => a.status == 'Interview').length;
    final accepte = applicants.where((a) => a.status == 'Accepte').length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildStatBubble('Tous', total.toString(), colors.primary),
          const SizedBox(width: 12),
          _buildStatBubble('Pendant', enCours.toString(), colors.impression),
          const SizedBox(width: 12),
          _buildStatBubble('Interview', interview.toString(), colors.cour),
          const SizedBox(width: 12),
          _buildStatBubble('Accepte', accepte.toString(), colors.accepted),
        ],
      ),
    );
  }

  Widget _buildStatBubble(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$value $label',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

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
                  color: colors.secondary.withOpacity(0.1),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedEdit02,
                    color: colors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildStatusOption(
              applicant,
              'Interview',
              'Planifier un entretien',
              HugeIcons.strokeRoundedCalendar03,
              colors.cour,
            ),
            const SizedBox(height: 16),
            _buildStatusOption(
              applicant,
              'Accepte',
              'Accepter la candidature',
              HugeIcons.strokeRoundedCheckmarkCircle01,
              colors.accepted,
            ),
            const SizedBox(height: 16),
            _buildStatusOption(
              applicant,
              'Rejete',
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
    List<List<dynamic>> icon,
    Color color,
  ) {
    bool isSelected = applicant.status == status;
    return InkWell(
      onTap: () {
        _updateApplicantStatus(applicant, status);
        Navigator.pop(context);
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

    switch (applicant.status) {
      case 'Accepte':
        statusColor = colors.accepted;
        statusText = 'Admis';
        break;
      case 'Interview':
        statusColor = colors.cour;
        statusText = 'Entretien';
        break;
      case 'En cours':
        statusColor = colors.impression;
        statusText = 'En attente';
        break;
      default:
        statusColor = colors.error;
        statusText = 'Décliné';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserCvView(userCv: applicant),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.bg,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: statusColor.withOpacity(0.2),
                        width: 4,
                      ),
                    ),
                  ),
                  Hero(
                    tag: 'avatar_${applicant.name}',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(applicant.photo),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
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
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: colors.secondary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      applicant.speciality,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildIdentityBadge(
                          Icons.location_on_rounded,
                          applicant.location,
                        ),
                        _buildIdentityBadge(
                          Icons.work_history_rounded,
                          applicant.exp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.bgSubmit.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colors.secondary.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bgSubmit.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.secondary.withOpacity(0.4)),
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
    final userProvider = context.watch<UserProvider>();
    final applicants = userProvider.allusers;
    final filteredApplicants = _getFilteredApplicants(applicants);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFB),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddVacancyPage()),
            );
          },
          backgroundColor: colors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "Publier",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [Header(auto: false)];
          },
          body: CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
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
                                'Candidatures',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: colors.secondary,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${applicants.length} dossiers actifs',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.secondary.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar with Glow
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un profil...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colors.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Horizontal Filters
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: statusFilters.map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => setState(() => selectedFilter = filter),
                          child: Column(
                            children: [
                              Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.secondary.withOpacity(0.4),
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 3,
                                width: isSelected ? 20 : 0,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Applicants List or Empty State
              if (filteredApplicants.isEmpty)
                _buildEmptyState()
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
          ),
        ),
      ),
    );
  }
}
