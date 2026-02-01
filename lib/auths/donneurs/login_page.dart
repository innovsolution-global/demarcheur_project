import 'package:demarcheur_app/apps/demandeurs/main_screens/dem_onboarding_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/dashboard_page.dart';
import 'package:demarcheur_app/apps/immo/immo_dashboard.dart';
import 'package:demarcheur_app/apps/prestataires/presta_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/screens/decision_page.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool textVisible = true;

  final _keyForm = GlobalKey<FormState>();
  bool _isLoading = false;
  void _submit() async {
    if (!_keyForm.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final authProvider = context.read<AuthProvider>();
    final succes = await authProvider.authentification(
      emailController.text,
      passwordController.text,
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    final role = authProvider.role;
    print("DEBUG: User role is $role");
    if (succes && role == 'SEARCHER') {
      // TODO: Handle navigation based on role (SEARCHER, GIVER, IMMO, PRESTATAIRE)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text(
              'Vous êtes connecté avec succès',
              style: TextStyle(color: color.bg),
            ),
          ),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else if (succes && role == 'GIVER') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text(
              'Vous êtes connecté avec succès',
              style: TextStyle(color: color.bg),
            ),
          ),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DemOnboardingPage()),
      );
    } else if (succes && role == 'IMMO') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text(
              'Vous êtes connecté avec succès',
              style: TextStyle(color: color.bg),
            ),
          ),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImmoDashboard()),
      );
    } else if (succes && role == 'SERVICE') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text(
              'Vous êtes connecté avec succès',
              style: TextStyle(color: color.bg),
            ),
          ),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrestaDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Center(
            child: Text(
              'Verifiez vos informations',
              style: TextStyle(color: color.bg),
            ),
          ),
        ),
      );
    }
  }

  String? emailOrPhoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email ou le numéro est requis';
    }

    final input = value.trim();

    // Email regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    // Phone number regex (international + local)
    final phoneRegex = RegExp(r'^(\+?[0-9]{8,15})$');

    if (emailRegex.hasMatch(input) || phoneRegex.hasMatch(input)) {
      return null; // valid
    }

    return 'Format d\'email ou numéro invalide';
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 4) {
      return 'Format de mot de passe invalide il doit contenir au moins 4 caracteres';
    }
    return null;
  }

  ConstColors color = ConstColors();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: color.bg,
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              automaticallyImplyLeading: false,
              iconTheme: IconThemeData(color: color.bg),
              actionsIconTheme: IconThemeData(color: color.bg),
              backgroundColor: Colors.transparent,
              // title: Text(
              //   titlteText,
              //   style: TextStyle(
              //     color: color.bg,
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
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
              child: Container(
                width: double.infinity,
                color: color.bg,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Form(
                        child: Column(
                          children: [
                            SizedBox(height: 6),
                            TitleWidget(
                              text: "Se connecter",
                              fontSize: 30,
                              color: color.secondary,
                            ),
                            SizedBox(height: 16),
                            Form(
                              key: _keyForm,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) =>
                                        emailOrPhoneValidator(value),
                                    decoration: InputDecoration(
                                      hint: SubTitle(
                                        text: "E-mail ou numero de telephone",
                                        fontsize: 16,
                                      ),
                                      fillColor: color.bgSubmit,
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: color.secondary,
                                      ),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      errorStyle: TextStyle(color: color.error),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: color.error,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: color.secondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    obscureText: textVisible,
                                    validator: (value) =>
                                        _passwordValidator(value),
                                    obscuringCharacter: "*",
                                    controller: passwordController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: color.secondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      helperStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      hint: SubTitle(
                                        text: "Mot de passe",
                                        fontsize: 16,
                                      ),
                                      fillColor: color.bgSubmit,
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            textVisible = !textVisible;
                                          });
                                        },
                                        child: textVisible
                                            ? Icon(
                                                Icons.visibility_off,
                                                color: color.secondary,
                                              )
                                            : Icon(
                                                Icons.visibility,
                                                color: color.secondary,
                                              ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: color.secondary,
                                      ),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      errorStyle: TextStyle(color: color.error),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: color.error,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  GestureDetector(
                                    child: SubTitle(
                                      text: "Mot de passe oublie?",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _isLoading ? null : _submit();
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    16,
                                  ),
                                ),
                                backgroundColor: color.primary,
                              ),
                              child: _isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: color.bg,
                                        ),
                                      ),
                                    )
                                  : TitleWidget(
                                      text: "Se connecter",
                                      color: color.bg,
                                      fontSize: 20,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SubTitle(
                      text: "Ou",
                      //fontWeight: FontWeight.bold,
                      fontsize: 16,
                    ),
                    SubTitle(
                      text: "Connectez-vous avec",
                      //fontWeight: FontWeight.bold,
                      fontsize: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 135,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: color.tertiary),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/google.png"),
                                SizedBox(width: 5),
                                SubTitle(text: "Google", fontsize: 16),
                              ],
                            ),
                          ),

                          SizedBox(width: 10),
                          Container(
                            width: 135,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: color.tertiary),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/facebook.png"),
                                SizedBox(width: 5),
                                SubTitle(text: "Facebook", fontsize: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SubTitle(
                          text: "Vous n'avez pas un compte?",
                          fontsize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DecisionPage(),
                              ),
                            );
                          },
                          child: Center(
                            child: TitleWidget(
                              text: "Creer un compte",
                              fontSize: 16,
                              color: color.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
