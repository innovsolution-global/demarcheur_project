import 'dart:math';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/widgets/immo_header.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ImmoStatisticPage extends StatefulWidget {
  final HouseModel house;
  const ImmoStatisticPage({super.key, required this.house});

  @override
  State<ImmoStatisticPage> createState() => _ImmoStatisticPageState();
}

class _ImmoStatisticPageState extends State<ImmoStatisticPage>
    with TickerProviderStateMixin {
  final ConstColors _colors = ConstColors();

  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _chartAnimation;

  String _selectedPeriod = '7 jours';
  bool _isPropertyAvailable = true;
  bool _isUpdatingStatus = false;

  // Mock statistics data
  final Map<String, Map<String, int>> _statisticsData = {
    '7 jours': {'views': 234, 'favorites': 18, 'contacts': 12, 'visits': 8},
    '30 jours': {'views': 892, 'favorites': 67, 'contacts': 45, 'visits': 28},
    '6 mois': {'views': 3456, 'favorites': 234, 'contacts': 156, 'visits': 89},
  };

  final List<String> _periods = ['7 jours', '30 jours', '6 mois'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _isPropertyAvailable = widget.house.status == 'Disponible';
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _chartAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _updatePropertyStatus() async {
    setState(() => _isUpdatingStatus = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isPropertyAvailable = !_isPropertyAvailable;
      _isUpdatingStatus = false;
    });

    _showSnackBar(
      _isPropertyAvailable
          ? 'Propriété marquée comme disponible'
          : 'Propriété marquée comme non disponible',
    );

    HapticFeedback.lightImpact();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : _colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors.bg,
      body: CustomScrollView(
        slivers: [
          const ImmoHeader(auto: true),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 50),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildPropertyCard(),
                        _buildStatusControl(),
                        _buildPeriodSelector(),
                        _buildStatisticsCards(),
                        _buildPerformanceChart(),
                        _buildDetailedAnalytics(),
                        _buildActionButtons(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleWidget(
            text: "Statistiques",
            fontSize: 28,
            color: _colors.secondary,
          ),
          const SizedBox(height: 8),
          SubTitle(
            text: "Analysez les performances de votre propriété",
            fontsize: 16,
            color: _colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  widget.house.imageUrl.first,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.home, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isPropertyAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isPropertyAvailable ? 'Disponible' : 'Non disponible',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.house.type} • ${widget.house.category}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _colors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: _colors.primary, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.house.location,
                        style: TextStyle(fontSize: 16, color: _colors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "${NumberFormat('#,###').format(widget.house.rent).replaceAll(',', '.')} GNF/mois",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: _colors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                "Gestion de disponibilité",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _colors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Marquer cette propriété comme ${_isPropertyAvailable ? 'non disponible' : 'disponible'}",
                  style: TextStyle(fontSize: 16, color: _colors.primary),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isUpdatingStatus ? null : _updatePropertyStatus,
                icon: _isUpdatingStatus
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _isPropertyAvailable
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                label: Text(_isPropertyAvailable ? 'Masquer' : 'Publier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPropertyAvailable
                      ? Colors.red
                      : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Text(
            "Période: ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _colors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(period),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedPeriod = period);
                        HapticFeedback.lightImpact();
                        _chartAnimationController.reset();
                        _chartAnimationController.forward();
                      },
                      backgroundColor: Colors.white,
                      selectedColor: _colors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _colors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? _colors.primary
                              : Colors.grey[300]!,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final stats = _statisticsData[_selectedPeriod]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Aperçu des performances",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _colors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _StatisticCard(
                icon: Icons.visibility,
                title: 'Vues',
                value: stats['views']!,
                color: Colors.blue,
                growth: '+12%',
              ),

              _StatisticCard(
                icon: Icons.message,
                title: 'Contacts',
                value: stats['contacts']!,
                color: Colors.green,
                growth: '+15%',
              ),
              _StatisticCard(
                icon: Icons.calendar_today,
                title: 'Visites',
                value: stats['visits']!,
                color: Colors.purple,
                growth: '+5%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    final stats = _statisticsData[_selectedPeriod]!;
    final maxValue = stats.values.reduce(max).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Graphique de performance",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _colors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ChartBar(
                      label: 'Vues',
                      value: stats['views']!,
                      maxValue: maxValue,
                      color: Colors.blue,
                      animation: _chartAnimation.value,
                    ),
                    _ChartBar(
                      label: 'Contacts',
                      value: stats['contacts']!,
                      maxValue: maxValue,
                      color: Colors.green,
                      animation: _chartAnimation.value,
                    ),
                    _ChartBar(
                      label: 'Visites',
                      value: stats['visits']!,
                      maxValue: maxValue,
                      color: Colors.purple,
                      animation: _chartAnimation.value,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalytics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Analyses détaillées",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _colors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          _AnalyticsRow(
            icon: Icons.trending_up,
            title: 'Taux de conversion',
            value: '3.2%',
            subtitle: 'Vues → Contacts',
            color: Colors.green,
          ),
          const Divider(),
          _AnalyticsRow(
            icon: Icons.schedule,
            title: 'Temps moyen sur la page',
            value: '2m 34s',
            subtitle: 'Temps d\'engagement',
            color: Colors.blue,
          ),
          const Divider(),
          _AnalyticsRow(
            icon: Icons.star_rate,
            title: 'Note moyenne',
            value: widget.house.rate.toString(),
            subtitle: 'Basé sur ${Random().nextInt(20) + 5} avis',
            color: Colors.amber,
          ),
          const Divider(),
          _AnalyticsRow(
            icon: Icons.share,
            title: 'Partages',
            value: '${Random().nextInt(50) + 10}',
            subtitle: 'Sur les réseaux sociaux',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSnackBar('Fonction d\'édition à venir'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _colors.primary,
                    side: BorderSide(color: _colors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSnackBar('Rapport exporté avec succès'),
                  icon: const Icon(Icons.download),
                  label: const Text('Exporter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showSnackBar('Promotion boostée!'),
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Booster cette annonce'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final Color color;
  final String growth;

  const _StatisticCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  growth,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat('#,###').format(value).replaceAll(',', '.'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ConstColors().secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String label;
  final int value;
  final double maxValue;
  final Color color;
  final double animation;

  const _ChartBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedHeight = (value / maxValue) * 150 * animation;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          NumberFormat('#,###').format(value).replaceAll(',', '.'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ConstColors().secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: normalizedHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _AnalyticsRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ConstColors().secondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
