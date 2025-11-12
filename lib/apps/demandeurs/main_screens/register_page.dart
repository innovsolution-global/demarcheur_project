import 'dart:io';
import 'package:demarcheur_app/auths/donneurs/login_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/methods/my_methodes.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final MyMethodes methodes = MyMethodes();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Form state
  File? selectedImage;
  String? selectedCompanySize;
  String? selectedIndustry;
  bool isLoading = false;
  bool _acceptTerms = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final List<String> companySizes = [
    '1-10 employés',
    '11-50 employés',
    '51-200 employés',
    '201-500 employés',
    '500+ employés',
  ];

  final List<String> industries = [
    'Technologie',
    'Finance',
    'Santé',
    'Éducation',
    'Commerce de détail',
    'Manufacturing',
    'Services',
    'Immobilier',
    'Transport',
    'Agriculture',
    'Autre',
  ];

  ConstColors colors = ConstColors();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _domainController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showMessage('Erreur lors de la sélection de l\'image', isError: true);
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              TitleWidget(
                text: 'Ajouter le logo de l\'entreprise',
                fontSize: 18,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: HugeIcons.strokeRoundedImage02,
                    label: 'Galerie',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: HugeIcons.strokeRoundedCamera01,
                    label: 'Caméra',
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
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required List<List<dynamic>> icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.tertiary),
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: colors.primary, size: 32),
            const SizedBox(height: 8),
            SubTitle(text: label, fontWeight: FontWeight.w500, fontsize: 14),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: colors.bg,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.bg,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? colors.error : colors.accepted,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  bool _validateForm() {
    if (selectedImage == null) {
      _showMessage(
        'Veuillez ajouter le logo de votre entreprise',
        isError: true,
      );
      return false;
    }

    if (_companyNameController.text.trim().isEmpty) {
      _showMessage('Le nom de l\'entreprise est obligatoire', isError: true);
      return false;
    }

    if (_companyNameController.text.trim().length < 2) {
      _showMessage(
        'Le nom de l\'entreprise doit contenir au moins 2 caractères',
        isError: true,
      );
      return false;
    }

    if (selectedIndustry == null) {
      _showMessage(
        'Veuillez sélectionner un secteur d\'activité',
        isError: true,
      );
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _showMessage('L\'adresse e-mail est obligatoire', isError: true);
      return false;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text.trim())) {
      _showMessage('Veuillez saisir une adresse e-mail valide', isError: true);
      return false;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showMessage('Le numéro de téléphone est obligatoire', isError: true);
      return false;
    }

    if (_phoneController.text.trim().length < 8) {
      _showMessage(
        'Veuillez saisir un numéro de téléphone valide',
        isError: true,
      );
      return false;
    }

    if (_locationController.text.trim().isEmpty) {
      _showMessage('La localisation est obligatoire', isError: true);
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showMessage(
        'La description de l\'entreprise est obligatoire',
        isError: true,
      );
      return false;
    }

    if (_descriptionController.text.trim().length < 20) {
      _showMessage(
        'La description doit contenir au moins 20 caractères',
        isError: true,
      );
      return false;
    }

    if (!_acceptTerms) {
      _showMessage(
        'Veuillez accepter les conditions d\'utilisation',
        isError: true,
      );
      return false;
    }

    return true;
  }

  Future<void> _registerCompany() async {
    if (!_validateForm()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Create company registration data
      final registrationData = {
        'companyName': _companyNameController.text.trim(),
        'industry': selectedIndustry,
        'domain': _domainController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'website': _websiteController.text.trim(),
        'companySize': selectedCompanySize,
        'logo': selectedImage?.path,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // TODO: Implement actual registration API call
      print('Registration data: $registrationData');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      _showMessage('Compte créé avec succès!');

      // Navigate to next screen
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, "/demonboarding");
    } catch (e) {
      _showMessage(
        'Erreur lors de l\'inscription. Veuillez réessayer.',
        isError: true,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextCapitalization? textCapitalization,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SubTitle(
                text: label,
                fontWeight: FontWeight.w600,
                fontsize: 16,
                color: colors.secondary,
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: colors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: colors.secondary.withOpacity(0.6),
                fontSize: 16,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              fillColor: colors.bgSubmit,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.tertiary),
              ),
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SubTitle(
                text: label,
                fontWeight: FontWeight.w600,
                fontsize: 16,
                color: colors.secondary,
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: colors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: colors.secondary.withOpacity(0.6),
                fontSize: 16,
              ),
              fillColor: colors.bgSubmit,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.tertiary),
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(fontSize: 16, color: colors.primary),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerDialog,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: selectedImage != null
                    ? Colors.transparent
                    : colors.tertiary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedImage != null
                      ? colors.primary
                      : colors.tertiary,
                  width: selectedImage != null ? 2 : 1,
                ),
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
                          color: colors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        SubTitle(
                          text: 'Ajouter logo',
                          fontWeight: FontWeight.w500,
                          fontsize: 12,
                          color: colors.primary,
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCameraAdd02,
                          color: colors.bg,
                          size: 24,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SubTitle(
                text: 'Logo de l\'entreprise',
                fontWeight: FontWeight.w600,
                fontsize: 16,
                color: colors.secondary,
              ),
              Text(
                ' *',
                style: TextStyle(
                  color: colors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SubTitle(
            text: 'Format recommandé: JPG, PNG (max 2MB)',
            fontsize: 12,
            color: colors.secondary.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.secondary,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'J\'accepte les '),
                      TextSpan(
                        text: 'conditions d\'utilisation',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' et la '),
                      TextSpan(
                        text: 'politique de confidentialité',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: CustomScrollView(
          slivers: [
            const Header(auto: true),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Center(
                        child: Column(
                          children: [
                            TitleWidget(
                              text: 'Créer un compte entreprise',
                              fontSize: 20,
                              color: colors.secondary,
                            ),
                            const SizedBox(height: 8),
                            SubTitle(
                              text:
                                  'Rejoignez notre plateforme et trouvez les meilleurs talents',
                              fontsize: 16,
                              color: colors.secondary.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Logo Selector
                      _buildLogoSelector(),

                      // Company Information
                      _buildFormField(
                        label: 'Nom de l\'entreprise',
                        controller: _companyNameController,
                        hint: 'Ex: TechCorp Solutions',
                        textCapitalization: TextCapitalization.words,
                        prefixIcon: Icon(Icons.business, color: colors.primary),
                      ),

                      _buildDropdownField(
                        label: 'Secteur d\'activité',
                        hint: 'Sélectionnez votre secteur',
                        items: industries,
                        value: selectedIndustry,
                        onChanged: (value) {
                          setState(() {
                            selectedIndustry = value;
                          });
                        },
                      ),

                      _buildFormField(
                        label: 'Domaine d\'expertise',
                        controller: _domainController,
                        textCapitalization: TextCapitalization.words,
                        hint: 'Ex: Développement web, Marketing digital...',
                        isRequired: false,
                        prefixIcon: Icon(
                          Icons.work_outline,
                          color: colors.primary,
                        ),
                      ),

                      // Contact Information
                      _buildFormField(
                        label: 'Adresse e-mail',
                        controller: _emailController,
                        hint: 'contact@votre-entreprise.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: colors.primary,
                        ),
                      ),

                      _buildFormField(
                        label: 'Numéro de téléphone',
                        controller: _phoneController,
                        hint: '+224 xxx xxx xxx',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: colors.primary,
                        ),
                      ),

                      _buildFormField(
                        label: 'Localisation',
                        controller: _locationController,
                        textCapitalization: TextCapitalization.words,

                        hint: 'Ex: Conakry, Guinée',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: colors.primary,
                        ),
                      ),

                      _buildFormField(
                        label: 'Site web',
                        controller: _websiteController,
                        hint: 'https://votre-site.com',
                        isRequired: false,
                        keyboardType: TextInputType.url,
                        prefixIcon: Icon(Icons.language, color: colors.primary),
                      ),

                      _buildDropdownField(
                        label: 'Taille de l\'entreprise',
                        hint: 'Nombre d\'employés',
                        items: companySizes,
                        value: selectedCompanySize,
                        isRequired: false,
                        onChanged: (value) {
                          setState(() {
                            selectedCompanySize = value;
                          });
                        },
                      ),

                      _buildFormField(
                        label: 'Description de l\'entreprise',
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.words,
                        hint:
                            'Décrivez votre entreprise, ses activités et sa mission...',
                        maxLines: 4,
                      ),

                      // Terms and Conditions
                      _buildTermsCheckbox(),

                      const SizedBox(height: 24),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _registerCompany,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.bg,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: colors.primary.withOpacity(
                              0.6,
                            ),
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              colors.bg,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Création en cours...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: colors.bg,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons
                                          .strokeRoundedCheckmarkCircle01,
                                      color: colors.bg,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Créer le compte',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: colors.bg,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.secondary,
                              ),
                              children: [
                                const TextSpan(text: 'Déjà un compte ? '),
                                TextSpan(
                                  text: 'Se connecter',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
