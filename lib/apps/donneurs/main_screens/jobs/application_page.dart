import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/application_model.dart';
import 'package:demarcheur_app/providers/application_provider.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  final ConstColors colors = ConstColors();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ApplicationProvider>().loadApplication();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: provider.isLoading
          ? _buildLoadingState()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildFilterChips(provider.categories),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                _buildApplicationList(provider),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar.large(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TitleWidget(
          text: "Candidatures",
          color: colors.primary,
          fontSize: 28,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: colors.bgSubmit,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {},
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: colors.primary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(categories.length, (index) {
          final isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
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
        }),
      ),
    );
  }

  Widget _buildApplicationList(ApplicationProvider provider) {
    final categories = provider.categories;
    final allApps = provider.allapplication;

    List<ApplicationModel> filteredApps;
    if (_selectedIndex == 0) {
      filteredApps = allApps;
    } else {
      final selectedCategory = categories[_selectedIndex];
      filteredApps = allApps
          .where(
            (app) => app.status.toLowerCase() == selectedCategory.toLowerCase(),
          )
          .toList();
    }

    if (filteredApps.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.bgSubmit,
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedFolder01,
                  color: colors.primary.withOpacity(0.5),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Aucune candidature trouvée",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final app = filteredApps[index];
        return _buildApplicationCard(app);
      }, childCount: filteredApps.length),
    );
  }

  Widget _buildApplicationCard(ApplicationModel app) {
    Color statusColor;
    Color statusBgColor;

    switch (app.status.toLowerCase()) {
      case 'accepte':
        statusColor = const Color(0xFF08875C);
        statusBgColor = const Color(0xFFE6F4EA);
        break;
      case 'en attente':
        statusColor = const Color(0xFFC56D2A);
        statusBgColor = const Color(0xFFFFF4E5);
        break;
      case 'interview':
        statusColor = colors.primary;
        statusBgColor = colors.primary.withOpacity(0.1);
        break;
      default:
        statusColor = const Color(0xFFEB3223);
        statusBgColor = const Color(0xFFFEEFEF);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colors.tertiary,
                        image: DecorationImage(
                          image: NetworkImage(app.logo),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            app.companyName,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedLocation01,
                                size: 14,
                                color: Colors.grey[500]!,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                app.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 12),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedClock01,
                                size: 14,
                                color: Colors.grey[500]!,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                app.postDate,
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
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      app.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitPulse(color: colors.primary, size: 60.0),
          const SizedBox(height: 16),
          Text(
            'Chargement des candidatures...',
            style: TextStyle(
              color: colors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
