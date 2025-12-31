import 'dart:io';
import 'package:demarcheur_app/apps/immo/immo_dashboard.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/methods/my_methodes.dart';
import 'package:demarcheur_app/widgets/immo_header.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class ImmoRegistrationPage extends StatefulWidget {
  const ImmoRegistrationPage({super.key});

  @override
  State<ImmoRegistrationPage> createState() => _ImmoRegistrationPageState();
}

class _ImmoRegistrationPageState extends State<ImmoRegistrationPage>
    with SingleTickerProviderStateMixin {
  final MyMethodes methodes = MyMethodes();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Separate controllers for each field
  final _companyNameController = TextEditingController();
  final _domainController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();

  File? selectedImage;
  bool isLoading = false;
  bool isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _domainController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection de l\'image', isError: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ConstColors().bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ConstColors().tertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            TitleWidget(
              text: "Choisir une image",
              fontSize: 20,
              color: ConstColors().secondary,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageSourceOption(
                  icon: Icons.camera,
                  label: "Galerie",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _ImageSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: "Caméra",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : ConstColors().primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedImage == null) {
      _showSnackBar(
        'Veuillez sélectionner un logo d\'entreprise',
        isError: true,
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        isSubmitting = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ImmoDashboard()),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    if (value.length < 8) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final color = ConstColors();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: color.bg,
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          slivers: [
            const ImmoHeader(auto: true),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  color: color.bg,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildImageSelector(),
                        _buildFormFields(),
                        _buildSubmitButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TitleWidget(
            text: "Créer un compte",
            fontSize: 32,
            color: ConstColors().secondary,
          ),
          const SizedBox(height: 8),
          SubTitle(
            text: "Rejoignez notre plateforme immobilière",
            fontsize: 16,
            color: ConstColors().primary,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelector() {
    final color = ConstColors();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: selectedImage != null
                    ? Colors.transparent
                    : color.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.primary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: selectedImage != null
                    ? DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCamera01,
                          color: color.primary,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        SubTitle(
                          text: "Ajouter",
                          fontsize: 14,
                          color: color.primary,
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedEdit02,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SubTitle(
            text: "Logo de l'entreprise",
            fontWeight: FontWeight.w600,
            fontsize: 18,
            color: ConstColors().secondary,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _CustomTextField(
            controller: _companyNameController,
            label: "Nom de l'entreprise",
            textCapitalization: TextCapitalization.sentences,

            icon: HugeIcons.strokeRoundedBuilding01,
            validator: (value) =>
                _validateRequired(value, "Le nom de l'entreprise"),
          ),
          const SizedBox(height: 20),
          _CustomTextField(
            controller: _domainController,
            textCapitalization: TextCapitalization.sentences,

            label: "Domaine d'activité",
            icon: HugeIcons.strokeRoundedBriefcase01,
            validator: (value) =>
                _validateRequired(value, "Le domaine d'activité"),
          ),
          const SizedBox(height: 20),
          _CustomTextField(
            controller: _emailController,
            textCapitalization: TextCapitalization.none,

            label: "Adresse e-mail",
            icon: HugeIcons.strokeRoundedMail01,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          _CustomTextField(
            controller: _phoneController,
            textCapitalization: TextCapitalization.none,

            label: "Numéro de téléphone",
            icon: HugeIcons.strokeRoundedAiPhone01,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
          const SizedBox(height: 20),
          _CustomTextField(
            controller: _locationController,
            textCapitalization: TextCapitalization.sentences,
            label: "Localisation",
            icon: HugeIcons.strokeRoundedLocation01,
            validator: (value) => _validateRequired(value, "La localisation"),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          _CustomTextField(
            textCapitalization: TextCapitalization.none,
            controller: _passwordController,
            label: "Mot de passe",
            icon: HugeIcons.strokeRoundedLocation01,
            validator: (value) => _validateRequired(value, "Mot de passe"),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstColors().primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: ConstColors().primary.withValues(
                  alpha: 0.6,
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Créer mon compte",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final dynamic icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.textCapitalization,
    this.keyboardType,
    this.validator,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = ConstColors();

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: textInputAction ?? TextInputAction.next,
      validator: validator,
      style: TextStyle(fontSize: 16, color: color.secondary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color.primary, fontSize: 16),
        // prefixIcon: HugeIcon(icon: icon, color: color.primary, size: 10),
        filled: true,
        fillColor: color.bgSubmit,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color.primary, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = ConstColors();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.primary.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color.primary, size: 32),
            const SizedBox(height: 8),
            SubTitle(
              text: label,
              fontsize: 16,
              color: color.secondary,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
