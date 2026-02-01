import 'package:demarcheur_app/apps/prestataires/presta_dashboard.dart'
    show PrestaDashboard;
import 'package:demarcheur_app/consts/color.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrestataireSelectPage extends StatefulWidget {
  const PrestataireSelectPage({super.key});

  @override
  State<PrestataireSelectPage> createState() => _PrestataireSelectPageState();
}

class _PrestataireSelectPageState extends State<PrestataireSelectPage>
    with TickerProviderStateMixin {
  final ConstColors _colors = ConstColors();

  late AnimationController _animationController;
  late AnimationController _selectionAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final Set<String> _selectedSpecialties = {};
  String? _selectedCategory;

  final Map<String, List<Map<String, dynamic>>> _specialtyCategories = {
    'Construction & Bâtiment': [
      {
        'name': 'Maçonnerie',
        'icon': Icons.construction,
        'description': 'Construction et réparation de murs',
      },
      {
        'name': 'Plomberie',
        'icon': Icons.plumbing,
        'description': 'Installation et réparation sanitaire',
      },
      {
        'name': 'Électricité',
        'icon': Icons.electrical_services,
        'description': 'Installation électrique et dépannage',
      },
      {
        'name': 'Carrelage',
        'icon': Icons.grid_on,
        'description': 'Pose et rénovation de carrelage',
      },
      {
        'name': 'Peinture',
        'icon': Icons.format_paint,
        'description': 'Peinture intérieure et extérieure',
      },
      {
        'name': 'Toiture',
        'icon': Icons.roofing,
        'description': 'Réparation et installation de toiture',
      },
      {
        'name': 'Menuiserie',
        'icon': Icons.carpenter,
        'description': 'Travaux du bois et mobilier',
      },
      {
        'name': 'Climatisation',
        'icon': Icons.ac_unit,
        'description': 'Installation et maintenance climatisation',
      },
    ],
    'Entretien & Nettoyage': [
      {
        'name': 'Nettoyage Maison',
        'icon': Icons.cleaning_services,
        'description': 'Nettoyage domestique complet',
      },
      {
        'name': 'Jardinage',
        'icon': Icons.grass,
        'description': 'Entretien jardins et espaces verts',
      },
      {
        'name': 'Blanchisserie',
        'icon': Icons.local_laundry_service,
        'description': 'Lavage et repassage',
      },
      {
        'name': 'Désinfection',
        'icon': Icons.sanitizer,
        'description': 'Désinfection et assainissement',
      },
      {
        'name': 'Nettoyage Vitres',
        'icon': Icons.window,
        'description': 'Nettoyage professionnel vitres',
      },
      {
        'name': 'Entretien Piscine',
        'icon': Icons.pool,
        'description': 'Maintenance et nettoyage piscines',
      },
    ],
    'Automobile & Mécanique': [
      {
        'name': 'Mécanique Auto',
        'icon': Icons.build,
        'description': 'Réparation véhicules',
      },
      {
        'name': 'Électricité Auto',
        'icon': Icons.power,
        'description': 'Système électrique véhicules',
      },
      {
        'name': 'Carrosserie',
        'icon': Icons.directions_car,
        'description': 'Réparation et peinture carrosserie',
      },
      {
        'name': 'Climatisation Auto',
        'icon': Icons.ac_unit,
        'description': 'Climatisation véhicules',
      },
      {
        'name': 'Lavage Auto',
        'icon': Icons.local_car_wash,
        'description': 'Nettoyage professionnel véhicules',
      },
      {
        'name': 'Dépannage',
        'icon': Icons.emergency_share,
        'description': 'Dépannage routier 24h/24',
      },
    ],
    'Réparation & Maintenance': [
      {
        'name': 'Électroménager',
        'icon': Icons.kitchen,
        'description': 'Réparation appareils ménagers',
      },
      {
        'name': 'Informatique',
        'icon': Icons.computer,
        'description': 'Réparation ordinateurs et téléphones',
      },
      {
        'name': 'Serrurerie',
        'icon': Icons.lock,
        'description': 'Installation et ouverture serrures',
      },
      {
        'name': 'Soudure',
        'icon': Icons.construction,
        'description': 'Travaux de soudure métallique',
      },
      {
        'name': 'Réparation Moto',
        'icon': Icons.two_wheeler,
        'description': 'Entretien et réparation motos',
      },
      {
        'name': 'Horlogerie',
        'icon': Icons.watch,
        'description': 'Réparation montres et horloges',
      },
    ],
    'Services Personnels': [
      {
        'name': 'Coiffure',
        'icon': Icons.content_cut,
        'description': 'Services de coiffure à domicile',
      },
      {
        'name': 'Esthétique',
        'icon': Icons.spa,
        'description': 'Soins esthétiques et beauté',
      },
      {
        'name': 'Massage',
        'icon': Icons.healing,
        'description': 'Massage thérapeutique et détente',
      },
      {
        'name': 'Fitness',
        'icon': Icons.fitness_center,
        'description': 'Coach sportif personnel',
      },
      {
        'name': 'Couture',
        'icon': Icons.design_services,
        'description': 'Retouches et confection vêtements',
      },
      {
        'name': 'Photographie',
        'icon': Icons.camera_alt,
        'description': 'Services photographiques',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Set first category as default
    _selectedCategory = _specialtyCategories.keys.first;
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _selectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _selectionAnimationController.dispose();
    super.dispose();
  }

  void _toggleSpecialty(String specialty) {
    setState(() {
      if (_selectedSpecialties.contains(specialty)) {
        _selectedSpecialties.remove(specialty);
      } else {
        _selectedSpecialties.add(specialty);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _proceedToNext() {
    if (_selectedSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner au moins une spécialité'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrestaDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors.bg,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 50),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: CustomScrollView(
                slivers: [
                  _buildModernHeader(),
                  _buildCategoryTabs(),
                  _buildSpecialtyGrid(),
                  _buildSelectedSummary(),
                  _buildContinueButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_colors.primary, _colors.primary.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Vos Spécialités",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sélectionnez vos domaines d'expertise",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      "${_selectedSpecialties.length} spécialité${_selectedSpecialties.length > 1 ? 's' : ''} sélectionnée${_selectedSpecialties.length > 1 ? 's' : ''}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _specialtyCategories.keys.length,
          itemBuilder: (context, index) {
            final category = _specialtyCategories.keys.toList()[index];
            final isSelected = _selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = category);
                    HapticFeedback.selectionClick();
                  }
                },
                backgroundColor: Colors.white,
                selectedColor: _colors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : _colors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? _colors.primary : Colors.grey[300]!,
                  ),
                ),
                elevation: isSelected ? 4 : 0,
                shadowColor: _colors.primary.withOpacity(0.3),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpecialtyGrid() {
    final specialties = _specialtyCategories[_selectedCategory!]!;

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final specialty = specialties[index];
          final isSelected = _selectedSpecialties.contains(specialty['name']);

          return _buildSpecialtyCard(
            name: specialty['name'],
            icon: specialty['icon'],
            description: specialty['description'],
            isSelected: isSelected,
            onTap: () => _toggleSpecialty(specialty['name']),
          );
        }, childCount: specialties.length),
      ),
    );
  }

  Widget _buildSpecialtyCard({
    required String name,
    required IconData icon,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? _colors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _colors.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _colors.primary.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : _colors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: isSelected ? Colors.white : _colors.primary,
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                //const SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : _colors.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                //const SizedBox(height: 4),
                Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : _colors.primary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSummary() {
    if (_selectedSpecialties.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _colors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: _colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Spécialités sélectionnées',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _colors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSpecialties.map((specialty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _colors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: _colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _toggleSpecialty(specialty),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: _colors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _proceedToNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: _colors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Continuer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_forward, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
