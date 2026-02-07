// main.dart logic updated to remove ChatPlugin and implement Splash/Onboarding

import 'package:demarcheur_app/apps/demandeurs/main_screens/boost_page.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/dem_home_page.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/dem_onboarding_page.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/dem_profile.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/vancy.dart';
import 'package:demarcheur_app/apps/prestataires/prestataire_select_page.dart';
import 'package:demarcheur_app/auths/donneurs/login_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/application_provider.dart';
import 'package:demarcheur_app/providers/compa_profile_provider.dart';
import 'package:demarcheur_app/providers/dem_job_provider.dart';
import 'package:demarcheur_app/providers/dem_user_provider.dart';
import 'package:demarcheur_app/providers/donnor_user_provider.dart';
import 'package:demarcheur_app/providers/enterprise_provider.dart';
import 'package:demarcheur_app/providers/house_provider.dart';
import 'package:demarcheur_app/providers/immo/immo_chat_provider.dart';
import 'package:demarcheur_app/providers/message_provider.dart';
import 'package:demarcheur_app/providers/chat/chat_provider.dart';
import 'package:demarcheur_app/providers/presta/presta_provider.dart';
import 'package:demarcheur_app/providers/presta/presta_user_provider.dart';
import 'package:demarcheur_app/providers/search_provider.dart';
import 'package:demarcheur_app/providers/user_provider.dart';
import 'package:demarcheur_app/providers/donor_register_provider.dart';
import 'package:demarcheur_app/providers/domain_pref_provider.dart';
import 'package:demarcheur_app/providers/settings_provider.dart';
import 'package:demarcheur_app/providers/candidature_provider.dart';
import 'package:demarcheur_app/screens/intro_onboarding_page.dart';
import 'package:demarcheur_app/screens/splash_screen.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/services/auth_service.dart';
import 'package:demarcheur_app/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.
  //[Storing C:\Users\alpho\upload-keystore.jks]
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    ensureConnection();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ensureConnection();
    } else if (state == AppLifecycleState.resumed) {}
    super.didChangeAppLifecycleState(state);
  }

  void ensureConnection() async {
    final token = await AuthService.getUserToken();
    final userId = await AuthService.getUser();

    if (token != null && userId != null) {
      print('DEBUG: main.dart - Initializing SocketService for user: $userId');
      SocketService().connect(token, userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HouseProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => DemJobProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CompaProfileProvider()),
        ChangeNotifierProvider(create: (_) => PrestaProvider()),
        ChangeNotifierProvider(create: (_) => ImmoChatProvider()),
        ChangeNotifierProvider(create: (_) => PrestaUserProvider()),
        ChangeNotifierProvider(create: (_) => DonorRegisterProvider()),
        ChangeNotifierProvider(create: (_) => DomainPrefProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DemUserProvider()),
        ChangeNotifierProvider(create: (_) => DonnorUserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadAuthData()),
        ChangeNotifierProvider(create: (_) => EnterpriseProvider()),
        ChangeNotifierProvider(create: (_) => CandidatureProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],

      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Demarcheur App',
            debugShowCheckedModeBanner: false,
            initialRoute: "/",
            locale: settings.locale,
            themeMode: settings.themeMode,
            routes: {
              "/": (context) => const SplashScreen(),
              "/intro_onboarding": (context) => const IntroOnboardingPage(),
              "/login": (context) => const LoginPage(),
              "/demhome": (context) => DemHomePage(),
              "/boost": (context) => BoostPage(),
              "/demonboarding": (context) => DemOnboardingPage(),
              // "/demmsg": (context) => DemMessage(),
              "/dempro": (context) => DemProfile(),
              "/vancy": (context) => Vancy(),
              "/prestataire": (context) => PrestataireSelectPage(),
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: ConstColors().primary,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                surfaceTintColor: Colors.transparent,
              ),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: ConstColors().primary,
                brightness: Brightness.dark,
              ),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
          );
        },
      ),
    );
  }
}
