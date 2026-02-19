import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/job_detail.dart';
import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/job_posting.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/services/api_service.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyAnnouncements extends StatefulWidget {
  const MyAnnouncements({super.key});

  @override
  State<MyAnnouncements> createState() => _MyAnnouncementsState();
}

class _MyAnnouncementsState extends State<MyAnnouncements> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<AddVancyModel> _myJobs = [];
  final ConstColors colors = ConstColors();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyJobs();
    });
  }

  Future<void> _fetchMyJobs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final userId = authProvider.userId;
    
    // For SEARCHER, we filter by their own userId
    // For GIVER, we also check enterprise ID
    final isGiver = authProvider.role == 'GIVER';
    final companyId = isGiver ? authProvider.enterprise?.id : userId;

    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final allJobs = await _apiService.getMyVacancies(token);

      print('DEBUG: MyAnnouncements - Role: ${authProvider.role}, userId: $userId, companyId: $companyId');
      final userJobs = allJobs.where((job) {
        if (job.companyId == null) return false;
        
        // Robust filtering:
        // 1. If ID matches companyId (Enterprise for GIVER, UserID for SEARCHER)
        // 2. Or if ID matches the direct UserID
        final match = job.companyId == companyId || job.companyId == userId;
        return match;
      }).toList();
      
      print('DEBUG: MyAnnouncements - total filtered jobs: ${userJobs.length}');

      // Enrich jobs with local user data if missing
      final enrichedJobs = userJobs.map((job) {
        // Fallback for company name
        if (job.companyName == null ||
            job.companyName!.isEmpty ||
            job.companyName == "Unknown") {
          job.companyName = authProvider.userName ?? "Moi";
        }

        // Fallback for location/city
        if (job.city.isEmpty || job.city == "Non spécifié") {
          job.city = isGiver 
              ? (authProvider.enterprise?.city ?? authProvider.enterprise?.adress ?? "Non spécifié")
              : "Non spécifié";
        }

        // Fallback for image
        if (job.companyImage == null ||
            job.companyImage!.isEmpty ||
            job.companyImage!.contains("placeholder")) {
          final userPhoto = authProvider.userPhoto;
          if (userPhoto != null && userPhoto.isNotEmpty) {
            job.companyImage = userPhoto;
          }
        }
        return job;
      }).toList();

      if (mounted) {
        setState(() {
          _myJobs = enrichedJobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching my jobs: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Mes Annonces",
          style: TextStyle(color: colors.bg, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: colors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowTurnBackward,
            color: colors.bg,
            size: 24,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: SpinKitPulse(color: colors.primary, size: 60.0))
          : _myJobs.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchMyJobs,
              color: colors.primary,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: _myJobs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildJobCard(_myJobs[index])
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 100 * index),
                          duration: 400.ms,
                        )
                        .slideY(begin: 0.1),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedJobLink,
              size: 60,
              color: colors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Aucune annonce publiée",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Vous n'avez pas encore publié d'offres d'emploi.",
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.secondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(AddVancyModel job) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => JobDetail(job: job)),
        // );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          job.companyImage ?? "https://via.placeholder.com/150",
                        ),
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
                            color: colors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.companyName ?? "Unknown",
                          style: TextStyle(
                            color: colors.secondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  _buildStatusChip(job),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    job.city.trim().isNotEmpty ? job.city : 'Non spécifié',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.work_outline, job.typeJobe),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade100),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMd().format(
                      DateTime.tryParse(job.createdAt ?? "") ??
                          DateTime.now(),
                    ),
                    style: TextStyle(color: colors.secondary, fontSize: 12),
                  ),
                  Text(
                    "${NumberFormat('#,###').format(job.salary)} GNF",
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(AddVancyModel job) {
    // Determine status logic (e.g., active vs expired based on deadline)
    final deadline = DateTime.tryParse(job.deadline);
    final isExpired = deadline != null && deadline.isBefore(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isExpired
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isExpired ? "Expiré" : "Actif",
            style: TextStyle(
              color: isExpired ? Colors.red : Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        //SizedBox(width: 5),
        PopupMenuButton<String>(
          style: ButtonStyle(),
          onSelected: (value) async {
            if (value == 'Modifier') {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobPostings(jobToEdit: job),
                ),
              );
              if (result == true) {
                _fetchMyJobs();
              }
            } else if (value == 'Supprimer') {
              _showDeleteConfirmation(job);
            }
          },
          color: colors.bg,
          borderRadius: BorderRadius.circular(20),
          iconColor: colors.primary,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'Modifier',
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // color: colors.accepted.withValues(alpha: 0.3),
                ),
                child: TitleWidget(
                  text: 'Modifier',
                  color: colors.accepted,
                  fontSize: 16,
                ),
              ),
            ),
            PopupMenuItem(
              value: 'Supprimer',
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  // color: colors.error.withValues(alpha: 0.3),
                ),
                child: TitleWidget(
                  text: 'Supprimer',
                  color: colors.error,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmation(AddVancyModel job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'annonce "${job.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final token = context.read<AuthProvider>().token;
              final success = await _apiService.deleteJobOffer(job.id!, token);
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Annonce supprimée')),
                );
                _fetchMyJobs();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Échec de la suppression')),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.secondary, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: colors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
