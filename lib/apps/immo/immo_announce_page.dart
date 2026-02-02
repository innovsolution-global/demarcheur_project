import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class ImmoAnnouncePage extends StatefulWidget {
  const ImmoAnnouncePage({super.key});

  @override
  State<ImmoAnnouncePage> createState() => _ImmoAnnouncePageState();
}

class _ImmoAnnouncePageState extends State<ImmoAnnouncePage>
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
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      final companyId = auth.userId;
      context.read<HouseProvider>().loadHous(
        token: token,
        companyId: companyId,
      );
      _fadeController.forward();
    });
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
        body: Consumer<HouseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            final myProperties = provider.housefiltered;

            if (myProperties.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                final auth = context.read<AuthProvider>();
                await provider.loadHous(
                  token: auth.token,
                  companyId: auth.userId,
                );
              },
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: myProperties.length,
                  itemBuilder: (context, index) {
                    return _buildPropertyCard(myProperties[index]);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPropertyCard(HouseModel house) {
    final currencyFormat = NumberFormat('#,###', 'fr_FR');
    final price = house.price ?? house.rent ?? 0;

    return GestureDetector(
      onTap: () => _showPropertyDetails(house),
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
                if (house.imageUrl.isNotEmpty)
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(house.imageUrl.first),
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
                              house.title ?? house.countType ?? 'Sans titre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.secondary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (house.location != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedLocation01,
                                size: 14,
                                color: colors.secondary.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  house.location!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: colors.secondary.withOpacity(0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
                  HugeIcons.strokeRoundedBedDouble,
                  "${house.rooms ?? 0} p",
                ),
                const SizedBox(width: 8),
                _buildInfoBadge(
                  HugeIcons.strokeRoundedShapeCollection,
                  "${house.area ?? 0} m²",
                ),
                const Spacer(),
                Text(
                  "${currencyFormat.format(price)} GNF",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
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
            "Aucun poste publié",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Commencez par publier votre première propriété",
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

  void _showPropertyDetails(HouseModel house) {
    final currencyFormat = NumberFormat('#,###', 'fr_FR');
    final price = house.price ?? house.rent ?? 0;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                house.title ?? house.countType ?? 'Sans titre',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: colors.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                house.location ?? 'Lieu non spécifié',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colors.secondary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${currencyFormat.format(price)} GNF",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildQuickSpecs(house),
                    const SizedBox(height: 24),
                    if (house.description != null &&
                        house.description!.isNotEmpty)
                      _buildDetailSection("Description", house.description!),
                    if (house.advantage != null && house.advantage!.isNotEmpty)
                      _buildDetailSection("Avantages", house.advantage!),
                    if (house.condition != null && house.condition!.isNotEmpty)
                      _buildDetailSection("Conditions", house.condition!),
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

  Widget _buildQuickSpecs(HouseModel house) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 16,
        children: [
          _buildSpecItem(
            HugeIcons.strokeRoundedBedDouble,
            "Chambres",
            "${house.rooms ?? 0}",
          ),
          _buildSpecItem(
            HugeIcons.strokeRoundedSofa01,
            "Salons",
            "${house.livingRooms ?? 0}",
          ),
          _buildSpecItem(
            HugeIcons.strokeRoundedStarFace,
            "Surface",
            "${house.area ?? 0} m²",
          ),
          _buildSpecItem(
            HugeIcons.strokeRoundedHouse01,
            "Garage",
            "${house.garage ?? 0}",
          ),
          _buildSpecItem(
            HugeIcons.strokeRoundedTree01,
            "Jardin",
            house.garden == true ? "Oui" : "Non",
          ),
          _buildSpecItem(
            HugeIcons.strokeRoundedSwimming,
            "Piscine",
            "${house.piscine ?? 0}",
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(List<List<dynamic>> icon, String label, String value) {
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(
            icon: icon,
            color: colors.secondary.withOpacity(0.4),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.secondary.withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.secondary,
            ),
          ),
        ],
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
}
