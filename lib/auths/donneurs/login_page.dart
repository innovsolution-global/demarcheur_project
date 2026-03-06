import 'package:demarcheur_app/apps/demandeurs/main_screens/dem_onboarding_page.dart';
import 'package:demarcheur_app/apps/donneurs/main_screens/dashboard_page.dart';
import 'package:demarcheur_app/apps/immo/immo_dashboard.dart';
import 'package:demarcheur_app/apps/prestataires/presta_dashboard.dart';
import 'package:demarcheur_app/auths/donneurs/forgot_password_page.dart';
import 'package:provider/provider.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/screens/decision_page.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool textVisible = true;
  bool isPhoneLogin = true;
  String _completePhone =
      ''; // Full phone with country code from IntlPhoneField

  final _keyForm = GlobalKey<FormState>();
  bool _isLoading = false;
  void _submit() async {
    if (!_keyForm.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    String loginItem;
    if (isPhoneLogin) {
      // Use the full international number captured from IntlPhoneField's onChanged
      // e.g. '+224623581928' instead of the national-only '623581928'
      loginItem = _completePhone.isNotEmpty
          ? _completePhone
          : emailController.text.trim().replaceAll(RegExp(r'\s+|-|\(|\)'), '');
      print(
        "DEBUG LOGIN: Sending Phone: '$loginItem' with length ${loginItem.length}",
      );
    } else {
      loginItem = emailController.text.trim();
      print(
        "DEBUG LOGIN: Sending Email: '$loginItem' with length ${loginItem.length}",
      );
    }

    final authProvider = context.read<AuthProvider>();
    final succes = await authProvider.authentification(
      loginItem,
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
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: color.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              backgroundColor: color.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  width: double.infinity,
                  //height: size.height * 0.35,
                  decoration: BoxDecoration(
                    color: color.primary,
                    image: const DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        "assets/background.png",
                      ), // Assuming a nice background
                      // colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
                    ),
                    borderRadius: const BorderRadius.only(
                      // bottomLeft: Radius.circular(40),
                      // bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  // child: SafeArea(
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Icon(
                  //         Icons.lock_person_rounded,
                  //         size: 60,
                  //         color: color.bg,
                  //       ),
                  //       const SizedBox(height: 15),
                  //       TitleWidget(
                  //         text: "Bienvenue !",
                  //         fontSize: 32,
                  //         color: color.bg,
                  //       ),
                  //       const SizedBox(height: 5),
                  //       SubTitle(
                  //         text: "Connectez-vous pour continuer",
                  //         fontsize: 16,
                  //         color: color.bg.withOpacity(0.9),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Modern Hero Header Segment
                  const SizedBox(height: 30),

                  // Login Form Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        TitleWidget(
                          text: "Se connecter",
                          fontSize: 28,
                          color: color.secondary,
                        ),
                        const SizedBox(height: 25),

                        Form(
                          key: _keyForm,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isPhoneLogin = true;
                                        emailController.clear();
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPhoneLogin
                                            ? color.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Téléphone",
                                        style: TextStyle(
                                          color: isPhoneLogin
                                              ? Colors.white
                                              : color.secondary.withOpacity(
                                                  0.6,
                                                ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isPhoneLogin = false;
                                        emailController.clear();
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: !isPhoneLogin
                                            ? color.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "E-mail",
                                        style: TextStyle(
                                          color: !isPhoneLogin
                                              ? Colors.white
                                              : color.secondary.withOpacity(
                                                  0.6,
                                                ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Email / Phone Field
                              isPhoneLogin
                                  ? IntlPhoneField(
                                      controller: emailController,
                                      keyboardType: TextInputType.phone,
                                      disableLengthCheck: true,
                                      initialCountryCode: 'GN',
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      onChanged: (phone) {
                                        _completePhone = phone.completeNumber;
                                      },
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: color.secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Numéro de téléphone",
                                        hintStyle: TextStyle(
                                          color: color.secondary.withOpacity(
                                            0.5,
                                          ),
                                          fontSize: 16,
                                        ),
                                        filled: true,
                                        fillColor: color.bgSubmit,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 20,
                                            ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: color.primary,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        errorStyle: TextStyle(
                                          color: color.error,
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: color.error,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      validator: (phone) {
                                        if (phone == null ||
                                            emailController.text.isEmpty) {
                                          return 'Le numéro de téléphone est requis';
                                        }
                                        return null;
                                      },
                                    )
                                  : TextFormField(
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) =>
                                          emailOrPhoneValidator(value),
                                      decoration: InputDecoration(
                                        hintText: "Adresse e-mail",
                                        hintStyle: TextStyle(
                                          color: color.secondary.withOpacity(
                                            0.5,
                                          ),
                                          fontSize: 16,
                                        ),
                                        fillColor: color.bgSubmit,
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: color.primary,
                                        ),
                                        filled: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 20,
                                            ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: color.primary,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        errorStyle: TextStyle(
                                          color: color.error,
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: color.error,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: color.secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                              const SizedBox(height: 20),

                              // Password Field
                              TextFormField(
                                obscureText: textVisible,
                                controller: passwordController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) => _passwordValidator(value),
                                obscuringCharacter: "•",
                                textInputAction: TextInputAction.done,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: color.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Mot de passe",
                                  hintStyle: TextStyle(
                                    color: color.secondary.withOpacity(0.5),
                                    fontSize: 16,
                                  ),
                                  fillColor: color.bgSubmit,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: color.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      textVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: color.primary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        textVisible = !textVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: color.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  errorStyle: TextStyle(color: color.error),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: color.error),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Forgot Password
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    "Mot de passe oublié ?",
                                    style: TextStyle(
                                      color: color.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Submit Button
                        Container(
                          height: 58,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: color.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: _isLoading ? null : _submit,
                            style: TextButton.styleFrom(
                              backgroundColor: color.primary,
                              //elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: color.bg,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : TitleWidget(
                                    text: "Se connecter",
                                    color: color.bg,
                                    fontSize: 20,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Social Login Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: color.tertiary.withOpacity(0.5),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: SubTitle(
                                text: "Ou continuer avec",
                                fontsize: 14,
                                color: color.secondary.withOpacity(0.6),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: color.tertiary.withOpacity(0.5),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialBtn("assets/google.png", "Google"),
                            const SizedBox(width: 20),
                            _buildSocialBtn("assets/facebook.png", "Facebook"),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Sign Up Link
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SubTitle(
                                text: "Vous n'avez pas de compte ? ",
                                fontsize: 15,
                                color: color.secondary.withValues(alpha: 0.8),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DecisionPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Créer un compte",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: color.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialBtn(String assetPath, String label) {
    return Container(
      width: 140,
      height: 50,
      decoration: BoxDecoration(
        color: color.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.tertiary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Social login action
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, width: 24, height: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
