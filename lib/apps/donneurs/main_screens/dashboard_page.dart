import 'package:demarcheur_app/apps/donneurs/main_screens/houses/immo_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/jobs/application_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/jobs/home_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/jobs/message_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/jobs/profile_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';
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
    ImmoPage(),
    ApplicationPage(),
    MessagePage(),
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
      drawer: Drawer(),

      backgroundColor: color.bg,
      body: pages[currentPage],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: color.tertiary)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GNav(
            tabMargin: EdgeInsetsGeometry.all(3),
            gap: 5,
            iconSize: 26,

            //padding: EdgeInsetsGeometry.all(80),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            tabBackgroundColor: color.tertiary,
            selectedIndex: currentPage,
            onTabChange: (value) {
              selectedPage(value);
            },
            activeColor: color.primary,

            tabs: [
              GButton(
                iconColor: color.primary,
                iconActiveColor: color.primary,
                icon: Icons.home,
                text: "Accueil",

                padding: EdgeInsets.all(10),
                borderRadius: BorderRadius.circular(16),
              ),
              GButton(
                iconColor: color.primary,
                iconActiveColor: color.primary,
                icon: Icons.real_estate_agent,
                text: "Immobilier",
                borderRadius: BorderRadius.circular(16),

                padding: EdgeInsets.all(10),
              ),
              GButton(
                borderRadius: BorderRadius.circular(16),
                iconColor: color.primary,
                iconActiveColor: color.primary,
                icon: Icons.work,
                text: "Demande",
                padding: EdgeInsets.all(10),
              ),
              GButton(
                borderRadius: BorderRadius.circular(16),

                iconColor: color.primary,
                iconActiveColor: color.primary,
                icon: Icons.message,
                text: "Message",
                padding: EdgeInsets.all(10),
              ),
              GButton(
                borderRadius: BorderRadius.circular(16),
                iconColor: color.primary,
                iconActiveColor: color.primary,
                icon: Icons.person,
                text: "Profil",
                padding: EdgeInsets.all(10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
