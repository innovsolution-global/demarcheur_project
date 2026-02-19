import 'package:demarcheur_app/apps/demandeurs/main_screens/add_vacancy_page.dart';
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
          Header(auto: true),
        ],
        body: Consumer<CompaProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: SpinKitDancingSquare(color: colors.primary));
            }

            final enterpriseProvider = context.watch<EnterpriseProvider>();
            final currentUser = enterpriseProvider.user;



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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.secondary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: colors.primary.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: () => _showVacancyDetails(vacancy),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: colors.secondary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              _buildManagementMenu(vacancy),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                vacancy.companyName ?? "Entreprise",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.secondary.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colors.secondary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _displayJobType(vacancy.typeJobe),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Location and Salary Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRefinedBadge(
                        HugeIcons.strokeRoundedLocation01,
                        vacancy.city.trim().isNotEmpty
                            ? vacancy.city
                            : 'Ville non spécifiée',
                      ),
                      const SizedBox(width: 12),
                      _buildRefinedBadge(
                        HugeIcons.strokeRoundedMoney03,
                        "${vacancy.salary} GNF",
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: colors.secondary.withOpacity(0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Expire le ${vacancy.deadline}",
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.secondary.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (vacancy.createdAt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Publié le ${vacancy.createdAt!.split('T')[0]}",
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.secondary.withOpacity(0.6),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefinedBadge(
    dynamic icon,
    String label, {
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight
            ? colors.primary.withOpacity(0.06)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlight
              ? colors.primary.withOpacity(0.1)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            color: isHighlight
                ? colors.primary
                : colors.secondary.withOpacity(0.4),
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isHighlight
                  ? colors.primary
                  : colors.secondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementMenu(AddVancyModel vacancy) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: colors.secondary.withOpacity(0.15),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.bgSubmit.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          color: colors.secondary,
          size: 20,
        ),
      ),
      onSelected: (value) async {
        if (value == 'edit') {
          _handleEdit(vacancy);
        } else if (value == 'delete') {
          _handleDelete(vacancy);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          height: 48,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedEdit02,
                  size: 18,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Modifier",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.secondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 48,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete02,
                  size: 18,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Supprimer",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleEdit(AddVancyModel vacancy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVacancyPage(vacancyToEdit: vacancy),
      ),
    ).then((_) {
      // Refresh list after returning from edit page
      final token = context.read<AuthProvider>().token;
      context.read<CompaProfileProvider>().loadVancies(token);
    });
  }

  Future<void> _handleDelete(AddVancyModel vacancy) async {
    print("DEBUG: Requesting deletion for Job ID: ${vacancy.id}");
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Supprimer l'offre ?"),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer l'annonce \"${vacancy.title}\" ? Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Annuler",
              style: TextStyle(color: colors.secondary.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final token = context.read<AuthProvider>().token;
      final result = await context.read<CompaProfileProvider>().deleteJobOffer(
        vacancy.id!,
        token,
      );

      if (mounted) {
        String message;
        bool isSuccess = false;

        if (result == true) {
          message = "Offre supprimée";
          isSuccess = true;
        } else if (result == 'FOREIGN_KEY_VIOLATION') {
          message =
              "Impossible de supprimer : des candidats ont postulé à cette offre.";
        } else {
          message = "Erreur lors de la suppression";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? colors.primary : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
