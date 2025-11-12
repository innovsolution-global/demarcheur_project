import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/btn_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';

class DemImmo extends StatefulWidget {
  const DemImmo({super.key});

  @override
  State<DemImmo> createState() => _DemImmoState();
}

class _DemImmoState extends State<DemImmo> {
  ConstColors color = ConstColors();
  bool isSelected = true;
  @override
  void initState() {
    Future.delayed(Duration(microseconds: 100), () {
      setState(() {
        isSelected = false;
      });
    });
    super.initState();
  }

  bool isAcive = true;
  void status() {
    if (isAcive == true) {
      setState(() {
        isAcive = isAcive;
      });
    } else {
      setState(() {
        isAcive = !isAcive;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
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
                  Text(
                    "Mes annonces",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                itemCount: 5,
                itemBuilder: (context, index) {
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

                                    SubTitle(
                                      text: "Il y a 1 min",
                                      fontsize: 12,
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              status();
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide.none,
                                              backgroundColor: color.bgA,
                                            ),
                                            child: Center(
                                              child: TitleWidget(
                                                text: "Disponible",
                                                fontSize: 12,
                                                color: color.accepted,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        SizedBox(
                                          height: 30,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              status();
                                            },
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
        ],
      ),
    );
  }
}
