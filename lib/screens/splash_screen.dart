import 'package:demarcheur_app/apps/demandeurs/main_screens/dem_onboarding_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/dashboard_page.dart';
import 'package:demarcheur_app/apps/immo/immo_dashboard.dart';
import 'package:demarcheur_app/apps/prestataires/presta_dashboard.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/services/auth_service.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 5));

    final isLoggedIn = await AuthService.logedUser();
    if (!mounted) return;

    if (isLoggedIn == true) {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role');

      Widget targetPage;

      if (role == 'SEARCHER') {
        targetPage = const DashboardPage();
      } else if (role == 'GIVER') {
        targetPage = const DemOnboardingPage();
      } else if (role == 'IMMO') {
        targetPage = const ImmoDashboard();
      } else if (role == 'SERVICE') {
        targetPage = const PrestaDashboard();
      } else {
        // Fallback or default
        targetPage = const DemOnboardingPage();
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => targetPage));
    } else {
      Navigator.of(context).pushReplacementNamed("/intro_onboarding");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: ConstColors().primary, // Using existing bg color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/demalogo.png', width: 150, height: 150)
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .fadeIn(),
            TitleWidget(
              text: 'Démarcheur',
              color: ConstColors().bg,
              fontSize: 24,
            ),
            const SizedBox(height: 30),
            // Spinner
            SpinKitThreeBounce(color: ConstColors().bg, size: 25.0),
          ],
        ),
      ),
    );
  }
}
