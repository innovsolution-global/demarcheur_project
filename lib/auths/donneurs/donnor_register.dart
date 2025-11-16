import 'package:demarcheur_app/auths/donneurs/domain_pref_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/donor_register_provider.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class DonnorRegister extends StatefulWidget {
  const DonnorRegister({super.key});

  @override
  State<DonnorRegister> createState() => _DonnorRegisterState();
}

class _DonnorRegisterState extends State<DonnorRegister>
    with SingleTickerProviderStateMixin {
  ConstColors color = ConstColors();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorRegisterProvider>().initialize().then((_) {
        _animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: color.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TitleWidget(
                    text: "Choisissez une source",
                    fontSize: 22,
                    color: color.secondary,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildImageSourceOption(
                        context: context,
                        icon: Icons.photo_library_rounded,
                        label: "Galerie",
                        onTap: () {
                          Navigator.pop(context);
                          context
                              .read<DonorRegisterProvider>()
                              .pickImageFromGallery();
                        },
                      ),
                      _buildImageSourceOption(
                        context: context,
                        icon: Icons.camera_alt_rounded,
                        label: "Caméra",
                        onTap: () {
                          Navigator.pop(context);
                          context
                              .read<DonorRegisterProvider>()
                              .pickImageFromCamera();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: color.tertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color.primary),
            const SizedBox(height: 12),
            SubTitle(text: label, fontsize: 16, fontWeight: FontWeight.w600),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Consumer<DonorRegisterProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: color.tertiary,
              shape: BoxShape.circle,
              border: Border.all(color: color.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (provider.selectedImage != null)
                  ClipOval(
                    child: Image.file(
                      provider.selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                else
                  Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCamera01,
                      size: 40,
                      color: color.primary,
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: color.bg, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.add, color: color.bg, size: 24),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    required Function(String) onChanged,
    String? errorText,
    String? value,
    TextCapitalization? textCapitalization,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        initialValue: value,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 16,
          color: color.secondary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: color.secondary.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.tertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(prefixIcon, size: 20, color: color.primary),
          ),
          filled: true,
          fillColor: color.bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: errorText != null ? color.error : Colors.transparent,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: errorText != null ? color.error : color.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: color.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: color.error, width: 2),
          ),
          errorText: errorText,
          errorStyle: TextStyle(
            color: color.error,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<DonorRegisterProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.primary, color.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.primary.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: provider.isSubmitting
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      final success = await provider.submitForm();
                      if (success && mounted) {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const DomainPrefPage(),
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Veuillez remplir tous les champs correctement',
                            ),
                            backgroundColor: color.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 56,
                alignment: Alignment.center,
                child: provider.isSubmitting
                    ? SpinKitThreeBounce(color: color.bg, size: 24.0)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TitleWidget(
                            text: "Continuer",
                            fontSize: 18,
                            color: color.bg,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: color.bg,
                            size: 24,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DonorRegisterProvider>(
      builder: (context, provider, child) {
        if (provider.isInitialLoading) {
          return Scaffold(
            backgroundColor: color.bg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitThreeBounce(color: color.primary, size: 30.0),
                  const SizedBox(height: 24),
                  SubTitle(
                    text: "Chargement...",
                    fontsize: 16,
                    color: color.secondary,
                  ),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: color.bg,
            extendBodyBehindAppBar: true,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const Header(isLeading: true),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color.bg,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 8),
                              // Title
                              TitleWidget(
                                text: "Créer un compte",
                                fontSize: 32,
                                color: color.secondary,
                              ),
                              const SizedBox(height: 8),
                              SubTitle(
                                text:
                                    "Remplissez vos informations pour commencer",
                                fontsize: 14,
                                color: color.secondary.withOpacity(0.6),
                                fontWeight: FontWeight.w400,
                              ),
                              const SizedBox(height: 32),
                              // Image picker
                              _buildImagePicker(),
                              const SizedBox(height: 40),
                              // Form fields
                              _buildTextField(
                                hint: "Votre nom complet",
                                prefixIcon: Icons.person_outline_rounded,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                onChanged: provider.setFullName,
                                errorText: provider.fullNameError,
                                value: provider.fullName,
                              ),
                              _buildTextField(
                                hint: "Votre spécialité",
                                prefixIcon: Icons.work_outline_rounded,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onChanged: provider.setSpecialty,
                                errorText: provider.specialtyError,
                                value: provider.specialty,
                                textCapitalization: TextCapitalization.words,
                              ),
                              _buildTextField(
                                hint: "Votre adresse e-mail",
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onChanged: provider.setEmail,
                                errorText: provider.emailError,
                                value: provider.email,
                              ),
                              _buildTextField(
                                hint: "Votre numéro de téléphone",
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                onChanged: provider.setPhone,
                                errorText: provider.phoneError,
                                value: provider.phone,
                              ),
                              _buildTextField(
                                hint: "Votre localisation",
                                prefixIcon: Icons.location_on_outlined,
                                keyboardType: TextInputType.streetAddress,
                                textInputAction: TextInputAction.done,
                                onChanged: provider.setLocation,
                                errorText: provider.locationError,
                                textCapitalization: TextCapitalization.words,
                                value: provider.location,
                              ),
                              const SizedBox(height: 12),
                              // Submit button
                              _buildSubmitButton(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
