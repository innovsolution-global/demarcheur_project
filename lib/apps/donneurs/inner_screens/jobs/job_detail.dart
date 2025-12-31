import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/upload.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

class JobDetail extends StatefulWidget {
  final AddVancyModel job;
  const JobDetail({super.key, required this.job});

  @override
  _JobDetailState createState() => _JobDetailState();
}

class _JobDetailState extends State<JobDetail> with TickerProviderStateMixin {
  double rate = 0.0;
  bool isFavorite = false;
  bool isApplied = false;

  final List<String> requirements = [
    "Avoir une connaissance des logiciels comptables",
    "Être toujours à jour sur les nouvelles tendances",
    "Être capable de travailler dans une petite ou large équipe",
    "Avoir une expérience de 3 ans minimum",
  ];

  ConstColors color = ConstColors();

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _fabController;
  late AnimationController _shareController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _fabController.forward();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shareController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shareController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContent(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 230,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: color.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowTurnBackward,
            color: color.primary,
            size: 22,
          ),
        ),
      ),
      // actions: [
      //   ScaleTransition(
      //     scale: _scaleAnimation,
      //     child: Container(
      //       margin: const EdgeInsets.all(8),
      //       decoration: BoxDecoration(
      //         color: Colors.white.withOpacity(0.9),
      //         borderRadius: BorderRadius.circular(14),
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.black.withOpacity(0.1),
      //             blurRadius: 10,
      //             offset: const Offset(0, 2),
      //           ),
      //         ],
      //       ),
      //       child: IconButton(
      //         onPressed: () {
      //           setState(() {
      //             isFavorite = !isFavorite;
      //           });
      //         },
      //         icon: Icon(
      //           isFavorite ? Icons.favorite : Icons.favorite_border,
      //           color: isFavorite ? Colors.red : color.primary,
      //           size: 22,
      //         ),
      //       ),
      //     ),
      //   ),
      // ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: NetworkImage(
                "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
              ),
              fit: BoxFit.cover,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.primary,
                color.primary.withOpacity(0.8),
                color.primary.withOpacity(0.6),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: JobDetailWavePainter(color.primary),
                ),
              ),
              Positioned(
                bottom: 25,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails de l\'emploi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Opportunité ${widget.job.typeJobe}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(),
          const SizedBox(height: 24),
          _buildJobInformation(),
          const SizedBox(height: 24),
          _buildRequirementsSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildJobHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'job_image_${widget.job.id}',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.primary.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.job.companyImage!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: TextStyle(
                        color: color.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.job.title,
                      style: TextStyle(
                        color: color.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.job.createdAt!,
                        style: TextStyle(
                          color: color.primary,
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(
                  'Évaluation de l\'entreprise',
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RatingBar.builder(
                    itemSize: 20,
                    glowColor: Colors.amber,
                    initialRating: rate > 0 ? rate : 4.5,
                    allowHalfRating: true,
                    itemBuilder: (context, index) {
                      return const Icon(Icons.star, color: Colors.amber);
                    },
                    onRatingUpdate: (val) {
                      setState(() {
                        rate = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInformation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedInformationCircle,
                  color: color.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Informations sur le poste',
                style: TextStyle(
                  color: color.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            'Salaire',
            "${NumberFormat('#,###').format(widget.job.salary)} GNF",
            HugeIcons.strokeRoundedMoney01,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Type d\'emploi',
            widget.job.typeJobe,
            HugeIcons.strokeRoundedBriefcase01,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Localisation',
            widget.job.city,
            HugeIcons.strokeRoundedLocation01,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Catégorie',
            widget.job.city,
            HugeIcons.strokeRoundedTag01,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, List<List<dynamic>> icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: color.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckList,
                  color: color.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Exigences du poste',
                style: TextStyle(
                  color: color.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...requirements.asMap().entries.map((entry) {
            int index = entry.key;
            String requirement = entry.value;
            return Container(
              margin: EdgeInsets.only(
                bottom: index == requirements.length - 1 ? 0 : 12,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      requirement,
                      style: TextStyle(
                        color: color.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isApplied
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Upload()),
                    ).then((_) {
                      setState(() {
                        isApplied = true;
                      });
                    });
                  },
            icon: Icon(
              isApplied ? Icons.check_circle : Icons.send_rounded,
              size: 20,
            ),
            label: Text(
              isApplied ? 'Candidature envoyée' : 'Postuler maintenant',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApplied ? color.accepted : color.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: (isApplied ? color.accepted : color.primary)
                  .withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedMessage01,
                  color: Colors.grey,
                  size: 18,
                ),
                label: const Text('Contacter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color.secondary,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showShareBottomSheet(),
                icon: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 0.5,
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedShare08,
                        color: Colors.grey,
                        size: 18,
                      ),
                    );
                  },
                ),
                label: const Text('Partager'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color.secondary,
                  side: BorderSide(color: Colors.grey.shade300),
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

  void _showShareBottomSheet() {
    _shareController.forward().then((_) => _shareController.reset());

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.41,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: color.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Partager cette offre',
                  style: TextStyle(
                    color: color.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _buildShareOption(
                              Brands.whatsapp,
                              'WhatsApp',
                              Colors.green,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _buildShareOption(
                              Brands.twitterx_2,
                              'X',
                              Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _buildShareOption(
                              Brands.facebook,
                              'Facebook',
                              Colors.blue,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _buildShareOption(
                              Brands.instagram,
                              'Instagram',
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _buildShareOption(
                              Brands.tiktok,
                              'TikTok',
                              Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _buildShareOption(
                              Brands.gmail,
                              'Gmail',
                              Colors.red,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _buildShareOption(
                              Brands.facebook_messenger,
                              'Messenger',
                              Colors.blue,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: _buildShareOption(
                              Brands.messages,
                              'Messages',
                              Colors.green,
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
    );
  }

  Widget _buildShareOption(dynamic brand, String label, Color accentColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Brand(brand, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class JobDetailWavePainter extends CustomPainter {
  final Color color;

  JobDetailWavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.6);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.6,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.6,
    );

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
