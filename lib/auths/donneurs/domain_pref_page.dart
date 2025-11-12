import 'package:demarcheur_app/apps/donneurs/main_screens/dashboard_page.dart';
import 'package:demarcheur_app/auths/donneurs/sign_up.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DomainPrefPage extends StatefulWidget {
  const DomainPrefPage({super.key});

  @override
  State<DomainPrefPage> createState() => _DomainPrefPageState();
}

class _DomainPrefPageState extends State<DomainPrefPage> {
  bool isloading = true;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        isloading = false;
      });
    });
  }

  ConstColors color = ConstColors();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: isloading
          ? Scaffold(
              backgroundColor: color.bg,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SpinKitThreeBounce(color: color.primary, size: 20.0),
                ),
              ),
            )
          : Scaffold(
              backgroundColor: color.bg,
              extendBodyBehindAppBar: true,
              body: CustomScrollView(
                slivers: [
                  Header(isLeading: true),
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      color: color.bg,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SubTitle(
                              text: "Quel poste vous\ninteresse?",
                              fontsize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                            SizedBox(height: 4),
                            SubTitle(
                              text:
                                  "Choisissez-en un ci-dessous et nous\nvous proposerons des offres apdatees\na votre profil",
                              fontsize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SubTitle(
                                  text: "Ingenerie logicielle et Informatique",
                                  fontWeight: FontWeight.w500,
                                  fontsize: 16,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement Mobile",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement web",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Fullstack development",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Python development",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "React native",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "React development",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Flutter development",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Frontend development",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                SubTitle(
                                  text:
                                      "Ingenerie cyber securite et Informatique",
                                  fontWeight: FontWeight.w500,
                                  fontsize: 16,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Cyber securite",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Administateur reseau",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: color.bg,
                                      border: Border.all(
                                        color: color.secondary,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: SubTitle(
                                        text: "Administateur systeme",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                SubTitle(
                                  text: "Science des donnees",
                                  fontsize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Data science",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Ingenerie de donnees",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: color.bg,
                                      border: Border.all(
                                        color: color.secondary,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: SubTitle(
                                        text: "Analyse de donnees",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SubTitle(
                                  text: "Ingenerie logicielle et Informatique",
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement Mobile",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.tertiary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement web",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SubTitle(
                                  text: "Ingenerie logicielle et Informatique",
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement Mobile",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.tertiary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement web",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SubTitle(
                                  text: "Ingenerie logicielle et Informatique",
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement Mobile",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.tertiary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement web",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SubTitle(
                                  text: "Ingenerie logicielle et Informatique",
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement Mobile",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.tertiary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement web",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SubTitle(
                                  text: "Ingenerie logicielle et Informatique",
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement Mobile",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.tertiary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement web",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SubTitle(
                                  text: "Ingenerie logicielle et Informatique",
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                const SignupPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.secondary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement Mobile",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2.2,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.bg,
                                          border: Border.all(
                                            color: color.tertiary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: SubTitle(
                                            text: "Developpement web",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          const DashboardPage(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: color.primary,
                                ),
                                child: TitleWidget(
                                  text: "Suivant",
                                  color: color.bg,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
