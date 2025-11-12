import 'dart:ui';
import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImmoProfilePage extends StatefulWidget {
  const ImmoProfilePage({super.key});

  @override
  State<ImmoProfilePage> createState() => _ImmoProfilePageState();
}

class _ImmoProfilePageState extends State<ImmoProfilePage>
    with TickerProviderStateMixin {
  final ConstColors _colors = ConstColors();
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _headerAnimation;

  bool _isEditing = false;
  String _profileImageUrl =
      "https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=300&q=80&auto=format&fit=crop";

  // Profile data
  final Map<String, dynamic> _userProfile = {
    'fullName': 'Jean-Baptiste Kamano',
    'email': 'jb.kamano@gmail.com',
    'phone': '+224 620 45 67 89',
    'location': 'Conakry, Guinée',
    'company': 'Kamano Immobilier Premium',
    'position': 'Agent Immobilier Senior',
    'joinDate': 'Mars 2021',
    'bio':
        'Expert en immobilier avec plus de 8 ans d\'expérience dans la vente et location de biens immobiliers haut de gamme à Conakry.',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _headerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImageUrl = image.path;
        });
        _showSnackBar('Photo de profil mise à jour');
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection de l\'image', isError: true);
    }
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

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
    HapticFeedback.lightImpact();
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
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildStatsSection(),
                        _buildAchievementsSection(),
                        _buildPersonalInfoSection(),
                        _buildBusinessInfoSection(),
                        _buildPreferencesSection(),
                        _buildActionButtons(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
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
      backgroundColor: _colors.primary,
      expandedHeight: 320,
      automaticallyImplyLeading: false,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://tse4.mm.bing.net/th/id/OIP.PC-Yjs2XzgXSFupMJqVE1QHaE7?cb=ucfimgc2&rs=1&pid=ImgDetMain&o=7&rm=3",
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_colors.primary, _colors.primary.withOpacity(0.8)],
                ),
              ),
            ),
            // Glass morphism effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Profile Content
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _headerAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * _headerAnimation.value),
                    child: _buildProfileHeader(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showSettingsBottomSheet(),
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'profile_image',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _profileImageUrl.startsWith('http')
                        ? Image.network(
                            _profileImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 50),
                          )
                        : Image.file(File(_profileImageUrl), fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userProfile['fullName'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile['position'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 18),
              const SizedBox(width: 4),
              Text(
                'Profil Vérifié',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = [
      {
        'label': 'Propriétés',
        'value': '24',
        'icon': Icons.home,
        'color': Colors.blue,
      },
      {
        'label': 'Clients',
        'value': '156',
        'icon': Icons.people,
        'color': Colors.green,
      },
      {
        'label': 'Avis',
        'value': '4.9',
        'icon': Icons.star,
        'color': Colors.amber,
      },
      {
        'label': 'Ventes',
        'value': '18',
        'icon': Icons.trending_up,
        'color': Colors.purple,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
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
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return _buildStatCard(
                label: stat['label'] as String,
                value: stat['value'] as String,
                icon: stat['icon'] as IconData,
                color: stat['color'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _colors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _colors.tertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = [
      {
        'title': 'Top Agent',
        'description': 'Meilleur agent du mois',
        'icon': Icons.emoji_events,
      },
      {
        'title': 'Client Satisfait',
        'description': '100% de satisfaction client',
        'icon': Icons.thumb_up,
      },
      {
        'title': 'Ventes Rapides',
        'description': 'Vente moyenne en 15 jours',
        'icon': Icons.speed,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Réussites',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _colors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
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
              children: achievements
                  .map(
                    (achievement) => _buildAchievementTile(
                      title: achievement['title'] as String,
                      description: achievement['description'] as String,
                      icon: achievement['icon'] as IconData,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.amber, size: 20),
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
                    color: _colors.secondary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: _colors.tertiary),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified, color: Colors.amber, size: 20),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildInfoSection(
      title: 'Informations Personnelles',
      items: [
        {
          'icon': Icons.person_outline,
          'label': 'Nom complet',
          'value': _userProfile['fullName'],
        },
        {
          'icon': Icons.alternate_email,
          'label': 'Email',
          'value': _userProfile['email'],
        },
        {
          'icon': Icons.phone_outlined,
          'label': 'Téléphone',
          'value': _userProfile['phone'],
        },
        {
          'icon': Icons.location_on_outlined,
          'label': 'Localisation',
          'value': _userProfile['location'],
        },
      ],
    );
  }

  Widget _buildBusinessInfoSection() {
    return _buildInfoSection(
      title: 'Informations Professionnelles',
      items: [
        {
          'icon': Icons.business,
          'label': 'Entreprise',
          'value': _userProfile['company'],
        },
        {
          'icon': Icons.work_outline,
          'label': 'Poste',
          'value': _userProfile['position'],
        },
        {
          'icon': Icons.calendar_today,
          'label': 'Membre depuis',
          'value': _userProfile['joinDate'],
        },
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildInfoSection(
      title: 'Préférences',
      items: [
        {'icon': Icons.language, 'label': 'Langue', 'value': 'Français'},
        {
          'icon': Icons.dark_mode_outlined,
          'label': 'Thème',
          'value': 'Système',
        },
        {
          'icon': Icons.notifications_outlined,
          'label': 'Notifications',
          'value': 'Activées',
        },
        {
          'icon': Icons.security,
          'label': 'Confidentialité',
          'value': 'Standard',
        },
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _colors.secondary,
                ),
              ),
              if (_isEditing || title == 'Informations Personnelles')
                IconButton(
                  onPressed: _toggleEditMode,
                  icon: Icon(
                    _isEditing ? Icons.save : Icons.edit,
                    color: _colors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
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
              children: items
                  .map(
                    (item) => _buildInfoTile(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      value: item['value'] as String,
                      isEditable:
                          _isEditing && title == 'Informations Personnelles',
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _colors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _colors.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (isEditable)
                  TextFormField(
                    initialValue: value,
                    style: TextStyle(
                      fontSize: 16,
                      color: _colors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      isDense: true,
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: _colors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (!isEditable)
            Icon(Icons.arrow_forward_ios, size: 16, color: _colors.tertiary),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showSnackBar('Profil mis à jour avec succès'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier le profil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSnackBar('Fonctionnalité à venir'),
                  icon: const Icon(Icons.share),
                  label: const Text('Partager'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _colors.primary,
                    side: BorderSide(color: _colors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
              onPressed: () => _showLogoutDialog(),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _colors.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _colors.tertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Paramètres',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _colors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingsTile(
              icon: Icons.security,
              title: 'Confidentialité',
              onTap: () => _showSnackBar('Paramètres de confidentialité'),
            ),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () => _showSnackBar('Paramètres de notifications'),
            ),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Aide & Support',
              onTap: () => _showSnackBar('Centre d\'aide'),
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'À propos',
              onTap: () => _showSnackBar('À propos de l\'application'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _colors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion'),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: _colors.tertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Déconnexion réussie');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
