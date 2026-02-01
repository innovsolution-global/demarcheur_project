import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:demarcheur_app/providers/message_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/services/config.dart';
import 'package:demarcheur_app/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailHouse extends StatefulWidget {
  final HouseModel house;
  final HouseProvider houseLenth;
  const DetailHouse({super.key, required this.house, required this.houseLenth});

  @override
  State<DetailHouse> createState() => _DetailHouseState();
}

class _DetailHouseState extends State<DetailHouse> {
  final ConstColors _color = ConstColors();

  @override
  Widget build(BuildContext context) {
    final house = widget.house;
    final sendMessagePro = context.read<MessageProvider>();
    final message = sendMessagePro.listMessag.isNotEmpty
        ? sendMessagePro.listMessag.first
        : SendMessageModel(
            id: '',
            content: '',
            senderId: '',
            receiverId: '',
            userName: '',
            timestamp: DateTime.now(),
          );

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(house),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(house),
                  const SizedBox(height: 32),
                  _buildQuickFeatures(house),
                  const SizedBox(height: 32),
                  _buildDescription(house),
                  const SizedBox(height: 32),
                  _buildAmenities(house),
                  const SizedBox(height: 32),
                  _buildOwnerCard(house),
                  const SizedBox(height: 120), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(house, message),
    );
  }

  Widget _buildSliverAppBar(HouseModel house) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: _color.secondary,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: _color.secondary,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              Config.getImgUrl(
                    house.imageUrl.isNotEmpty ? house.imageUrl.first : null,
                  ) ??
                  "https://via.placeholder.com/400x400",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.home_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black38,
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(HouseModel house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _color.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                house.countType ?? "Propriété",
                style: TextStyle(
                  color: _color.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: house.status == 'AVAILABLE'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                house.status == 'AVAILABLE' ? 'Disponible' : 'Occupé',
                style: TextStyle(
                  color: house.status == 'AVAILABLE'
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          house.title ?? house.countType ?? "Sans titre",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: _color.secondary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on_rounded, color: Colors.grey[400], size: 18),
            const SizedBox(width: 4),
            Text(
              house.location ?? "Lieu non spécifié",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          "${NumberFormat('#,###').format(house.rent).replaceAll(',', '.')} GNF",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: _color.primary,
          ),
        ),
        Text(
          "par mois",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFeatures(HouseModel house) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _FeatureItem(
            icon: Icons.meeting_room_outlined,
            label: "Chambres",
            value: "${house.rooms ?? 0}",
          ),
          _FeatureItem(
            icon: Icons.weekend_outlined,
            label: "Salons",
            value: "${house.livingRooms ?? 0}",
          ),
          _FeatureItem(
            icon: Icons.square_foot_outlined,
            label: "Surface",
            value: "${house.area ?? 0} m²",
          ),
          _FeatureItem(
            icon: Icons.garage_outlined,
            label: "Garage",
            value: "${house.garage ?? 0}",
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(HouseModel house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _color.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          house.description ??
              "Cette magnifique propriété située à ${house.location} offre un cadre de vie exceptionnel. Parfaitement entretenue, elle dispose de grands espaces lumineux et d'aménagements modernes.",
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.6),
        ),
      ],
    );
  }

  Widget _buildAmenities(HouseModel house) {
    final List<Map<String, dynamic>> amenities = [
      if (house.kitchen != null && house.kitchen! > 0)
        {"icon": Icons.kitchen_outlined, "label": "Cuisine"},
      if (house.garden == true)
        {"icon": Icons.park_outlined, "label": "Jardin"},
      if (house.piscine != null && house.piscine! > 0)
        {"icon": Icons.pool_outlined, "label": "Piscine"},
      if (house.store != null && house.store! > 0)
        {"icon": Icons.store_mall_directory_outlined, "label": "Magasin"},
    ];

    if (amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Commodités",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _color.secondary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: amenities.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item["icon"] as IconData,
                    size: 18,
                    color: _color.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item["label"] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _color.secondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOwnerCard(HouseModel house) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _color.secondary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _color.secondary.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Config.getImgUrl(house.logo) != null
                  ? Image.network(
                      Config.getImgUrl(house.logo)!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.business,
                        size: 32,
                        color: Colors.grey[400],
                      ),
                    )
                  : Icon(Icons.business, size: 32, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  house.companyName ?? "Agence Immo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _color.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Professionnel vérifié",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(HouseModel house, SendMessageModel message) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Loyer mensuel",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${NumberFormat.compact().format(house.rent)} GNF",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _color.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final currentUserId = authProvider.userId ?? '';

                final newMessage = SendMessageModel(
                  id: '', // Will be generated by backend or unused for new chat
                  content: '',
                  senderId: currentUserId,
                  receiverId:
                      house.companyId ??
                      house.ownerId ??
                      '', // Use company or owner ID
                  userName: house.companyName ?? 'Agence Immo',
                  userPhoto: house.logo,
                  timestamp: DateTime.now(),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatWidget(pageType: 'Searcher', message: newMessage),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
              label: const Text("Contacter"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _color.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                elevation: 8,
                shadowColor: _color.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
            ],
          ),
          child: Icon(icon, color: ConstColors().primary, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: ConstColors().secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
