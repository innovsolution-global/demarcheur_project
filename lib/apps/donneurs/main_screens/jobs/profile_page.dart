import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/job_posting.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/donnor_user_provider.dart';
import 'package:demarcheur_app/providers/settings_provider.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/payment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
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
    Future.microtask(() {
      context.read<DonnorUserProvider>().loadUser();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final demUser = context.watch<DonnorUserProvider>();
    final user = demUser.user;
    if (user != null) {
      print("DEBUG PROFILE: User is not null");
      print("DEBUG PROFILE: Name: ${user.name}");
      print("DEBUG PROFILE: Phone: ${user.phone}");
      print("DEBUG PROFILE: Email: ${user.email}");
      print("DEBUG PROFILE: Address: ${user.adress}");
      print("DEBUG PROFILE: City: ${user.city}");
    } else {
      print("DEBUG PROFILE: User is NULL");
    }
    if (demUser.isLoading) {
      return Scaffold(
        backgroundColor: colors.bg,
        body: Center(child: SpinKitDancingSquare(color: colors.accepted)),
      );
    }

    // if (user == null) {
    //   return Scaffold(
    //     backgroundColor: colors.bg,
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Icon(Icons.error_outline, size: 48, color: colors.primary),
    //           const SizedBox(height: 16),
    //           Text(
    //             "Impossible de charger le profil",
    //             style: TextStyle(color: colors.primary, fontSize: 16),
    //           ),
    //           const SizedBox(height: 16),
    //           ElevatedButton(
    //             onPressed: () {
    //               context.read<DonnorUserProvider>().loadUser();
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: colors.primary,
    //               foregroundColor: Colors.white,
    //             ),
    //             child: const Text("Réessayer"),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DonnorUserProvider>().loadUser();
        },
        child: CustomScrollView(
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
                                if (user?.name != null)
                                  _ModernInfoTile(
                                    icon: Icons.business_outlined,
                                    label: "Organisation",
                                    value: user!.name,
                                    colors: colors,
                                  ),
                                _ModernInfoTile(
                                  icon: Icons.email_outlined,
                                  label: "Adresse email",
                                  value: user?.email ?? "Non renseigné",
                                  colors: colors,
                                ),
                                _ModernInfoTile(
                                  icon: Icons.phone_outlined,
                                  label: "Numéro de téléphone",
                                  value: user?.phone ?? "Non renseigné",
                                  colors: colors,
                                ),
                                _ModernInfoTile(
                                  icon: Icons.location_on_outlined,
                                  label: "Adresse",
                                  value: user?.city ?? "Non renseigné",
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
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Paramètres de confidentialité bientôt disponibles",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _ModernInfoTile(
                                  icon: Icons.help,
                                  label: "Centre d'aide",
                                  value: "Voir comment nous pouvons vous aider",
                                  colors: colors,
                                  hasAction: true,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Centre d'aide bientôt disponible",
                                        ),
                                      ),
                                    );
                                  },
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
      ),
    );
  }
}

class _EnhancedProfileHeader extends StatefulWidget {
  final ConstColors colors;

  const _EnhancedProfileHeader({required this.colors});

  @override
  State<_EnhancedProfileHeader> createState() => _EnhancedProfileHeaderState();
}

class _EnhancedProfileHeaderState extends State<_EnhancedProfileHeader> {
  bool isLoading = false;
  Future<void> submit(BuildContext context, DonnorUserProvider dem) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    await dem.toggleIsVerified();

    setState(() {
      isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final demUser = context.watch<DonnorUserProvider>();
    final user = demUser.user;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: widget.colors.primary.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        demUser.user?.profile ?? "",
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: Icon(Icons.person, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? "Nom de l'entreprise",
                          style: TextStyle(
                            color: widget.colors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),

                        // user.isVerified
                        //     ? Container(
                        //         padding: const EdgeInsets.symmetric(
                        //           horizontal: 10,
                        //           vertical: 6,
                        //         ),
                        //         decoration: BoxDecoration(
                        //           color: widget.colors.accepted.withValues(
                        //             alpha: 0.08,
                        //           ),
                        //           borderRadius: BorderRadius.circular(16),
                        //         ),
                        //         child: Row(
                        //           mainAxisSize: MainAxisSize.min,
                        //           children: [
                        //             Icon(
                        //               Icons.verified_rounded,
                        //               color: widget.colors.accepted,
                        //               size: 16,
                        //             ),
                        //             const SizedBox(width: 4),
                        //             Text(
                        //               "Compte certifié",
                        //               style: TextStyle(
                        //                 color: widget.colors.accepted,
                        //                 fontSize: 12,
                        //                 fontWeight: FontWeight.w600,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       )
                        //     :
                        TextButton(
                          onPressed: () {
                            if (!demUser.isLoading && !isLoading) {
                              submit(context, demUser);
                            }
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: widget.colors.primary.withValues(
                              alpha: 0.08,
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: widget.colors.primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Certifier mon compte',
                                  style: TextStyle(
                                    color: widget.colors.primary,
                                  ),
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
                  color: widget.colors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.colors.primary.withValues(alpha: 0.02),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    // Text(
                    //   demUser.user!.rate.toString(),
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.w700,
                    //     fontSize: 16,
                    //     color: widget.colors.primary,
                    //   ),
                    // ),
                    // const SizedBox(width: 4),
                    // Text(
                    //   "(127 avis)",
                    //   style: TextStyle(
                    //     color: widget.colors.secondary,
                    //     fontSize: 14,
                    //   ),
                    // ),
                    // const Spacer(),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 12,
                    //     vertical: 6,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: widget.colors.primary,
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: demUser.user!.isVerified
                    //       ? Text(
                    //           "Profil à 100%",
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         )
                    //       :
                    Text(
                      "Profil à 80%",
                      style: TextStyle(
                        color: Colors.white,
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
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.02),
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
          Text(subtitle, style: TextStyle(color: colors.primary, fontSize: 10)),
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
            color: Colors.black.withValues(alpha: 0.06),
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
                        builder: (context) => const JobPostings(),
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const StatisticsPage(),
                    //   ),
                    // );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  colors: colors,
                  icon: Icons.support_agent_outlined,
                  label: "Support",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Support bientôt disponible"),
                      ),
                    );
                  },
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
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary.withValues(alpha: 0.01)),
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
            color: Colors.black.withValues(alpha: 0.09),
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
                    color: colors.primary.withValues(alpha: 0.05),
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
                    color: colors.primary.withValues(alpha: 0.08),
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
                        overflow: TextOverflow.ellipsis,
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
                    color: colors.primary,
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
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Modification bientôt disponible"),
                      ),
                    );
                  },
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
            ),
            SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Modification bientôt disponible"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.archive, size: 20),
                  label: const Text(
                    "Mon portofolio",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary.withValues(alpha: 0.2),
                    foregroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              showDialog(
                //barrierColor: colors.bg,
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFFF8FAFC),
                  title: Text(
                    "Déconnexion !",
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  content: Text(
                    "Voulez-vous vraiment vous déconnecter ?",
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: colors.primary.withValues(alpha: 0.05),
                        foregroundColor: colors.primary,
                        side: BorderSide(color: colors.primary),
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Add logout logic here if available
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Déconnexion",
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              );
            },
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
    );
  }
}
