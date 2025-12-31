import 'package:chat_plugin/chat_plugin.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/boost_page.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/dem_home_page.dart';
import 'package:demarcheur_app/apps/demandeurs/main_screens/dem_message.dart';
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
import 'package:demarcheur_app/providers/presta/presta_provider.dart';
import 'package:demarcheur_app/providers/chat/chat_provider.dart';
import 'package:demarcheur_app/providers/presta/presta_user_provider.dart';
import 'package:demarcheur_app/providers/search_provider.dart';
import 'package:demarcheur_app/providers/user_provider.dart';
import 'package:demarcheur_app/providers/donor_register_provider.dart';
import 'package:demarcheur_app/providers/domain_pref_provider.dart';
import 'package:demarcheur_app/providers/settings_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AuthService.logedUser();
  if (isLoggedIn == true) {
    await AuthService.initilizedChatPlugin();
  }
  runApp(MyApp(isLoggedIn: isLoggedIn!));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (widget.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {});
      ensureConnection();
    }
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isLoggedIn) return;
    if (state == AppLifecycleState.resumed) {
      ensureConnection();
    } else if (state == AppLifecycleState.resumed) {
      try {
        final chatService = ChatPlugin.chatService;
        chatService.updateUserStatus(false);
      } catch (ex) {}
    }
    super.didChangeAppLifecycleState(state);
  }

  void ensureConnection() async {
    if (ChatConfig.instance.userId != null) {
      try {
        final chatService = ChatPlugin.chatService;
        if (!chatService.isSocketConnected) {
          await chatService.initGlobalConnection();
        } else {
          chatService.refreshGlobalConnection();
        }
        chatService.updateUserStatus(true);
      } catch (ex) {
        throw "this is the $ex";
      }
    } else {
      await AuthService.initilizedChatPlugin();
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
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ImmoChatProvider()),
        ChangeNotifierProvider(create: (_) => PrestaUserProvider()),
        ChangeNotifierProvider(create: (_) => DonorRegisterProvider()),
        ChangeNotifierProvider(create: (_) => DomainPrefProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DemUserProvider()),
        ChangeNotifierProvider(create: (_) => DonnorUserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EnterpriseProvider()),
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
              //"/": (context) => InitializeWidget(),
              "/demhome": (context) => DemHomePage(),
              "/boost": (context) => BoostPage(),
              "/demonboarding": (context) => DemOnboardingPage(),
              "/demmsg": (context) => DemMessage(),
              "/dempro": (context) => DemProfile(),
              "/vancy": (context) => Vancy(),
              "/prestataire": (context) => PrestataireSelectPage(),
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: ConstColors().primary,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: ConstColors().primary,
                brightness: Brightness.dark,
              ),
            ),
            home: const LoginPage(),
          );
        },
      ),
    );
  }
}

class InitializeWidget extends StatefulWidget {
  const InitializeWidget({super.key});

  @override
  State<InitializeWidget> createState() => _InitializeWidgetState();
}

class _InitializeWidgetState extends State<InitializeWidget> {
  String? initilizeRoute;
  @override
  void initState() {
    super.initState();
    _connectionState();
  }

  Future<void> _connectionState() async {
    final isLoggedIn = await AuthService.logedUser();
    if (isLoggedIn == true) {
      initilizeRoute = "/login";
    } else {
      initilizeRoute = "/landing";
    }
    Navigator.of(context).pushReplacementNamed(initilizeRoute!);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
