
import 'package:demarcheur_app/auths/donneurs/domain_pref_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  ConstColors color = ConstColors();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   leading: IconButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     icon: Icon(Icons.arrow_back_outlined, color: color.bg, size: 30),
        //   ),
        // ),
        backgroundColor: color.bg,
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          slivers: [
            Header(isLeading: true,),
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
                              text: "Creer un compte",
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
                                      text: "Prenoms",
                                      fontsize: 16,
                                    ),
                                    fillColor: color.bgSubmit,
                                    prefixIcon: Icon(
                                      Icons.person,
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
                                TextFormField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hint: SubTitle(text: "Nom", fontsize: 16),
                                    fillColor: color.bgSubmit,

                                    prefixIcon: Icon(
                                      Icons.person,
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
                                TextFormField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hint: SubTitle(
                                      text: "Adresse e-mail",
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
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hint: SubTitle(
                                      text: "Numero de telephone",
                                      fontsize: 16,
                                    ),
                                    fillColor: color.bgSubmit,

                                    prefixIcon: Icon(
                                      Icons.phone,
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
                                TextFormField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    hint: SubTitle(
                                      text: "Localisation",
                                      fontsize: 16,
                                    ),
                                    fillColor: color.bgSubmit,

                                    prefixIcon: Icon(
                                      Icons.location_on,
                                      color: color.secondary,
                                    ),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
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
                                // Navigator.push<void>(
                                //   context,
                                //   MaterialPageRoute<void>(
                                //     builder: (BuildContext context) =>
                                //         const DomainPrefPage(),
                                //   ),
                                // );
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
