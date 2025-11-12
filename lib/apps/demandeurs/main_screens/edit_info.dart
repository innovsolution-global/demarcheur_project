import 'dart:io';

import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/btn.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart' show TitleWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class EditInfo extends StatefulWidget {
  const EditInfo({super.key});

  @override
  State<EditInfo> createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Individual controllers for each field
  final _companyNameController = TextEditingController();
  final _domainController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  File? selectedImage;
  bool _isLoading = false;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _companyNameController.dispose();
    _domainController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
        _imageError = null;
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _imageError = 'Erreur lors de la sélection de l\'image';
      });
      _showErrorSnackBar(
        'Erreur lors de la sélection de l\'image: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImagePickerBottomSheet(
        onCameraPressed: () => _pickImage(ImageSource.camera),
        onGalleryPressed: () => _pickImage(ImageSource.gallery),
        onRemovePressed: selectedImage != null ? _removeImage : null,
      ),
    );
  }

  void _removeImage() {
    setState(() {
      selectedImage = null;
      _imageError = null;
    });
    Navigator.pop(context);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _showSuccessSnackBar('Informations mises à jour avec succès!');

      // Navigate back or to next screen
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la mise à jour: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConstColors color = ConstColors();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: color.bg,
        body: CustomScrollView(
          slivers: [
            const Header(auto: true),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Center(
                          child: TitleWidget(
                            text: "Modifier les infos",
                            fontSize: 28,
                            color: color.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: SubTitle(
                            text:
                                "Mettez à jour vos informations professionnelles",
                            fontsize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Profile Image Section
                        _buildImageSection(color),
                        const SizedBox(height: 32),

                        // Form Fields
                        _buildFormFields(color),
                        const SizedBox(height: 32),

                        // Submit Button
                        _buildSubmitButton(color),
                        const SizedBox(height: 20),
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

  Widget _buildImageSection(ConstColors color) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _showImagePicker,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color.tertiary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _imageError != null ? Colors.red : color.primary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(selectedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCamera01,
                          color: color.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        SubTitle(
                          text: "Ajouter",
                          fontsize: 12,
                          color: color.primary,
                        ),
                      ],
                    ),
            ),
          ),
          if (selectedImage != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: color.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: _showImagePicker,
                ),
              ),
            ),
          const SizedBox(height: 12),
          SubTitle(
            text: "Logo de l'entreprise",
            fontWeight: FontWeight.w600,
            fontsize: 16,
            color: color.secondary,
          ),
          if (_imageError != null) ...[
            const SizedBox(height: 4),
            Text(
              _imageError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormFields(ConstColors color) {
    return Column(
      children: [
        _buildCustomTextField(
          controller: _companyNameController,
          label: "Nom de l'entreprise",
          hint: "Entrez le nom de votre entreprise",
          icon: HugeIcons.strokeRoundedBuilding01,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom de l\'entreprise est obligatoire';
            }
            if (value.trim().length < 2) {
              return 'Le nom doit contenir au moins 2 caractères';
            }
            return null;
          },
          color: color,
        ),
        const SizedBox(height: 20),

        _buildCustomTextField(
          controller: _domainController,
          label: "Domaine d'activité",
          hint: "Ex: Informatique, Commerce, etc.",
          icon: HugeIcons.strokeRoundedBriefcase01,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le domaine d\'activité est obligatoire';
            }
            return null;
          },
          color: color,
        ),
        const SizedBox(height: 20),

        _buildCustomTextField(
          controller: _emailController,
          label: "Adresse e-mail",
          hint: "exemple@email.com",
          icon: HugeIcons.strokeRoundedMail01,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'L\'adresse e-mail est obligatoire';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Veuillez entrer une adresse e-mail valide';
            }
            return null;
          },
          color: color,
        ),
        const SizedBox(height: 20),

        _buildCustomTextField(
          controller: _phoneController,
          label: "Numéro de téléphone",
          hint: "+33 6 12 34 56 78",
          icon: HugeIcons.strokeRoundedCall,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le numéro de téléphone est obligatoire';
            }
            if (value.replaceAll(RegExp(r'[^\d]'), '').length < 10) {
              return 'Veuillez entrer un numéro valide';
            }
            return null;
          },
          color: color,
        ),
        const SizedBox(height: 20),

        _buildCustomTextField(
          controller: _locationController,
          label: "Localisation",
          hint: "Ville, Pays",
          icon: HugeIcons.strokeRoundedLocation01,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La localisation est obligatoire';
            }
            return null;
          },
          color: color,
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required List<List<dynamic>> icon,
    required String? Function(String?) validator,
    required ConstColors color,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(
          text: label,
          fontWeight: FontWeight.w600,
          fontsize: 16,
          color: color.secondary,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          textInputAction: TextInputAction.next,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: HugeIcon(icon: icon, color: color.primary, size: 20),
            ),
            fillColor: color.bgSubmit,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color.primary, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1),
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
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ConstColors color) {
    return SizedBox(
      width: double.infinity,
      child: _isLoading
          ? Container(
              height: 50,
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : Btn(texte: "Mettre à jour", function: _submitForm),
    );
  }
}

class _ImagePickerBottomSheet extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback? onRemovePressed;

  const _ImagePickerBottomSheet({
    required this.onCameraPressed,
    required this.onGalleryPressed,
    this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final ConstColors color = ConstColors();

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            TitleWidget(
              text: "Choisir une option",
              fontSize: 20,
              color: color.secondary,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  icon: HugeIcons.strokeRoundedImage02,
                  label: "Galerie",
                  onTap: onGalleryPressed,
                  color: color,
                ),
                _buildOptionButton(
                  icon: HugeIcons.strokeRoundedCamera01,
                  label: "Caméra",
                  onTap: onCameraPressed,
                  color: color,
                ),
                if (onRemovePressed != null)
                  _buildOptionButton(
                    icon: HugeIcons.strokeRoundedDelete02,
                    label: "Supprimer",
                    onTap: onRemovePressed!,
                    color: color,
                    isDestructive: true,
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required List<List<dynamic>> icon,
    required String label,
    required VoidCallback onTap,
    required ConstColors color,
    bool isDestructive = false,
  }) {
    final buttonColor = isDestructive ? Colors.red : color.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: buttonColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: buttonColor, size: 28),
            const SizedBox(height: 8),
            SubTitle(
              text: label,
              fontsize: 14,
              color: buttonColor,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
