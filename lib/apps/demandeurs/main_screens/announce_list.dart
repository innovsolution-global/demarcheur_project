import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/providers/compa_profile_provider.dart';
import 'package:demarcheur_app/providers/enterprise_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AnnounceList extends StatefulWidget {
  const AnnounceList({super.key});

  @override
  State<AnnounceList> createState() => _AnnounceListState();
}

class _AnnounceListState extends State<AnnounceList>
    with TickerProviderStateMixin {
  final ConstColors colors = ConstColors();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      context.read<CompaProfileProvider>().loadVancies(token);
      context.read<EnterpriseProvider>().loadUser(); // Load user for filtering
      _fadeController.forward();
    });
  }

  String _displayJobType(String token) {
    switch (token.toUpperCase()) {
      case 'CDI':
        return 'Plein temps';
      case 'PART_TIME':
        return 'Temps partiel';
      case 'CDD':
        return 'Contrat';
      case 'FREELANCE':
        return 'Freelance';
      case 'STAGE':
        return 'Stage';
      default:
        return token;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFFBFBFB),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          Header(auto: false),
        ],
        body: Consumer<CompaProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: SpinKitDancingSquare(color: colors.primary));
            }

            final enterpriseProvider = context.watch<EnterpriseProvider>();
            final currentUser = enterpriseProvider.user;

            print("DEBUG: AnnounceList - UserId: ${currentUser?.id}");

            // Filter vacancies by companyId
            final myVacancies = provider.vacancies.where((vacancy) {
              final match =
                  currentUser != null && vacancy.companyId == currentUser.id;
              // print("DEBUG: Vacancy ${vacancy.title} - CompanyId: ${vacancy.companyId} - Match: $match");
              return match;
            }).toList();

            if (myVacancies.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                final token = context.read<AuthProvider>().token;
                await provider.loadVancies(token);
                // Also reload user to ensure ID is fresh
                if (mounted) {
                  context.read<EnterpriseProvider>().loadUser();
                }
              },
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: myVacancies.length,
                  itemBuilder: (context, index) {
                    return _buildVacancyCard(myVacancies[index]);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVacancyCard(AddVancyModel vacancy) {
    return GestureDetector(
      onTap: () => _showVacancyDetails(vacancy),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: colors.primary.withValues(alpha: 0.02)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vacancy.companyImage != null &&
                    vacancy.companyImage!.isNotEmpty)
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(vacancy.companyImage!),
                        fit: BoxFit.cover,
                      ),
                      color: Colors.grey[200],
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vacancy.title,
                              style: TextStyle(
                                fontSize: 18,
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
                              color: colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _displayJobType(vacancy.typeJobe),
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (vacancy.companyName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            vacancy.companyName!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.secondary.withOpacity(0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoBadge(
                  HugeIcons.strokeRoundedLocation01,
                  vacancy.city.trim().isNotEmpty
                      ? vacancy.city
                      : 'Non spécifié',
                ),
                const SizedBox(width: 12),
                _buildInfoBadge(
                  HugeIcons.strokeRoundedMoney03,
                  "${vacancy.salary} GNF",
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: colors.secondary.withOpacity(0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Expire le: ${vacancy.deadline}",
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.secondary.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (vacancy.createdAt != null)
                  Text(
                    "Publié le: ${vacancy.createdAt!.split('T')[0]}",
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.secondary.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(List<List<dynamic>> icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            color: colors.secondary.withOpacity(0.5),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.secondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedPackageSearch,
              color: colors.primary.withOpacity(0.2),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Aucune annonce publiée",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Commencez par publier votre première offre d'emploi",
            style: TextStyle(
              color: colors.secondary.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showVacancyDetails(AddVancyModel vacancy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      vacancy.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailSection("Description", vacancy.description),
                    if (vacancy.missions.isNotEmpty)
                      _buildListSection("Missions", vacancy.missions),
                    if (vacancy.reqProfile.isNotEmpty)
                      _buildListSection("Profil recherché", vacancy.reqProfile),
                    if (vacancy.conditions.isNotEmpty)
                      _buildListSection("Conditions", vacancy.conditions),
                    if (vacancy.benefits.isNotEmpty)
                      _buildListSection("Avantages", vacancy.benefits),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: colors.secondary.withOpacity(0.7),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildListSection(String title, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.secondary.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
