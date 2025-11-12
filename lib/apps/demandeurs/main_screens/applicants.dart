import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/dem_job_provider.dart';
import 'package:demarcheur_app/widgets/btn_page.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class Applicants extends StatefulWidget {
  const Applicants({super.key});

  @override
  State<Applicants> createState() => _ApplicantsState();
}

class _ApplicantsState extends State<Applicants> {
  ConstColors colors = ConstColors();

  @override
  void initState() {
    Future.microtask(() {
      final applica = context.read<DemJobProvider>();
      applica.loadVancies();
    });
    super.initState();
  }

  String dispo = "Disponible";
  String nonDispo = "Plus disponible";

  @override
  Widget build(BuildContext context) {
    final search = context.watch<DemJobProvider>();
    final applicant = search.allJobs;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: colors.bg,
        body: CustomScrollView(
          slivers: [
            Header(auto: true),
            search.isLoading
                ? SliverToBoxAdapter(
                    child: Center(
                      child: SpinKitThreeBounce(
                        color: colors.primary,
                        size: 30.0,
                      ),
                    ),
                  )
                : SliverList.builder(
                    itemCount: applicant.length,
                    itemBuilder: (context, index) {
                      final dem = applicant[index];
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 208,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.tertiary),
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
                                        border: Border.all(
                                          color: colors.tertiary,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(dem.imageUrl),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

                                        SubTitle(
                                          text: dem.postDate,
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
                                                  setState(() {
                                                    dispo != nonDispo;
                                                  });
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide.none,
                                                  backgroundColor:
                                                      dem.status == "Disponible"
                                                      ? colors.bgA
                                                      : colors.errorBg,
                                                ),
                                                child:
                                                    dem.status == "Disponible"
                                                    ? Center(
                                                        child: TitleWidget(
                                                          text: "Disponible",
                                                          fontSize: 12,
                                                          color:
                                                              colors.accepted,
                                                        ),
                                                      )
                                                    : Center(
                                                        child: SizedBox(
                                                          width: 60,
                                                          child: Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            "Plus disponible",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  colors.error,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            SizedBox(
                                              height: 30,
                                              width: 90,
                                              child: OutlinedButton(
                                                onPressed: () {},
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide.none,
                                                  backgroundColor:
                                                      colors.errorBg,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    "Supprimer",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: colors.error,
                                                    ),
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
                                Divider(color: colors.tertiary, height: 2),
                                SizedBox(height: 17),
                                SizedBox(
                                  height: 45,
                                  child: BtnPage(
                                    texte: "Booster",
                                    route: "/boost",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
