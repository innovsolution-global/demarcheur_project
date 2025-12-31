import 'dart:ui';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/widgets/immo_header.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BoostPage extends StatefulWidget {
  final HouseModel boost;
  const BoostPage({super.key, required this.boost});

  @override
  State<BoostPage> createState() => _BoostPageState();
}

class _BoostPageState extends State<BoostPage>
    with TickerProviderStateMixin {
  final ConstColors _colors = ConstColors();

  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late AnimationController _uploadController;
  late Animation<double> _cardAnimation;

  int _selectedPackageIndex = 1; // Default to Standard package
  bool _isProcessingPayment = false;
  // Boost packages data
  final List<BoostPackage> _packages = [
    BoostPackage(
      name: 'Basic',
      price: 25000,
      originalPrice: 35000,
      duration: '7 jours',
      color: Colors.blue,
      gradient: [Colors.blue.shade400, Colors.blue.shade600],
      icon: Icons.trending_up,
      features: [
        'Visibilité augmentée de 2x',
        'Apparition dans les suggestions',
        'Badge "En vedette"',
        'Support email',
      ],
      benefits: [
        '+150% de vues en moyenne',
        '+80% de contacts',
        '+60% de favoris',
      ],
      isPopular: false,
    ),
    BoostPackage(
      name: 'Standard',
      price: 45000,
      originalPrice: 65000,
      duration: '14 jours',
      color: Colors.orange,
      gradient: [Colors.orange.shade400, Colors.orange.shade600],
      icon: Icons.rocket_launch,
      features: [
        'Visibilité augmentée de 5x',
        'Position prioritaire',
        'Badge "Super vedette"',
        'Notifications push',
        'Statistiques avancées',
        'Support prioritaire',
      ],
      benefits: [
        '+300% de vues en moyenne',
        '+200% de contacts',
        '+150% de favoris',
        'Portée géographique étendue',
      ],
      isPopular: true,
    ),
    BoostPackage(
      name: 'Premium',
      price: 75000,
      originalPrice: 100000,
      duration: '30 jours',
      color: Colors.purple,
      gradient: [Colors.purple.shade400, Colors.purple.shade600],
      icon: Icons.star,
      features: [
        'Visibilité maximale 10x',
        'Top position garantie',
        'Badge "Premium Gold"',
        'Campagne publicitaire',
        'Analytics complets',
        'Support 24/7',
        'Réseaux sociaux inclus',
        'Photos professionnelles (1 séance)',
      ],
      benefits: [
        '+500% de vues en moyenne',
        '+400% de contacts',
        '+300% de favoris',
        'Couverture nationale',
        'Garantie de résultats',
      ],
      isPopular: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _uploadController.forward();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _cardAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _uploadController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _processBoost() async {
    setState(() => _isProcessingPayment = true);
    HapticFeedback.mediumImpact();

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isProcessingPayment = false);

      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        _uploadController.forward();
        return ScaleTransition(
          scale: _uploadController,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Boost Activé!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre propriété est maintenant boostée et bénéficie d\'une visibilité maximale!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Parfait!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                        _buildPropertyPreview(),
                        _buildBenefitsSection(),
                        _buildPackageSelector(),
                        _buildSelectedPackageDetails(),
                        _buildPaymentSection(),
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
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _colors.primary.withOpacity(0.1),
            _colors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.rocket_launch, color: _colors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          TitleWidget(
            text: "Boostez votre propriété",
            fontSize: 26,
            color: _colors.secondary,
          ),
          const SizedBox(height: 8),
          SubTitle(
            text:
                "Augmentez la visibilité et attirez plus d'acheteurs potentiels",
            fontsize: 16,
            color: _colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  widget.boost.imageUrl.first,
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
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'À booster',
                    style: TextStyle(
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.boost.type} • ${widget.boost.category}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _colors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: _colors.primary, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.boost.location,
                        style: TextStyle(color: _colors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${NumberFormat('#,###').format(widget.boost.rent).replaceAll(',', '.')} GNF/mois",
                  style: TextStyle(
                    fontSize: 20,
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

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.visibility,
        'title': 'Plus de visibilité',
        'desc': 'Votre annonce apparaîtra en premier',
      },
      {
        'icon': Icons.people,
        'title': 'Plus de contacts',
        'desc': 'Augmentez vos chances de trouver un locataire',
      },
      {
        'icon': Icons.schedule,
        'title': 'Résultats rapides',
        'desc': 'Effets visibles dès les premières heures',
      },
      {
        'icon': Icons.trending_up,
        'title': 'Meilleur ROI',
        'desc': 'Rentabilisez votre investissement rapidement',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pourquoi booster?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _colors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final benefit = benefits[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _colors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        benefit['icon'] as IconData,
                        color: _colors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      benefit['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _colors.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      benefit['desc'] as String,
                      style: TextStyle(fontSize: 12, color: _colors.primary),
                      textAlign: TextAlign.center,
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

  Widget _buildPackageSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choisissez votre pack",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _colors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _cardAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _cardAnimation.value,
                child: Column(
                  children: _packages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final package = entry.value;
                    final isSelected = _selectedPackageIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedPackageIndex = index);
                        HapticFeedback.selectionClick();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: package.gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : _colors.tertiary.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? package.color.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: isSelected ? 15 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            if (package.isPopular)
                              Positioned(
                                top: -10,
                                right: -10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'POPULAIRE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : package.color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    package.icon,
                                    color: isSelected
                                        ? Colors.white
                                        : package.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package.name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : _colors.secondary,
                                        ),
                                      ),
                                      Text(
                                        package.duration,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.8)
                                              : _colors.tertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (package.originalPrice > package.price)
                                      Text(
                                        "${NumberFormat('#,###').format(package.originalPrice).replaceAll(',', '.')} GNF",
                                        style: TextStyle(
                                          fontSize: 14,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.grey,
                                        ),
                                      ),
                                    Text(
                                      "${NumberFormat('#,###').format(package.price).replaceAll(',', '.')} GNF",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : package.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPackageDetails() {
    final selectedPackage = _packages[_selectedPackageIndex];

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
              Icon(Icons.featured_play_list, color: selectedPackage.color),
              const SizedBox(width: 8),
              Text(
                "Fonctionnalités incluses",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _colors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...selectedPackage.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: selectedPackage.color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(color: _colors.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.trending_up, color: selectedPackage.color),
              const SizedBox(width: 8),
              Text(
                "Résultats attendus",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _colors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...selectedPackage.benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(color: _colors.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final selectedPackage = _packages[_selectedPackageIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: selectedPackage.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total à payer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (selectedPackage.originalPrice >
                            selectedPackage.price)
                          Text(
                            "${NumberFormat('#,###').format(selectedPackage.originalPrice).replaceAll(',', '.')} GNF",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          "${NumberFormat('#,###').format(selectedPackage.price).replaceAll(',', '.')} GNF",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (selectedPackage.originalPrice > selectedPackage.price) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Économisez ${NumberFormat('#,###').format(selectedPackage.originalPrice - selectedPackage.price).replaceAll(',', '.')} GNF",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isProcessingPayment ? null : _processBoost,
              icon: _isProcessingPayment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.payment, size: 24),
              label: Text(
                _isProcessingPayment ? "Traitement..." : "Booster maintenant",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPackage.color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: selectedPackage.color.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Paiement sécurisé • Activé instantanément",
            style: TextStyle(fontSize: 12, color: _colors.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class BoostPackage {
  final String name;
  final int price;
  final int originalPrice;
  final String duration;
  final Color color;
  final List<Color> gradient;
  final IconData icon;
  final List<String> features;
  final List<String> benefits;
  final bool isPopular;

  BoostPackage({
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.duration,
    required this.color,
    required this.gradient,
    required this.icon,
    required this.features,
    required this.benefits,
    required this.isPopular,
  });
}
