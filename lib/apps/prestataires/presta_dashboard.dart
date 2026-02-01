import 'package:demarcheur_app/apps/prestataires/presta_home_page.dart';
import 'package:demarcheur_app/apps/prestataires/presta_message_page.dart';
import 'package:demarcheur_app/apps/prestataires/presta_profile_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class PrestaDashboard extends StatefulWidget {
  const PrestaDashboard({super.key});

  @override
  State<PrestaDashboard> createState() => _PrestaDashboardState();
}

class _PrestaDashboardState extends State<PrestaDashboard> {
  bool isloading = true;
  @override
  initState() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        isloading = false;
      });
    });
    super.initState();
  }

  int currentPage = 0;
  final List pages = [
    PrestaHomePage(),
    PrestaMessagePage(),
    PrestaProfilePage(),
  ];
  void selectedPage(int value) {
    setState(() {
      currentPage = value;
    });
  }

  ConstColors color = ConstColors();
  @override
  Widget build(BuildContext context) {
    return isloading
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
            body: pages[currentPage],
            bottomNavigationBar: SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: color.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: GNav(
                  gap: 8,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: color.primary,
                  color: color.secondary.withOpacity(0.6),
                  selectedIndex: currentPage,
                  onTabChange: (index) {
                    selectedPage(index);
                  },
                  tabs: [
                    GButton(
                      icon: currentPage == 0
                          ? IconlyBold.home
                          : IconlyLight.home,
                      text: 'Acceuil',
                      padding: EdgeInsets.all(10),
                    ),
                    GButton(
                      icon: currentPage == 1
                          ? IconlyBold.message
                          : IconlyLight.message,
                      text: 'Message',
                      padding: EdgeInsets.all(10),
                    ),
                    GButton(
                      icon: currentPage == 2
                          ? IconlyBold.profile
                          : IconlyLight.profile,
                      padding: EdgeInsets.all(10),
                      text: 'Profil',
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
