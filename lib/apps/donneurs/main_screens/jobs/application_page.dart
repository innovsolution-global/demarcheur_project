import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/application_model.dart';
import 'package:demarcheur_app/providers/application_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ApplicationPageState createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  ConstColors color = ConstColors();
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    // Load local mock data when screen starts
    Future.microtask(() {
      //final jobProvider = context.read<JobProvider>();
      final searchProvider = context.read<ApplicationProvider>();

      searchProvider.loadApplication().then((_) {
        // searchProvider.setJobs(searchProvider.allJobs);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();
    final categories = provider.categories;
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: color.bg,

        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              actionsPadding: EdgeInsets.all(20),

              automaticallyImplyLeading: false,
              iconTheme: IconThemeData(color: color.bg),
              actionsIconTheme: IconThemeData(color: color.bg),
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: color.primary,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(categories.length, (index) {
                          return Row(
                            children: [
                              btnMenu(categories[index], index),
                              if (index != categories.length - 1)
                                const SizedBox(width: 10),
                            ],
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            provider.isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: Colors.blue,
                        size: 60.0,
                      ),
                    ),
                  )
                : content(),
          ],
        ),
      ),
    );
  }

  Widget btnMenu(String title, int index) {
    bool isTab = currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: isTab ? color.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTab ? Colors.transparent : color.tertiary,
          ),
        ),
        height: 40,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isTab ? color.bg : color.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget content() {
    final houseProvider = context.watch<ApplicationProvider>();
    final categories = houseProvider
        .categories; // final categories = houseProvider.categories;
    final houses = houseProvider.allapplication;
    List<ApplicationModel> filteredJobs;
    if (currentIndex == 0) {
      filteredJobs = houses; // "Tout"
    } else {
      final selectedCategory = categories[currentIndex];
      filteredJobs = houses
          .where(
            (job) => job.status.toLowerCase() == selectedCategory.toLowerCase(),
          )
          .toList();
    }

    if (houses.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              "Aucune offre disponible pour cette catégorie.",
              style: TextStyle(color: color.primary),
            ),
          ),
        ),
      );
    }
    if (currentIndex == 0) {
      filteredJobs = houses; // Show all
    } else {
      final selectedCategory = categories[currentIndex];
      filteredJobs = houses
          .where(
            (job) => job.status.toLowerCase() == selectedCategory.toLowerCase(),
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
        final application = filteredJobs[index];
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.tertiary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Job image and info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.tertiary),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(application.logo),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleWidget(
                        text: application.title,
                        fontSize: 18,
                        color: color.primary,
                      ),
                      SubTitle(
                        text: application.companyName,
                        fontsize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedLocation01,
                            size: 18,
                            color: color.primary,
                          ),
                          SubTitle(text: application.location, fontsize: 16),
                        ],
                      ),
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedClock01,
                            size: 15,
                            color: color.primary,
                          ),
                          SizedBox(width: 4),
                          SubTitle(text: application.postDate, fontsize: 14),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 5),
              Divider(color: color.tertiary),
              const SizedBox(height: 10),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: application.status == "Accepte"
                      ? color
                            .bgA // Si VRAI (Accepte)
                      : application.status ==
                            "En attente" // Sinon, vérifie la deuxième condition
                      ? color.bgcour
                      : application.status == "Interview"
                      ? color
                            .bgSubmit // Si VRAI (En attente)
                      : color.errorBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: TitleWidget(
                    text: application.status,
                    color: application.status == "Accepte"
                        ? color.accepted
                        : application.status == "En attente"
                        ? color.cour
                        : application.status == "Interview"
                        ? color.primary
                        : color.error,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      }, childCount: filteredJobs.length),
    );
  }
}
