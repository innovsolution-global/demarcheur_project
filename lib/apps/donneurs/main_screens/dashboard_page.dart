import 'package:demarcheur_app/apps/donneurs/main_screens/jobs/application_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/jobs/home_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/jobs/message.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/jobs/profile_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ConstColors color = ConstColors();
  List pages = [
    HomePage(),
    // ImmoPage(),
    ApplicationPage(),
    Message(),
    ProfilePage(),
  ];
  int currentPage = 0;
  void selectedPage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: Drawer(),
      backgroundColor: color.bg,
      body: pages[currentPage],
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: color.primary,
            color: color.secondary.withOpacity(0.6),
            selectedIndex: currentPage,
            onTabChange: (index) {
              selectedPage(index);
            },
            tabs: [
              GButton(
                icon: currentPage == 0 ? IconlyBold.home : IconlyLight.home,
                text: 'Acceuil',
                padding: EdgeInsets.all(10),
              ),
              GButton(
                icon: currentPage == 1 ? IconlyBold.work : IconlyLight.work,
                text: 'Mes demandes',
                padding: EdgeInsets.all(10),
              ),
              GButton(
                icon: currentPage == 2
                    ? IconlyBold.message
                    : IconlyLight.message,
                text: 'Message',
                padding: EdgeInsets.all(10),
              ),
              GButton(
                icon: currentPage == 3
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
