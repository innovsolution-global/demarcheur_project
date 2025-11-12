import 'package:demarcheur_app/apps/donneurs/main_screens/dashboard_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/screens/decision_page.dart';
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
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
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  obscureText: textVisible,
                                  obscuringCharacter: "*",
                                  controller: passwordController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
