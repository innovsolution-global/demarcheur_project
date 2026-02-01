import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/candidature_detail_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/candidate_model.dart';
import 'package:demarcheur_app/providers/candidature_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class JobApplicantsPage extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobApplicantsPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobApplicantsPage> createState() => _JobApplicantsPageState();
}

class _JobApplicantsPageState extends State<JobApplicantsPage> {
  final ConstColors colors = ConstColors();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = context.read<AuthProvider>().token;
      context.read<CandidatureProvider>().fetchApplicants(widget.jobId, token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<CandidatureProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              if (provider.isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: SpinKitFadingCube(color: colors.primary, size: 40.0),
                  ),
                )
              else if (provider.errorMessage != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedAlert01,
                            color: colors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (provider.applicants.isEmpty)
                _buildEmptyState()
              else
                _buildApplicantsList(provider.applicants),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar.large(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          color: colors.primary,
          size: 24,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16, right: 20),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Candidatures",
              style: TextStyle(
                color: colors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              widget.jobTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              final token = context.read<AuthProvider>().token;
              context.read<CandidatureProvider>().fetchApplicants(
                widget.jobId,
                token,
              );
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedRefresh,
              color: colors.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUserGroup,
                color: colors.primary.withOpacity(0.3),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Aucun candidat pour le moment",
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Les nouvelles candidatures apparaîtront ici",
              style: TextStyle(color: colors.secondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantsList(List<CandidateModel> applicants) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final applicant = applicants[index];
          return _buildApplicantCard(applicant);
        }, childCount: applicants.length),
      ),
    );
  }

  Widget _buildApplicantCard(CandidateModel applicant) {
    final user = applicant.applicant;
    final date = applicant.createdAt != null
        ? DateTime.tryParse(applicant.createdAt!)
        : null;
    final formattedDate = date != null
        ? DateFormat('dd MMM yyyy').format(date)
        : 'Date inconnue';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            if (applicant.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CandidatureDetailPage(
                    candidatureId: applicant.id!,
                    applicantName: user?.name ?? 'Candidat',
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: colors.primary.withOpacity(0.1),
                    image: user?.photo != null
                        ? DecorationImage(
                            image: NetworkImage(user!.photo),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user?.photo == null || user!.photo.isEmpty
                      ? Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            color: colors.primary,
                            size: 28,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? "Candidat anonyme",
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (user?.email != null) ...[
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedMail01,
                              color: colors.secondary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                user!.email!,
                                style: TextStyle(
                                  color: colors.secondary,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar03,
                            color: colors.secondary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: colors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(applicant.status ?? 'En attente'),
                const SizedBox(width: 8),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: Colors.grey.shade300,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'accepte':
        statusColor = const Color(0xFF10B981);
        bgColor = const Color(0xFFD1FAE5);
        break;
      case 'refuse':
        statusColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
