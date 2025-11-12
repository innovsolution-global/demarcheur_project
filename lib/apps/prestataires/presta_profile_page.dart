import 'dart:ui';
import 'package:demarcheur_app/widgets/btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PrestaProfilePage extends StatefulWidget {
  const PrestaProfilePage({super.key});

  @override
  State<PrestaProfilePage> createState() => _PrestaProfilePageState();
}

class _PrestaProfilePageState extends State<PrestaProfilePage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _pageAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _pulseAnimationController;

  // Animations
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  bool _isEditing = false;
  bool _isAvailable = true;
  double _headerHeight = 0;

  String _profileImageUrl =
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80";

  // Service Provider Data
  final Map<String, dynamic> _providerProfile = {
    'fullName': 'Mamadou Diallo',
    'email': 'mamadou.diallo@gmail.com',
    'phone': '+224 628 55 77 99',
    'location': 'Kaloum, Conakry',
    'profession': 'Électricien Professionnel',
    'experience': '8 ans',
    'rating': 4.9,
    'completedJobs': 156,
    'responseTime': '2h',
    'bio':
        'Électricien professionnel avec plus de 8 ans d\'expérience dans l\'installation et la réparation électrique résidentielle et commerciale. Spécialisé dans les solutions énergétiques durables.',
  };

  final List<Map<String, dynamic>> _skills = [
    {
      'name': 'Installation Électrique',
      'level': 0.95,
      'color': Color(0xFF4CAF50),
      'icon': Icons.electrical_services,
    },
    {
      'name': 'Réparation Électroménager',
      'level': 0.85,
      'color': Color(0xFF2196F3),
      'icon': Icons.home_repair_service,
    },
    {
      'name': 'Dépannage Urgence',
      'level': 0.90,
      'color': Color(0xFFFF9800),
      'icon': Icons.emergency,
    },
    {
      'name': 'Maintenance Préventive',
      'level': 0.80,
      'color': Color(0xFF9C27B0),
      'icon': Icons.build_circle,
    },
  ];

  final List<Map<String, dynamic>> _portfolioItems = [
    {
      'title': 'Installation Villa Moderne',
      'description': 'Installation électrique complète avec domotique',
      'image':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      'date': 'Décembre 2023',
      'category': 'Résidentiel',
      'rating': 5.0,
    },
    {
      'title': 'Rénovation Bureau',
      'description': 'Modernisation système électrique 200m²',
      'image':
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400&q=80',
      'date': 'Novembre 2023',
      'category': 'Commercial',
      'rating': 4.8,
    },
    {
      'title': 'Dépannage Express',
      'description': 'Intervention d\'urgence en moins d\'1h',
      'image':
          'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=400&q=80',
      'date': 'Octobre 2023',
      'category': 'Urgence',
      'rating': 5.0,
    },
  ];

  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'Expert Certifié',
      'description': 'Certification professionnelle validée',
      'icon': Icons.verified_user,
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Top Prestataire',
      'description': 'Dans le top 5% de la région',
      'icon': Icons.star,
      'color': Color(0xFFFFD700),
    },
    {
      'title': 'Service Rapide',
      'description': 'Temps de réponse < 2h',
      'icon': Icons.speed,
      'color': Color(0xFF2196F3),
    },
    {
      'title': 'Client Satisfait',
      'description': '98% de satisfaction client',
      'icon': Icons.favorite,
      'color': Color(0xFFE91E63),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideInAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageAnimationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pageAnimationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _headerHeight = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _floatingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _profileImageUrl = image.path;
        });
        _showSnackBar('Photo de profil mise à jour avec succès', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Erreur lors du téléchargement', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _toggleAvailability() {
    setState(() {
      _isAvailable = !_isAvailable;
    });
    HapticFeedback.mediumImpact();
    _showSnackBar(
      _isAvailable
          ? 'Vous êtes maintenant disponible'
          : 'Mode indisponible activé',
      _isAvailable ? Colors.green : Colors.orange,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnimatedBuilder(
        animation: _pageAnimationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideInAnimation,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildModernHeader(),
                  SliverToBoxAdapter(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          _buildQuickActionsCard(),
                          _buildAvailabilityCard(),
                          _buildStatsGrid(),
                          _buildAchievementsSection(),
                          _buildSkillsCard(),
                          _buildPortfolioSection(),
                          _buildPersonalInfoCard(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // floatingActionButton: AnimatedBuilder(
      //   animation: _floatingAnimationController,
      //   builder: (context, child) {
      //     return Transform.translate(
      //       offset: Offset(0, _floatingAnimationController.value * 4),
      //       child: FloatingActionButton.extended(
      //         onPressed: () => _showSnackBar('Modifier le profil', Colors.blue),
      //         backgroundColor: const Color(0xFF0C315A),
      //         icon: const Icon(Icons.edit, color: Colors.white),
      //         label: const Text(
      //           'Modifier',
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontWeight: FontWeight.w600,
      //           ),
      //         ),
      //         elevation: 8,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(16),
      //         ),
      //       ),
      //     );
      //   },
      // ),
    );
  }

  Widget _buildModernHeader() {
    return SliverAppBar(
      expandedHeight: 320,
      backgroundColor: const Color(0xFF0C315A),
      automaticallyImplyLeading: false,
      elevation: 0,
      pinned: true,
      title: Text(
        "Profil de Prestataire",
        style: TextStyle(
          color: Colors.white.withOpacity(_headerHeight > 250 ? 1.0 : 0.0),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      stretch: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Animated Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0C315A),
                    const Color(0xFF1E4A72),
                    const Color(0xFF2E6091),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Floating particles effect
            ...List.generate(15, (index) {
              return Positioned(
                left: (index * 25.0) % MediaQuery.of(context).size.width,
                top: (index * 30.0) % 250,
                child: AnimatedBuilder(
                  animation: _floatingAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _floatingAnimationController.value * 10,
                        _floatingAnimationController.value * 5,
                      ),
                      child: Container(
                        width: 4 + (index % 3) * 2,
                        height: 4 + (index % 3) * 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            // Profile content
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildProfileHeader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _profileImageUrl.startsWith('http')
                      ? Image.network(
                          _profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                        )
                      : Image.file(File(_profileImageUrl), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _providerProfile['fullName'],
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _providerProfile['profession'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Professionnel Vérifié',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Messages',
              Icons.message,
              const Color(0xFF2196F3),
              () => _showSnackBar('Messages', Colors.blue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'Partager',
              Icons.share,
              const Color(0xFF9C27B0),
              () => _showSnackBar('Partager', Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isAvailable
              ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
              : [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isAvailable ? Colors.green : Colors.orange).withOpacity(
              0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isAvailable ? Icons.check_circle : Icons.schedule,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAvailable ? 'Disponible Maintenant' : 'Indisponible',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isAvailable
                      ? 'Prêt à accepter de nouveaux projets'
                      : 'Occupé avec des projets en cours',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) => _toggleAvailability(),
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withOpacity(0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'label': 'Projets',
        'value': '${_providerProfile['completedJobs']}',
        'icon': Icons.work,
        'color': Color(0xFF4CAF50),
      },
      {
        'label': 'Note',
        'value': '${_providerProfile['rating']}★',
        'icon': Icons.star,
        'color': Color(0xFFFFD700),
      },
      {
        'label': 'Réponse',
        'value': _providerProfile['responseTime'],
        'icon': Icons.schedule,
        'color': Color(0xFF2196F3),
      },
      {
        'label': 'Expérience',
        'value': _providerProfile['experience'],
        'icon': Icons.timeline,
        'color': Color(0xFF9C27B0),
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récompenses',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 131,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (achievement['color'] as Color).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (achievement['color'] as Color).withOpacity(
                            0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          achievement['icon'] as IconData,
                          color: achievement['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement['title'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement['description'] as String,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  color: const Color(0xFF0C315A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Color(0xFF0C315A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Compétences Professionnelles',
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...(_skills.map((skill) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: skill['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          skill['icon'],
                          color: skill['color'],
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          skill['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${(skill['level'] * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: skill['color'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: skill['level'],
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(skill['color']),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C315A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF0C315A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Portfolio Récent',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () =>
                    _showSnackBar('Voir tout le portfolio', Colors.blue),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(color: Color(0xFF0C315A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _portfolioItems.length,
              itemBuilder: (context, index) {
                final item = _portfolioItems[index];
                return Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              item['image'],
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 140,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item['rating']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0C315A,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['category'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0C315A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['date'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: 170,
            height: 40,
            child: Btn(
              size: 14,
              texte: "Ajouter portofolio",
              function: () {
                _showSnackBar('Ajouter un portfolio', Colors.blue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C315A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF0C315A)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Informations Personnelles',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showSnackBar('Mode édition', Colors.blue),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C315A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF0C315A),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.person_outline,
            'Nom complet',
            _providerProfile['fullName'],
          ),
          _buildInfoRow(
            Icons.alternate_email,
            'Email',
            _providerProfile['email'],
          ),
          _buildInfoRow(
            Icons.phone_outlined,
            'Téléphone',
            _providerProfile['phone'],
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Localisation',
            _providerProfile['location'],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'À propos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _providerProfile['bio'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0C315A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0C315A), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
