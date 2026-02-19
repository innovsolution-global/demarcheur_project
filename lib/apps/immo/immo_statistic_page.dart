import 'package:demarcheur_app/apps/immo/immo_boost_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:demarcheur_app/widgets/immo_header.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';

class ImmoStatisticPage extends StatefulWidget {
  final HouseModel house;
  const ImmoStatisticPage({super.key, required this.house});

  @override
  State<ImmoStatisticPage> createState() => _ImmoStatisticPageState();
}

class _ImmoStatisticPageState extends State<ImmoStatisticPage> {
  final ConstColors _colors = ConstColors();
  bool _isUpdatingStatus = false;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _isAvailable =
        (widget.house.statusProperty == 'AVAILABLE' ||
        widget.house.status == 'AVAILABLE');
  }

  Future<void> _toggleStatus() async {
    setState(() => _isUpdatingStatus = true);
    HapticFeedback.mediumImpact();

    try {
      final provider = context.read<HouseProvider>();
      final auth = context.read<AuthProvider>();

      // Since backend rejected RENTED, we'll try a fallback or just toggling locally if we don't know the exact enum yet.
      // But for a professional UI, we should still try to push the update.
      final newStatus = _isAvailable
          ? 'RENTED'
          : 'AVAILABLE'; // We'll keep RENTED for now but the user knows backend has issues.

      final success = await provider.updateHouse(
        widget.house.id!,
        HouseModel(
          id: widget.house.id,
          statusProperty: newStatus,
          status: newStatus,
        ),
        auth.token,
      );

      if (success && mounted) {
        setState(() => _isAvailable = !_isAvailable);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isAvailable ? 'Propriété activée' : 'Propriété désactivée',
            ),
            backgroundColor: _colors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour (Backend)'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          const ImmoHeader(auto: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildPropertyHero(),
                  const SizedBox(height: 32),
                  _buildManagementCard(),
                  const SizedBox(height: 32),
                  _buildPropertyDetails(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                color: _colors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gestion",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _colors.secondary,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  "Contrôle de disponibilité",
                  style: TextStyle(
                    fontSize: 14,
                    color: _colors.secondary.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyHero() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Hero(
                  tag: 'stat_house_${widget.house.id}',
                  child: Image.network(
                    widget.house.imageUrl.isNotEmpty
                        ? widget.house.imageUrl.first
                        : '',
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 240,
                      color: Colors.grey[100],
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedHome01,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (_isAvailable ? Colors.green : Colors.red)
                            .withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isAvailable ? 'DISPONIBLE' : 'INDISPONIBLE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.house.title ?? "Sans titre",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _colors.secondary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedLocation01,
                      size: 16,
                      color: _colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.house.location ?? "Lieu non spécifié",
                      style: TextStyle(
                        fontSize: 15,
                        color: _colors.secondary.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "${NumberFormat('#,###').format(widget.house.rent ?? 0).replaceAll(',', '.')} GNF",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
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

  Widget _buildManagementCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _colors.secondary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _colors.secondary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Actions de visibilité",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Changez l'état de votre annonce pour les clients.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isUpdatingStatus ? null : _toggleStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAvailable
                        ? Colors.redAccent
                        : Colors.greenAccent[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: _isUpdatingStatus
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: _isAvailable
                                  ? HugeIcons.strokeRoundedEye
                                  : HugeIcons.strokeRoundedEye,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isAvailable
                                  ? "RETIRER DU MARCHÉ"
                                  : "REMETTRE EN LIGNE",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImmoBoostPage(boost: widget.house),
                      ),
                    );
                  },
                  icon: const Icon(Icons.rocket_launch, color: Colors.white),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Détails techniques",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _colors.secondary,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.0, // Increased height
          children: [
            _buildDetailItem(
              HugeIcons.strokeRoundedBedDouble,
              "Pièces",
              "${widget.house.rooms ?? 0}",
            ),
            _buildDetailItem(
              HugeIcons.strokeRoundedSofa01,
              "Salons",
              "${widget.house.livingRooms ?? 0}",
            ),
            _buildDetailItem(
              HugeIcons.strokeRoundedSquare01,
              "Surface",
              "${widget.house.area ?? 0} m²",
            ),
            _buildDetailItem(
              HugeIcons.strokeRoundedGarage,
              "Garage",
              "${widget.house.garage ?? 0}",
            ),
            _buildDetailItem(
              HugeIcons.strokeRoundedSwimming,
              "Piscine",
              widget.house.piscine == 1 ? "Oui" : "Non",
            ),
            _buildDetailItem(
              HugeIcons.strokeRoundedTree01,
              "Jardin",
              widget.house.garden == true ? "Oui" : "Non",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    List<List<dynamic>> icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: _colors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _colors.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: _colors.secondary.withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
