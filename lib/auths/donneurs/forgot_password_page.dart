import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/auths/donneurs/otp_verification_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
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
    final success = await authProvider.sendOtp(emailController.text.trim());

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Center(
              child: Text(
                'Code OTP envoyé par mail avec succès',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: emailController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Center(
              child: Text(
                authProvider.errorMessage ?? 'Erreur lors de l\'envoi du code. Vérifiez votre email.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }
    }
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  ConstColors color = ConstColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: color.secondary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _keyForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TitleWidget(
                  text: "Mot de passe oublié",
                  fontSize: 28,
                  color: color.secondary,
                ),
                const SizedBox(height: 10),
                SubTitle(
                  text: "Entrez votre email pour recevoir un code OTP",
                  fontsize: 16,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: emailValidator,
                  style: TextStyle(
                    fontSize: 18,
                    color: color.secondary,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: "Votre adresse e-mail",
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
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: color.primary,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : TitleWidget(
                            text: "Envoyer le code",
                            color: Colors.white,
                            fontSize: 18,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
