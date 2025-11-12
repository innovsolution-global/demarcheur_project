import 'package:demarcheur_app/apps/immo/immo_home_page.dart';
import 'package:demarcheur_app/apps/immo/immo_message_page.dart';
import 'package:demarcheur_app/apps/immo/immo_profile_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ImmoDashboard extends StatefulWidget {
  const ImmoDashboard({super.key});

  @override
  State<ImmoDashboard> createState() => _ImmoDashboardState();
}

class _ImmoDashboardState extends State<ImmoDashboard> {
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
  final List pages = [ImmoHomePage(), ImmoMessagePage(), ImmoProfilePage()];
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
                      active: true,
                      iconColor: color.primary,
                      iconActiveColor: color.primary,
                      icon: Icons.home,
                      text: "Accueil",

                      padding: EdgeInsets.all(10),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    GButton(
                      active: true,
                      borderRadius: BorderRadius.circular(16),
                      iconColor: color.primary,
                      iconActiveColor: color.primary,
                      icon: Icons.message,
                      text: "Message",
                      padding: EdgeInsets.all(10),
                    ),

                    GButton(
                      active: true,
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
