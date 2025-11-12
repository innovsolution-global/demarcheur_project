import 'package:demarcheur_app/apps/demandeurs/main_screens/applicant_detail.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/applicants.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/post_vancy.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/user_cv_view.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/vancy.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/dem_job_provider.dart';
import 'package:demarcheur_app/providers/user_provider.dart';
import 'package:demarcheur_app/widgets/btn_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DemHomePage extends StatefulWidget {
  const DemHomePage({super.key});

  @override
  State<DemHomePage> createState() => _DemHomePageState();
}

class _DemHomePageState extends State<DemHomePage> {
  ConstColors color = ConstColors();
  bool isSelected = true;
  @override
  void initState() {
    Future.microtask(() {
      final demProvider = context.read<DemJobProvider>();
      demProvider.loadVancies().then((_) {
        // searchProvider.setJobs(searchProvider.allJobs);
      });
      final userProvider = context.read<UserProvider>();
      userProvider.loadUsers();
    });
    super.initState();
  }

  String dispo = "Disponible";
  String nonDispo = "Plus disponible";

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DemJobProvider>();
    final user = context.watch<UserProvider>();
    return Scaffold(
      backgroundColor: color.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubTitle(
                        text: "Mes annonces",
                        fontsize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Applicants(),
                            ),
                          );
                        },

                        child: SubTitle(
                          text: "Tout voir",
                          fontsize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.allJobs.length,
                itemBuilder: (context, index) {
                  final dem = provider.allJobs[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 10.0,
                      left: 10,
                      bottom: 10,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 218,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.tertiary),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: color.tertiary),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(dem.imageUrl),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        TitleWidget(
                                          text: dem.title,
                                          fontSize: 18,
                                        ),
                                        SizedBox(width: 5),
                                      ],
                                    ),
                                    SubTitle(
                                      text: dem.companyName,
                                      fontsize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),

                                    SubTitle(text: dem.postDate, fontsize: 12),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                dispo != nonDispo;
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide.none,
                                              backgroundColor:
                                                  dem.status == "Disponible"
                                                  ? color.bgA
                                                  : color.errorBg,
                                            ),
                                            child: dem.status == "Disponible"
                                                ? Center(
                                                    child: TitleWidget(
                                                      text: "Disponible",
                                                      fontSize: 12,
                                                      color: color.accepted,
                                                    ),
                                                  )
                                                : Center(
                                                    child: SizedBox(
                                                      width: 60,
                                                      child: Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        "Plus disponible",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: color.error,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        SizedBox(
                                          height: 30,
                                          child: OutlinedButton(
                                            onPressed: () {},
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide.none,
                                              backgroundColor: color.errorBg,
                                            ),
                                            child: Center(
                                              child: TitleWidget(
                                                text: "Supprimer",
                                                fontSize: 12,
                                                color: color.error,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Divider(color: color.tertiary, height: 2),
                            SizedBox(height: 17),
                            SizedBox(
                              height: 45,
                              child: BtnPage(texte: "Booster", route: "/boost"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SubTitle(
                    text: "Reccement applique",
                    fontWeight: FontWeight.w500,
                    fontsize: 18,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Vancy()),
                      );
                    },
                    child: SubTitle(
                      text: "Tout voir",
                      fontWeight: FontWeight.w500,
                      fontsize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList.builder(
            itemCount: user.allusers.length,
            itemBuilder: (context, index) {
              final users = user.allusers[index];
              return SizedBox(
                width: double.infinity,
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: color.bg,
                      border: Border.all(color: color.tertiary),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(color: color.tertiary),
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(users.photo),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleWidget(text: users.name),
                                  SubTitle(text: users.speciality),
                                  SubTitle(text: users.exp),
                                  Row(
                                    children: [
                                      HugeIcon(
                                        size: 18,
                                        icon: HugeIcons.strokeRoundedTime04,
                                      ),
                                      SizedBox(width: 3),
                                      SubTitle(text: users.postDate),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(color: color.tertiary),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                width: 150,
                                height: 40,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: color.primary,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserCvView(userCv: users),
                                      ),
                                    );
                                  },
                                  child: TitleWidget(
                                    text: "Voir CV",
                                    color: color.bg,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 150,
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ApplicantDetail(details: users),
                                      ),
                                    );
                                  },
                                  child: TitleWidget(
                                    text: "Voir detail",
                                    color: color.primary,
                                    fontSize: 16,
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
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostVancy()),
          );
        },
        child: Icon(Icons.add, color: color.bg),
      ),
    );
  }

  int value = 0;
  Widget menu(String label, int index) {
    bool selected = value == index;
    return GestureDetector(
      child: Container(
        width: 110,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? color.primary : color.bg,
          border: BoxBorder.all(
            color: selected ? color.primary : color.tertiary,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: selected ? color.bg : color.primary,
            ),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          value = index;
        });
      },
    );
  }

  Widget content() {
    if (value == 0) {
      return Column(
        children: [
          isSelected
              ? Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: Container(
                    width: double.infinity,
                    height: 218,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // border: Border.all(color: color.tertiary),
                      color: color.accepted,
                    ),
                  ),
                )
              : SizedBox(height: 20),
          isSelected
              ? Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: Container(
                    width: double.infinity,
                    height: 218,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // border: Border.all(color: color.tertiary),
                      color: color.accepted,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 218,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.tertiary),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: color.tertiary),
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    "https://tse2.mm.bing.net/th/id/OIP.HP55nAQfHY4mlb4v9MxJKAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3",
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitleWidget(
                                  text: "UI/UX Designer",
                                  fontSize: 18,
                                ),
                                SubTitle(
                                  text: "Google",
                                  fontsize: 16,
                                  fontWeight: FontWeight.w500,
                                ),

                                SubTitle(text: "Il y a 1 min", fontsize: 12),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        Divider(color: color.tertiary, height: 2),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.bgcour,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: TitleWidget(
                              color: color.cour,
                              text: "En attente ",
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          SizedBox(height: 20),
          isSelected
              ? Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: Container(
                    width: double.infinity,
                    height: 218,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // border: Border.all(color: color.tertiary),
                      color: color.accepted,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 218,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.tertiary),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: color.tertiary),
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    "https://tse2.mm.bing.net/th/id/OIP.HP55nAQfHY4mlb4v9MxJKAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3",
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitleWidget(
                                  text: "UI/UX Designer",
                                  fontSize: 18,
                                ),
                                SubTitle(
                                  text: "Google",
                                  fontsize: 16,
                                  fontWeight: FontWeight.w500,
                                ),

                                SubTitle(text: "Il y a 1 min", fontsize: 12),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        Divider(color: color.tertiary, height: 2),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.bgA,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: TitleWidget(
                              color: color.accepted,
                              text: "Accepte",
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          SizedBox(height: 20),
          isSelected
              ? Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: Container(
                    width: double.infinity,
                    height: 218,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // border: Border.all(color: color.tertiary),
                      color: color.accepted,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 218,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.tertiary),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: color.tertiary),
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    "https://tse2.mm.bing.net/th/id/OIP.HP55nAQfHY4mlb4v9MxJKAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3",
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitleWidget(
                                  text: "UI/UX Designer",
                                  fontSize: 18,
                                ),
                                SubTitle(
                                  text: "Google",
                                  fontsize: 16,
                                  fontWeight: FontWeight.w500,
                                ),

                                SubTitle(text: "Il y a 1 min", fontsize: 12),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        Divider(color: color.tertiary, height: 2),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.errorBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: TitleWidget(
                              color: color.error,
                              text: "Rejeté",
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      );
    } else if (value == 1) {
      return isSelected
          ? Shimmer.fromColors(
              baseColor: Colors.grey,
              highlightColor: Colors.white,
              child: Container(
                width: double.infinity,
                height: 218,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // border: Border.all(color: color.tertiary),
                  color: color.accepted,
                ),
              ),
            )
          : Container(
              width: double.infinity,
              height: 218,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.tertiary),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: color.tertiary),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                "https://tse2.mm.bing.net/th/id/OIP.HP55nAQfHY4mlb4v9MxJKAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleWidget(text: "UI/UX Designer", fontSize: 18),
                            SubTitle(
                              text: "Google",
                              fontsize: 16,
                              fontWeight: FontWeight.w500,
                            ),

                            SubTitle(text: "Il y a 1 min", fontsize: 12),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    Divider(color: color.tertiary, height: 2),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.bgA,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: TitleWidget(
                          color: color.accepted,
                          text: "Accepte",
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
    } else if (value == 2) {
      return isSelected
          ? Shimmer.fromColors(
              baseColor: Colors.grey,
              highlightColor: Colors.white,
              child: Container(
                width: double.infinity,
                height: 218,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // border: Border.all(color: color.tertiary),
                  color: color.accepted,
                ),
              ),
            )
          : SizedBox(
              height: 520,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    height: 218,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.tertiary),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: color.tertiary),
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      "https://tse2.mm.bing.net/th/id/OIP.HP55nAQfHY4mlb4v9MxJKAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleWidget(
                                    text: "UI/UX Designer",
                                    fontSize: 18,
                                  ),
                                  SubTitle(
                                    text: "Google",
                                    fontsize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),

                                  SubTitle(text: "Il y a 1 min", fontsize: 12),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          Divider(color: color.tertiary, height: 2),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.bgSubmit,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: TitleWidget(
                                color: color.primary,
                                text: "Planifié pour interview",
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
    } else {
      {
        return isSelected
            ? Shimmer.fromColors(
                baseColor: Colors.grey,
                highlightColor: Colors.white,
                child: Container(
                  width: double.infinity,
                  height: 218,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    // border: Border.all(color: color.tertiary),
                    color: color.accepted,
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                height: 218,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.tertiary),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: color.tertiary),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  "https://tse2.mm.bing.net/th/id/OIP.HP55nAQfHY4mlb4v9MxJKAHaEK?cb=12&rs=1&pid=ImgDetMain&o=7&rm=3",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleWidget(text: "UI/UX Designer", fontSize: 18),
                              SubTitle(
                                text: "Google",
                                fontsize: 16,
                                fontWeight: FontWeight.w500,
                              ),

                              SubTitle(text: "Il y a 1 min", fontsize: 12),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      Divider(color: color.tertiary, height: 2),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.errorBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: TitleWidget(
                            color: color.error,
                            text: "Rejeté ",
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
      }
    }
  }
}
