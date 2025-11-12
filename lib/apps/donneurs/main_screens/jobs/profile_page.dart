import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ConstColors colors = ConstColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        slivers: [
          Header(auto: false),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _ProfileHeader(colors: colors),
                  const SizedBox(height: 16),
                  _StatsRow(colors: colors),
                  const SizedBox(height: 16),
                  _SectionCard(
                    colors: colors,
                    title: "Informations",
                    children: const [
                      _InfoTile(
                        icon: Icons.person_outline,
                        label: "Nom complet",
                        value: "Utilisateur",
                      ),
                      _InfoTile(
                        icon: Icons.alternate_email,
                        label: "Email",
                        value: "user@example.com",
                      ),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: "Téléphone",
                        value: "+224 620 00 00 00",
                      ),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        label: "Localisation",
                        value: "Conakry, Guinée",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    colors: colors,
                    title: "Préférences",
                    children: const [
                      _InfoTile(
                        icon: Icons.language,
                        label: "Langue",
                        value: "Français",
                      ),
                      _InfoTile(
                        icon: Icons.dark_mode_outlined,
                        label: "Thème",
                        value: "Système",
                      ),
                      _InfoTile(
                        icon: Icons.notifications_outlined,
                        label: "Notifications",
                        value: "Activées",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 0,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.logout),
                          label: const Text("Déconnexion"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.primary,
                            side: BorderSide(color: colors.tertiary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text("Modifier le profil"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.bg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ConstColors colors;
  const _ProfileHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=300&q=80&auto=format&fit=crop",
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Utilisateur",
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Prestataire",
                    style: TextStyle(color: colors.secondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.verified, color: colors.accepted, size: 18),
                      const SizedBox(width: 4),
                      Text("Vérifié", style: TextStyle(color: colors.accepted)),
                    ],
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

class _StatsRow extends StatelessWidget {
  final ConstColors colors;
  const _StatsRow({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(colors: colors, label: "Annonces", value: "12"),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(colors: colors, label: "Messages", value: "5"),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(colors: colors, label: "Avis", value: "4.8"),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final ConstColors colors;
  final String label;
  final String value;
  const _StatCard({
    required this.colors,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: colors.tertiary)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final ConstColors colors;
  final String title;
  final List<Widget> children;
  const _SectionCard({
    required this.colors,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                title,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(height: 1),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
