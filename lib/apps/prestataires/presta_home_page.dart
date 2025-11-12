import 'package:demarcheur_app/apps/prestataires/chat_page.dart';
import 'package:demarcheur_app/apps/prestataires/presta_detail.dart';
import 'package:demarcheur_app/apps/prestataires/presta_list.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/presta/presta_model.dart';
import 'package:demarcheur_app/providers/presta/presta_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class PrestaHomePage extends StatefulWidget {
  const PrestaHomePage({super.key});

  @override
  State<PrestaHomePage> createState() => _PrestaHomePageState();
}

class _PrestaHomePageState extends State<PrestaHomePage> {
  ConstColors color = ConstColors();
  int isSelected = 0;
  final TextEditingController _searchController = TextEditingController();

  // Controller and header offset for SliverAppBar animation
  final ScrollController _scrollController = ScrollController();
  double _headerHeight = 0;

  @override
  void initState() {
    super.initState();
    // Load local mock data when screen starts
    Future.microtask(() {
      //final jobProvider = context.read<JobProvider>();
      final searchProvider = context.read<PrestaProvider>();

      searchProvider.loadVancies().then((_) {
        searchProvider.setJobs(searchProvider.allJobs);
      });
    });

    // Update header height on scroll to animate AppBar title opacity
    _scrollController.addListener(() {
      setState(() {
        _headerHeight = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrestaProvider>();
    final categories = provider.categories;

    return Scaffold(
      backgroundColor: color.bg,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 🟦 Modern AppBar with gradient overlay and search
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            title: Text(
              "Accueil",
              style: TextStyle(
                color: Colors.white.withOpacity(
                  _headerHeight > 220 ? 1.0 : 0.0,
                ),
              ),
            ),
            expandedHeight: 220,
            backgroundColor: color.primary,
            foregroundColor: color.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const Image(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=2069&auto=format&fit=crop",
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trouvez un boulot qui vous convient",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _SearchBar(
                          controller: _searchController,
                          hintText: "Rechercher un service, une ville...",
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🟩 Category menu + header section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _CategoryChips(
                    categories: categories,
                    isSelected: isSelected,
                    onSelect: (index) {
                      setState(() => isSelected = index);
                    },
                    primary: color.primary,
                    background: color.bg,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubTitle(
                        text: "Recommandé pour vous",
                        fontsize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrestaList(),
                            ),
                          );
                        },
                        child: SubTitle(
                          text: "Tout voir",
                          fontsize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          content(),
        ],
      ),
    );
  }

  Widget menu(String label, int index) {
    bool isTap = isSelected == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = index;
        });
      },
      child: Container(
        width: label == "Tout" ? 80 : 150,
        height: 42,

        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isTap ? color.primary : color.bg,
          border: Border.all(color: isTap ? Colors.transparent : color.primary),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              overflow: TextOverflow.ellipsis,
              label,
              style: TextStyle(
                color: isTap ? color.bg : color.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget content() {
    final searchProvider = context.watch<PrestaProvider>();
    final categories = searchProvider.categories;
    final jobs = searchProvider.allJobs;
    List<PrestaModel> filteredJobs = jobs;
    if (isSelected != 0 && isSelected < categories.length) {
      final selectedCategory = categories[isSelected];
      filteredJobs = jobs
          .where(
            (job) =>
                job.categorie.toLowerCase() == selectedCategory.toLowerCase(),
          )
          .toList();
    }
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filteredJobs = filteredJobs
          .where(
            (job) =>
                job.title.toLowerCase().contains(query) ||
                job.companyName.toLowerCase().contains(query) ||
                job.location.toLowerCase().contains(query),
          )
          .toList();
    }

    // ✅ Define categories (must match your menu order)
    //final categories = jobs[isSelected].category;

    // ✅ Filter jobs based on the selected category
    //List<JobModel> filteredJobs;
    // (consolidated above)

    if (filteredJobs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: color.tertiary,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  "Aucun résultat",
                  style: TextStyle(
                    color: color.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Essayez d'autres mots-clés ou catégories",
                  style: TextStyle(color: color.tertiary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ Build the job list dynamically
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final job = filteredJobs[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PrestaDetail(presta: job)),
            );
          },
          child: _JobCard(
            color: color,
            title: job.title,
            company: job.companyName,
            location: job.location,
            imageUrl: job.imageUrl.first,
            status: job.status,
            postDate: job.postDate,
            onContact: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage(presta: job)),
              );
            },
          ),
        );
      }, childCount: filteredJobs.length),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  const _SearchBar({
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9AA0A6)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF5F6368)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int isSelected;
  final ValueChanged<int> onSelect;
  final Color primary;
  final Color background;
  const _CategoryChips({
    required this.categories,
    required this.isSelected,
    required this.onSelect,
    required this.primary,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          final selected = isSelected == index;
          return Padding(
            padding: EdgeInsets.only(
              right: index == categories.length - 1 ? 0 : 8,
            ),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: selected,
              onSelected: (_) => onSelect(index),
              selectedColor: primary,
              backgroundColor: background,
              labelStyle: TextStyle(
                color: selected ? background : primary,
                fontWeight: FontWeight.w600,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected ? Colors.transparent : primary,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final ConstColors color;
  final String title;
  final String company;
  final String location;
  final String imageUrl;
  final String status;
  final String postDate;
  final VoidCallback onContact;
  const _JobCard({
    required this.color,
    required this.title,
    required this.company,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.postDate,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = status == "Disponible";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BouncingDot(size: 12, color: Colors.amber),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 100,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TitleWidget(
                                text: title,
                                fontSize: 18,
                                color: color.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isAvailable ? color.bgA : color.errorBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: isAvailable
                                      ? color.accepted
                                      : color.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SubTitle(text: company, fontsize: 16),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedLocation01,
                              size: 18,
                              color: color.primary,
                            ),
                            const SizedBox(width: 4),
                            SubTitle(text: location, fontsize: 14),
                            const SizedBox(width: 12),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedClock01,
                              size: 16,
                              color: color.primary,
                            ),
                            const SizedBox(width: 4),
                            SubTitle(text: postDate, fontsize: 12),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_border),
                      label: const Text("Sauvegarder"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color.primary,
                        side: BorderSide(color: color.tertiary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onContact,
                      icon: const Icon(Icons.send),
                      label: const Text("Contacter"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.primary,
                        foregroundColor: color.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final double size;
  final Color color;
  const _BouncingDot({this.size = 12, this.color = Colors.amber});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _offsetAnim = Tween<double>(
      begin: -4,
      end: 4,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnim.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
