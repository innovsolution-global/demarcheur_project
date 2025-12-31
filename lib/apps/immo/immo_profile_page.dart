import 'package:demarcheur_app/apps/demandeurs/main_screens/post_vancy.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/statistics_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/settings_provider.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImmoProfilePage extends StatefulWidget {
  const ImmoProfilePage({super.key});

  @override
  State<ImmoProfilePage> createState() => _ImmoProfilePageState();
}

class _ImmoProfilePageState extends State<ImmoProfilePage>
    with TickerProviderStateMixin {
  ConstColors colors = ConstColors();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          Header(auto: false),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          _EnhancedProfileHeader(colors: colors),
                          const SizedBox(height: 20),
                          _ModernStatsSection(colors: colors),
                          const SizedBox(height: 20),
                          _QuickActionsSection(colors: colors),
                          const SizedBox(height: 20),
                          _ModernSectionCard(
                            colors: colors,
                            title: "Informations personnelles",
                            icon: Icons.person_outline_rounded,
                            children: [
                              _ModernInfoTile(
                                icon: Icons.badge_outlined,
                                label: "Nom complet",
                                value: "Utilisateur",
                                colors: colors,
                              ),
                              _ModernInfoTile(
                                icon: Icons.email_outlined,
                                label: "Adresse email",
                                value: "user@example.com",
                                colors: colors,
                              ),
                              _ModernInfoTile(
                                icon: Icons.phone_outlined,
                                label: "Numéro de téléphone",
                                value: "+224 620 00 00 00",
                                colors: colors,
                              ),
                              _ModernInfoTile(
                                icon: Icons.location_on_outlined,
                                label: "Localisation",
                                value: "Conakry, Guinée",
                                colors: colors,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _ModernSectionCard(
                            colors: colors,
                            title: "Préférences & Paramètres",
                            icon: Icons.settings_outlined,
                            children: [
                              _ModernInfoTile(
                                icon: Icons.notifications_outlined,
                                label: "Notifications push",
                                value: settings.notificationsEnabled
                                    ? "Activées"
                                    : "Désactivées",
                                colors: colors,
                                hasAction: true,
                                onTap: () {
                                  settings.toggleNotifications(
                                    !settings.notificationsEnabled,
                                  );
                                },
                              ),
                              _ModernInfoTile(
                                icon: Icons.security_outlined,
                                label: "Confidentialité",
                                value: "Gérer les paramètres",
                                colors: colors,
                                hasAction: true,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _ActionButtonsSection(colors: colors),
                          const SizedBox(height: 24),
                        ],
                      ),
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

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return "Thème système";
      case ThemeMode.light:
        return "Clair";
      case ThemeMode.dark:
        return "Sombre";
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final settings = context.read<SettingsProvider>();
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choisir la langue",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                context,
                "Français",
                const Locale('fr'),
                settings,
              ),
              _buildLanguageOption(
                context,
                "English",
                const Locale('en'),
                settings,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    Locale locale,
    SettingsProvider settings,
  ) {
    final isSelected = settings.locale == locale;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colors.primary : colors.secondary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colors.primary)
          : null,
      onTap: () {
        settings.setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final settings = context.read<SettingsProvider>();
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choisir le thème",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context,
                "Thème système",
                ThemeMode.system,
                settings,
              ),
              _buildThemeOption(context, "Clair", ThemeMode.light, settings),
              _buildThemeOption(context, "Sombre", ThemeMode.dark, settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    ThemeMode mode,
    SettingsProvider settings,
  ) {
    final isSelected = settings.themeMode == mode;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colors.primary : colors.secondary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colors.primary)
          : null,
      onTap: () {
        settings.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}

class _EnhancedProfileHeader extends StatelessWidget {
  final ConstColors colors;
  const _EnhancedProfileHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=300&q=80&auto=format&fit=crop",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Utilisateur",
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Prestataire",
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accepted.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: colors.accepted,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Compte vérifié",
                              style: TextStyle(
                                color: colors.accepted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "4.8",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "(127 avis)",
                    style: TextStyle(color: colors.secondary, fontSize: 14),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Profil à 95%",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernStatsSection extends StatelessWidget {
  final ConstColors colors;
  const _ModernStatsSection({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModernStatCard(
            colors: colors,
            icon: Icons.campaign_outlined,
            label: "Annonces",
            value: "12",
            subtitle: "Actives",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModernStatCard(
            colors: colors,
            icon: Icons.message_outlined,
            label: "Messages",
            value: "5",
            subtitle: "Non lus",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModernStatCard(
            colors: colors,
            icon: Icons.visibility_outlined,
            label: "Vues",
            value: "248",
            subtitle: "Ce mois",
          ),
        ),
      ],
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final ConstColors colors;
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  const _ModernStatCard({
    required this.colors,
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: colors.tertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final ConstColors colors;
  const _QuickActionsSection({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Actions rapides",
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  colors: colors,
                  icon: Icons.add_circle_outline,
                  label: "Nouvelle annonce",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostVancy(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  colors: colors,
                  icon: Icons.analytics_outlined,
                  label: "Statistiques",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatisticsPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  colors: colors,
                  icon: Icons.support_agent_outlined,
                  label: "Support",
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final ConstColors colors;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.colors,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: colors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernSectionCard extends StatelessWidget {
  final ConstColors colors;
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ModernSectionCard({
    required this.colors,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ModernInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ConstColors colors;
  final bool hasAction;
  final VoidCallback? onTap;

  const _ModernInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    this.hasAction = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAction ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: colors.primary, size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: colors.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasAction)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: colors.tertiary,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButtonsSection extends StatelessWidget {
  final ConstColors colors;
  const _ActionButtonsSection({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text(
              "Modifier le profil",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.help_outline_rounded, size: 18),
                label: const Text(
                  "Aide",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.secondary,
                  side: BorderSide(color: colors.secondary.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  "Déconnexion",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
