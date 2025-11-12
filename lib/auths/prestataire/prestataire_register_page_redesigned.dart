import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class PrestataireRegisterPageRedesigned extends StatefulWidget {
  const PrestataireRegisterPageRedesigned({super.key});

  @override
  State<PrestataireRegisterPageRedesigned> createState() =>
      _PrestataireRegisterPageRedesignedState();
}

class _PrestataireRegisterPageRedesignedState
    extends State<PrestataireRegisterPageRedesigned>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _pageAnimationController;
  late AnimationController _stepAnimationController;
  late AnimationController _floatingAnimationController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _domainController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  // State Variables
  int _currentStep = 0;
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Form Focus Nodes
  final _nameFocus = FocusNode();
  final _domainFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _bioFocus = FocusNode();

  // Color Scheme
  static const Color _primaryColor = Color(0xFF0C315A);
  static const Color _secondaryColor = Color(0xFF2E3641);
  static const Color _accentColor = Color(0xFF4CAF50);
  static const Color _errorColor = Color(0xFFEB3223);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _cardColor = Colors.white;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Photo de Profil',
      'description': 'Ajoutez votre photo professionnelle',
      'icon': Icons.person_add,
    },
    {
      'title': 'Informations Personnelles',
      'description': 'Vos informations de base',
      'icon': Icons.info,
    },
    {
      'title': 'Détails Professionnels',
      'description': 'Votre domaine d\'expertise',
      'icon': Icons.work,
    },
    {
      'title': 'Confirmation',
      'description': 'Vérifiez vos informations',
      'icon': Icons.check_circle,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageAnimationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _stepAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _floatingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _stepAnimationController.dispose();
    _floatingAnimationController.dispose();
    _nameController.dispose();
    _domainController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _nameFocus.dispose();
    _domainFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _locationFocus.dispose();
    _bioFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        HapticFeedback.lightImpact();
        _showSnackBar('Photo ajoutée avec succès!', _accentColor);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection de l\'image', _errorColor);
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImagePickerBottomSheet(),
    );
  }

  Widget _buildImagePickerBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
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
              const Text(
                'Sélectionner une photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _secondaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Caméra',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galerie',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primaryColor.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == _accentColor ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
        });
        _stepAnimationController.reset();
        _stepAnimationController.forward();
        HapticFeedback.lightImpact();
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _stepAnimationController.reset();
      _stepAnimationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedImage == null) {
          _showSnackBar('Veuillez ajouter une photo de profil', _errorColor);
          return false;
        }
        return true;
      case 1:
        if (_nameController.text.trim().isEmpty ||
            _emailController.text.trim().isEmpty) {
          _showSnackBar(
            'Veuillez remplir tous les champs obligatoires',
            _errorColor,
          );
          return false;
        }
        if (!_isValidEmail(_emailController.text.trim())) {
          _showSnackBar('Veuillez entrer un email valide', _errorColor);
          return false;
        }
        return true;
      case 2:
        if (_domainController.text.trim().isEmpty ||
            _phoneController.text.trim().isEmpty ||
            _locationController.text.trim().isEmpty) {
          _showSnackBar(
            'Veuillez remplir tous les champs obligatoires',
            _errorColor,
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    _showSnackBar('Inscription réussie!', _accentColor);

    // Navigate to next screen
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/prestataire');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: AnimatedBuilder(
        animation: _pageAnimationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProgressIndicator(),
                    Expanded(child: _buildStepContent()),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _floatingAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatingAnimation.value * 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Étape ${_currentStep + 1}/${_steps.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _steps[_currentStep]['title'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _steps[_currentStep]['description'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? _accentColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedScale(
                    scale: isCurrent ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isActive ? _accentColor : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _steps[index]['icon'],
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    return AnimatedBuilder(
      animation: _stepAnimationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _getCurrentStepWidget(),
          ),
        );
      },
    );
  }

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return _buildPhotoStep();
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildProfessionalInfoStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return Container();
    }
  }

  Widget _buildPhotoStep() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showImagePickerBottomSheet,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: _primaryColor.withOpacity(0.6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: TextStyle(
                                color: _primaryColor.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    _selectedImage == null ? Icons.add : Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Votre photo de profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez une photo professionnelle pour que les clients puissent vous reconnaître facilement.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildModernTextField(
            controller: _nameController,
            focusNode: _nameFocus,
            label: 'Nom complet',
            hint: 'Entrez votre nom complet',
            icon: Icons.person_outline,
            keyboardType: TextInputType.text,
            nextFocus: _emailFocus,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom est obligatoire';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            label: 'Adresse email',
            hint: 'votre@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'L\'email est obligatoire';
              }
              if (!_isValidEmail(value.trim())) {
                return 'Email invalide';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoStep() {
    return Column(
      children: [
        _buildModernTextField(
          controller: _domainController,
          focusNode: _domainFocus,
          label: 'Domaine d\'activité',
          hint: 'Ex: Électricien, Plombier, etc.',
          icon: Icons.work_outline,
          keyboardType: TextInputType.text,
          nextFocus: _phoneFocus,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          label: 'Numéro de téléphone',
          hint: '+224 XXX XX XX XX',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          nextFocus: _locationFocus,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _locationController,
          focusNode: _locationFocus,
          label: 'Localisation',
          hint: 'Votre ville ou région',
          icon: Icons.location_on_outlined,
          keyboardType: TextInputType.text,
          nextFocus: _bioFocus,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _bioController,
          focusNode: _bioFocus,
          label: 'Description (optionnel)',
          hint: 'Décrivez brièvement votre expérience...',
          icon: Icons.description_outlined,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Vérifiez vos informations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedImage != null) ...[
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildInfoRow('Nom', _nameController.text),
          _buildInfoRow('Email', _emailController.text),
          _buildInfoRow('Domaine', _domainController.text),
          _buildInfoRow('Téléphone', _phoneController.text),
          _buildInfoRow('Localisation', _locationController.text),
          if (_bioController.text.isNotEmpty)
            _buildInfoRow('Description', _bioController.text),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? nextFocus,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textInputAction: nextFocus != null
            ? TextInputAction.next
            : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: _cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: _secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Précédent',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _currentStep < _steps.length - 1
                          ? 'Suivant'
                          : 'Confirmer',
                      style: const TextStyle(
                        fontSize: 16,
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
