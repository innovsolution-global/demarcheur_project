import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/widgets/chat_widget.dart';
import 'package:demarcheur_app/apps/prestataires/presta_detail.dart';
import 'package:demarcheur_app/apps/prestataires/presta_list.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/presta/presta_model.dart';
import 'package:demarcheur_app/providers/presta/presta_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

class PrestaHomePage extends StatefulWidget {
  const PrestaHomePage({super.key});

  @override
  State<PrestaHomePage> createState() => _PrestaHomePageState();
}

class _PrestaHomePageState extends State<PrestaHomePage> {
  final ConstColors colors = ConstColors();
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = context.read<AuthProvider>();
      final prestaProvider = context.read<PrestaProvider>();
      prestaProvider.loadVancies(authProvider.token).then((_) {
        prestaProvider.setJobs(prestaProvider.allJobs);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrestaProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildSearchBar(),
              ),
            ),
            // _buildStatsSection(),
            _buildCategorySection(provider.categories),
            _buildSectionTitle("Opportunités récentes", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrestaList()),
              );
            }),
            _buildJobList(provider),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 240,
      automaticallyImplyLeading: false,
      pinned: true,
      elevation: 0,
      backgroundColor: colors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
                  ),
                ),
              ),
            ),
            //Positioned(bottom: 50, child: _buildSearchBar()),
            Positioned(
              bottom: 30,
              child: Text(
                "Prêt pour de nouvelles missions ?",
                style: TextStyle(
                  color: colors.bg,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Rechercher une mission...",
          hintStyle: TextStyle(color: colors.secondary.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(List<String> categories) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedCategoryIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.grey.shade200,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : colors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onTap) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            // GestureDetector(
            //   onTap: onTap,
            //   child: Text(
            //     "Voir tout",
            //     style: TextStyle(
            //       color: colors.primary,
            //       fontSize: 14,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(PrestaProvider provider) {
    final jobs = provider.allJobs;
    // Filter vacancies: only from SEARCHER role
    List<PrestaModel> filteredJobs = jobs.where((job) {
      if (job.ownerRole != null) {
        return job.ownerRole == 'SEARCHER';
      }
      // Heuristic: SEARCHERs (donneurs) often don't have a company name set 
      // or it defaults to their personal name, while GIVERS (employers) always have it.
      return job.companyName.isEmpty || 
             job.companyName == 'Entreprise' || 
             job.companyName == 'N/A';
    }).toList();


    if (_selectedCategoryIndex != 0 &&
        _selectedCategoryIndex < provider.categories.length) {
      final category = provider.categories[_selectedCategoryIndex];
      filteredJobs = filteredJobs
          .where((job) => job.categorie == category)
          .toList();
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredJobs = filteredJobs
          .where(
            (job) =>
                job.title.toLowerCase().contains(query) ||
                job.companyName.toLowerCase().contains(query),
          )
          .toList();
    }

    if (filteredJobs.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                size: 48,
                color: colors.tertiary,
              ),
              const SizedBox(height: 16),
              Text(
                "Aucune mission trouvée",
                style: TextStyle(
                  color: colors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final job = filteredJobs[index];
        return _ModernJobCard(job: job, colors: colors);
      }, childCount: filteredJobs.length),
    );
  }
}

class _ModernJobCard extends StatelessWidget {
  final PrestaModel job;
  final ConstColors colors;

  const _ModernJobCard({required this.job, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PrestaDetail(presta: job)),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(
                            job.imageUrl.isNotEmpty ? job.imageUrl[0] : "",
                          ),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Handle image load error silently or log it
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.companyName,
                            style: TextStyle(
                              color: colors.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildTag(
                                job.location,
                                HugeIcons.strokeRoundedLocation01,
                              ),
                              const SizedBox(width: 8),
                              _buildTag(
                                job.salary,
                                HugeIcons.strokeRoundedMoney03,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //Icon(Icons.bookmark_border_rounded, color: colors.tertiary),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrestaDetail(presta: job),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: colors.primary.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Détails",
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final authProvider = context.read<AuthProvider>();
                          final myId = authProvider.userId;
                          if (myId == null) return;

                          final receiverId = job.ownerId ?? job.id;
                          if (receiverId!.isEmpty) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatWidget(
                                pageType: 'Presta',
                                message: SendMessageModel(
                                  senderId: myId,
                                  receiverId: receiverId,
                                  userName: job.companyName,
                                  userPhoto: job.imageUrl.isNotEmpty
                                      ? job.imageUrl[0]
                                      : null,
                                  content: '',
                                  timestamp: DateTime.now(),
                                ),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Postuler",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildTag(String text, List<List<dynamic>> icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, size: 12, color: colors.secondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: colors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
