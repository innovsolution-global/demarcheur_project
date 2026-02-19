import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _keyForm = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _submit() async {
    if (!_keyForm.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      widget.email,
      passwordController.text,
      confirmPasswordController.text,
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
                'Mot de passe modifié avec succès',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
        // Navigate to login and clear stacks
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Center(
              child: Text(
                'Erreur lors de la modification du mot de passe.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }
    }
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 4) {
      return 'Le mot de passe doit contenir au moins 4 caractères';
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
                  text: "Nouveau mot de passe",
                  fontSize: 28,
                  color: color.secondary,
                ),
                const SizedBox(height: 10),
                SubTitle(
                  text: "Créez votre nouveau mot de passe pour ${widget.email}",
                  fontsize: 16,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  validator: passwordValidator,
                  style: TextStyle(
                    fontSize: 18,
                    color: color.secondary,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: "Nouveau mot de passe",
                    fillColor: color.bgSubmit,
                    prefixIcon: Icon(
                      Icons.lock,
                      color: color.secondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: color.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    errorStyle: TextStyle(color: color.error),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return passwordValidator(value);
                  },
                  style: TextStyle(
                    fontSize: 18,
                    color: color.secondary,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: "Confirmer le mot de passe",
                    fillColor: color.bgSubmit,
                    prefixIcon: Icon(
                      Icons.lock_outline,
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
                            text: "Réinitialiser",
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
