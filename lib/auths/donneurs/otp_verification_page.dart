import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/auths/donneurs/reset_password_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final otpController = TextEditingController();
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
    final success = await authProvider.verifyOtp(
      widget.email,
      otpController.text.trim(),
    );

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
                'Code OTP vérifié avec succès',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Center(
              child: Text(
                'Code OTP invalide. Veuillez réessayer.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }
    }
  }

  String? otpValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le code OTP est requis';
    }
    if (value.trim().length < 4) {
      return 'Le code OTP doit contenir au moins 4 chiffres';
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
                  text: "Vérification OTP",
                  fontSize: 28,
                  color: color.secondary,
                ),
                const SizedBox(height: 10),
                SubTitle(
                  text: "Entrez le code envoyé à ${widget.email}",
                  fontsize: 16,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  validator: otpValidator,
                  style: TextStyle(
                    fontSize: 18,
                    color: color.secondary,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: "Code OTP",
                    fillColor: color.bgSubmit,
                    prefixIcon: Icon(
                      Icons.lock_clock,
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
                            text: "Vérifier",
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
