import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/job_detail.dart';
import 'package:demarcheur_app/apps/donneurs/inner_screens/jobs/search_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/job_model.dart';
import 'package:demarcheur_app/providers/search_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ConstColors color = ConstColors();
  int isSelected = 0;
  @override
  void initState() {
    super.initState();
    // Load local mock data when screen starts
    Future.microtask(() {
      //final jobProvider = context.read<JobProvider>();
      final searchProvider = context.read<SearchProvider>();

      searchProvider.loadJobs().then((_) {
        searchProvider.setJobs(searchProvider.allJobs);
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final categories = provider.categories;

    return Scaffold(
      backgroundColor: color.bg,
      body: CustomScrollView(
        slivers: [
          // 🟦 AppBar always visible
          SliverAppBar.medium(
            automaticallyImplyLeading: false,
            iconTheme: IconThemeData(color: color.bg),
            actionsIconTheme: IconThemeData(color: color.bg),
            backgroundColor: Colors.transparent,
            title: TitleWidget(text: "A C C U E I L", color: color.bg),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: color.primary,
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
                  ),
                ),
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
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(categories.length, (index) {
                        return Row(
                          children: [
                            menu(categories[index], index),
                            if (index != categories.length - 1)
                              const SizedBox(width: 10),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              builder: (context) => const SearchPage(),
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

          // 🟨 Job list section — only this part shows loading
          provider.isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: SpinKitFadingCircle(color: Colors.blue, size: 60.0),
                  ),
                )
              : content(),
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
    final searchProvider = context.watch<SearchProvider>();
    final categories = searchProvider.categories;
    final jobs = searchProvider.allJobs;
    List<JobModel> filteredJobs;
    if (isSelected == 0) {
      filteredJobs = jobs; // "Tout"
    } else {
      final selectedCategory = categories[isSelected];
      filteredJobs = jobs
          .where(
            (job) =>
                job.category.toLowerCase() == selectedCategory.toLowerCase(),
          )
          .toList();
    }

    // ✅ Define categories (must match your menu order)
    //final categories = jobs[isSelected].category;

    // ✅ Filter jobs based on the selected category
    //List<JobModel> filteredJobs;
    if (isSelected == 0) {
      filteredJobs = jobs; // Show all
    } else {
      final selectedCategory = categories[isSelected];
      filteredJobs = jobs
          .where(
            (job) =>
                job.category.toLowerCase() == selectedCategory.toLowerCase(),
          )
          .toList();
    }

    if (filteredJobs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              "Aucune offre trouvée dans cette catégorie.",
              style: TextStyle(color: color.primary),
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
              MaterialPageRoute(builder: (_) => JobDetail(job: job)),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.tertiary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: color.tertiary),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(job.imageUrl),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleWidget(
                            text: job.title,
                            fontSize: 18,
                            color: color.primary,
                          ),
                          SubTitle(text: job.companyName, fontsize: 16),
                          Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedLocation01,
                                size: 18,
                                color: color.primary,
                              ),
                              const SizedBox(width: 4),
                              SubTitle(text: job.location, fontsize: 14),
                              const SizedBox(width: 10),
                              SubTitle(text: job.type, fontsize: 14),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SubTitle(
                            text: "${NumberFormat().format(job.salary)} GNF",
                            fontsize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedClock01,
                                size: 15,
                                color: color.primary,
                              ),
                              const SizedBox(width: 4),
                              SubTitle(text: job.postDate, fontsize: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Divider(color: color.tertiary),
                const SizedBox(height: 10),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: job.status == "Disponible"
                        ? color.bgA
                        : color.errorBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: TitleWidget(
                      text: job.status,
                      color: job.status == "Disponible"
                          ? color.accepted
                          : color.error,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }, childCount: filteredJobs.length),
    );
  }
}
