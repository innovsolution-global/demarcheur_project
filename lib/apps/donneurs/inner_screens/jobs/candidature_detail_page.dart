import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/candidate_model.dart';
import 'package:demarcheur_app/providers/candidature_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CandidatureDetailPage extends StatefulWidget {
  final String candidatureId;
  final String applicantName;

  const CandidatureDetailPage({
    super.key,
    required this.candidatureId,
    required this.applicantName,
  });

  @override
  State<CandidatureDetailPage> createState() => _CandidatureDetailPageState();
}

class _CandidatureDetailPageState extends State<CandidatureDetailPage> {
  final ConstColors colors = ConstColors();
  CandidateModel? _candidature;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final token = context.read<AuthProvider>().token;
    final result = await context
        .read<CandidatureProvider>()
        .fetchCandidatureDetail(widget.candidatureId, token);
    if (mounted) {
      setState(() {
        _candidature = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Détail de la candidature",
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
      ),
      body: Consumer<CandidatureProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: SpinKitFadingCube(
                color: colors.primary,
                size: 40.0,
              ),
            );
          }

          if (_candidature == null) {
            return Center(
              child: Text(
                provider.errorMessage ?? "Impossible de charger les détails",
                style: TextStyle(color: colors.secondary),
              ),
            );
          }

          return _buildContent(_candidature!);
        },
      ),
    );
  }

  Widget _buildContent(CandidateModel candidature) {
    final user = candidature.applicant;
    final date = candidature.createdAt != null
        ? DateTime.tryParse(candidature.createdAt!)
        : null;
    final formattedDate =
        date != null ? DateFormat('dd MMM yyyy à HH:mm').format(date) : 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withOpacity(0.1),
                    image: user?.photo != null && user!.photo.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(user.photo),
                        fit: BoxFit.cover,
                      )
                    : null,
                  ),
                  child: user?.photo == null || user!.photo.isEmpty
                      ? Icon(Icons.person, size: 50, color: colors.primary)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? widget.applicantName,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (user?.email != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedMail01,
                          color: colors.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user!.email!,
                          style: TextStyle(
                            color: colors.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Status & Date
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  "Statut",
                  candidature.status ?? "En attente",
                  HugeIcons.strokeRoundedInformationCircle,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  "Date de candidature",
                  formattedDate,
                  HugeIcons.strokeRoundedCalendar03,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CV Section
          Text(
            "Documents",
            style: TextStyle(
              color: colors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (candidature.cvUrl != null || user?.document != null)
             _buildDocumentCard(candidature.cvUrl ?? user!.document!, "CV / Document"),
          if (candidature.cvUrl == null && user?.document == null)
            Text(
              "Aucun document fourni",
              style: TextStyle(color: colors.secondary),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String url, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2), // Red for PDF/Doc
              borderRadius: BorderRadius.circular(12),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedFile02,
              color: const Color(0xFFEF4444),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Cliquez pour ouvrir",
                  style: TextStyle(
                    color: colors.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
               if (await canLaunchUrl(Uri.parse(url))) {
                 await launchUrl(Uri.parse(url));
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Impossible d'ouvrir le document")),
                 );
               }
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedView,
              color: colors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, List<List<dynamic>> icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: HugeIcon(
            icon: icon,
            color: colors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: colors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
