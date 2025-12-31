import 'package:demarcheur_app/apps/demandeurs/main_screens/boost_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ConstColors colors = ConstColors();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Statistiques",
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(colors),
            const SizedBox(height: 24),
            _buildChartSection(colors),
            const SizedBox(height: 24),
            _buildRecentActivity(colors),
            const SizedBox(height: 24),
            _buildBoostSection(context, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(ConstColors colors) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            colors: colors,
            title: "Vues totales",
            value: "1,234",
            icon: HugeIcons.strokeRoundedView,
            trend: "+12%",
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            colors: colors,
            title: "Candidatures",
            value: "56",
            icon: HugeIcons.strokeRoundedUserGroup,
            trend: "+5%",
            isPositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(ConstColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performance",
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      "Cette semaine",
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Bar(height: 0.4, label: "Lun", colors: colors),
                _Bar(height: 0.6, label: "Mar", colors: colors),
                _Bar(height: 0.3, label: "Mer", colors: colors),
                _Bar(height: 0.8, label: "Jeu", colors: colors, isActive: true),
                _Bar(height: 0.5, label: "Ven", colors: colors),
                _Bar(height: 0.2, label: "Sam", colors: colors),
                _Bar(height: 0.4, label: "Dim", colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(ConstColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Activité récente",
          style: TextStyle(
            color: colors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _ActivityItem(
                colors: colors,
                title: "Nouvelle candidature",
                subtitle: "Développeur Flutter Senior",
                time: "Il y a 2h",
                icon: HugeIcons.strokeRoundedDocumentCode,
              ),
              Divider(height: 1, color: Colors.grey.shade100),
              _ActivityItem(
                colors: colors,
                title: "Annonce boostée",
                subtitle: "Designer UI/UX",
                time: "Il y a 5h",
                icon: HugeIcons.strokeRoundedRocket,
              ),
              Divider(height: 1, color: Colors.grey.shade100),
              _ActivityItem(
                colors: colors,
                title: "Message reçu",
                subtitle: "De Jean Dupont",
                time: "Il y a 1j",
                icon: HugeIcons.strokeRoundedMessage01,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoostSection(BuildContext context, ConstColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const HugeIcon(icon:
              HugeIcons.strokeRoundedRocket,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Booster votre visibilité",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Obtenez jusqu'à 3x plus de vues",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BoostPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              "Booster",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ConstColors colors;
  final String title;
  final String value;
  final List<List<dynamic>> icon;
  final String trend;
  final bool isPositive;

  const _StatCard({
    required this.colors,
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(icon:icon, color: colors.primary, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? colors.accepted.withOpacity(0.1)
                      : colors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: isPositive ? colors.accepted : colors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        color: isPositive ? colors.accepted : colors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: colors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: colors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final String label;
  final ConstColors colors;
  final bool isActive;

  const _Bar({
    required this.height,
    required this.label,
    required this.colors,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: 150 * height,
          decoration: BoxDecoration(
            color: isActive ? colors.primary : colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? colors.primary : colors.secondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ConstColors colors;
  final String title;
  final String subtitle;
  final String time;
  final List<List<dynamic>> icon;

  const _ActivityItem({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HugeIcon(icon:  icon, color: colors.primary, size: 20),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: colors.secondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: colors.tertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
