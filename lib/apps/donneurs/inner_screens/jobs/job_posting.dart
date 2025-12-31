import 'dart:io';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/immo_header.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class JobPosting extends StatefulWidget {
  const JobPosting({super.key});

  @override
  State<JobPosting> createState() => _JobPostingState();
}

class _JobPostingState extends State<JobPosting>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorController = TextEditingController();
  final _yearBuiltController = TextEditingController();

  // Form State
  String? selectedPropertyType;
  String? selectedTransactionType;
  String? selectedCondition;
  String? selectedFurnishing;
  String? selectedEnergyRating;
  List<File> selectedImages = [];
  List<String> selectedFeatures = [];
  int currentPage = 0;
  bool isSubmitting = false;

  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Property Types
  final List<String> propertyTypes = [
    'Appartement',
    'Maison',
    'Villa',
    'Studio',
    'Duplex',
    'Penthouse',
    'Loft',
    'Terrain',
    'Local commercial',
    'Bureau',
  ];

  // Transaction Types
  final List<String> transactionTypes = [
    'Vente',
    'Location',
    'Location saisonnière',
  ];

  // Property Conditions
  final List<String> conditions = [
    'Neuf',
    'Excellent état',
    'Bon état',
    'À rénover',
    'À restaurer',
  ];

  // Furnishing Options
  final List<String> furnishingOptions = [
    'Meublé',
    'Semi-meublé',
    'Non meublé',
  ];

  // Energy Ratings
  final List<String> energyRatings = ['A+', 'A', 'B', 'C', 'D', 'E', 'F', 'G'];

  // Available Features
  final List<String> availableFeatures = [
    'Balcon',
    'Terrasse',
    'Jardin',
    'Piscine',
    'Garage',
    'Parking',
    'Cave',
    'Grenier',
    'Cheminée',
    'Climatisation',
    'Chauffage central',
    'Ascenseur',
    'Gardien',
    'Sécurité',
    'Vue mer',
    'Vue montagne',
    'Proche transport',
    'Proche école',
    'Proche commerces',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _floorController.dispose();
    _yearBuiltController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1080,
        imageQuality: 80,
      );

      if (images.isNotEmpty && selectedImages.length + images.length <= 10) {
        setState(() {
          selectedImages.addAll(images.map((image) => File(image.path)));
        });
      } else if (selectedImages.length + images.length > 10) {
        _showSnackBar('Maximum 10 images autorisées', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection des images', isError: true);
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        imageQuality: 80,
      );

      if (image != null && selectedImages.length < 10) {
        setState(() {
          selectedImages.add(File(image.path));
        });
      } else if (selectedImages.length >= 10) {
        _showSnackBar('Maximum 10 images autorisées', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la prise de photo', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : ConstColors().primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _nextPage() {
    if (currentPage < 2) {
      setState(() {
        currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (currentPage) {
      case 0:
        return _titleController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            selectedPropertyType != null &&
            selectedTransactionType != null;
      case 1:
        return _priceController.text.isNotEmpty &&
            _areaController.text.isNotEmpty &&
            _addressController.text.isNotEmpty;
      case 2:
        return selectedImages.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || !_validateCurrentPage()) {
      _showSnackBar('Veuillez remplir tous les champs requis', isError: true);
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

      _showSnackBar('Annonce publiée avec succès!');

      // Navigate back or to success page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ConstColors();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              const ImmoHeader(auto: true),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: FadeTransition(
                    opacity: _slideAnimation,
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildProgressIndicator(),
                        _buildPageView(),
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            text: "Publier une annonce",
            fontSize: 28,
            color: ConstColors().secondary,
          ),
          const SizedBox(height: 8),
          SubTitle(
            text: "Partagez votre bien immobilier avec notre communauté",
            fontsize: 16,
            color: ConstColors().primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final colors = ConstColors();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= currentPage;
          // final isCompleted = index < currentPage;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? colors.primary
                    : colors.tertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPageView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            currentPage = page;
          });
        },
        children: [
          _buildBasicInfoPage(),
          _buildDetailsPage(),
          _buildImagesAndFeaturesPage(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SubTitle(
              text: "Informations de base",
              fontsize: 20,
              fontWeight: FontWeight.w600,
              color: ConstColors().secondary,
            ),
            const SizedBox(height: 24),
            _CustomTextField(
              controller: _titleController,
              label: "Titre de l'annonce *",
              icon: HugeIcons.strokeRoundedHome01,
              validator: (value) =>
                  value?.isEmpty == true ? 'Titre requis' : null,
            ),
            const SizedBox(height: 16),
            _CustomTextField(
              controller: _descriptionController,
              label: "Description *",
              icon: HugeIcons.strokeRoundedFileEdit,
              maxLines: 4,
              validator: (value) =>
                  value?.isEmpty == true ? 'Description requise' : null,
            ),
            const SizedBox(height: 16),
            _CustomDropdown(
              value: selectedPropertyType,
              label: "Type de bien *",
              icon: HugeIcons.strokeRoundedBuilding01,
              items: propertyTypes,
              onChanged: (value) =>
                  setState(() => selectedPropertyType = value),
            ),
            const SizedBox(height: 16),
            _CustomDropdown(
              value: selectedTransactionType,
              label: "Type de transaction *",
              icon: HugeIcons.strokeRoundedExchange01,
              items: transactionTypes,
              onChanged: (value) =>
                  setState(() => selectedTransactionType = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SubTitle(
              text: "Détails du bien",
              fontsize: 20,
              fontWeight: FontWeight.w600,
              color: ConstColors().secondary,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _CustomTextField(
                    controller: _priceController,
                    label: "Prix *",
                    icon: HugeIcons.strokeRoundedMoney03,
                    keyboardType: TextInputType.number,
                    suffix: selectedTransactionType == 'Location'
                        ? '/mois'
                        : null,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Prix requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CustomTextField(
                    controller: _areaController,
                    label: "Surface (m²) *",
                    icon: HugeIcons.strokeRoundedSquare,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Surface requise' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CustomTextField(
              controller: _addressController,
              label: "Adresse *",
              icon: HugeIcons.strokeRoundedLocation01,
              validator: (value) =>
                  value?.isEmpty == true ? 'Adresse requise' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CustomTextField(
                    controller: _bedroomsController,
                    label: "Chambres",
                    icon: HugeIcons.strokeRoundedBed,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CustomTextField(
                    controller: _bathroomsController,
                    label: "Salles de bain",
                    icon: HugeIcons.strokeRoundedBathtub01,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CustomTextField(
                    controller: _floorController,
                    label: "Étage",
                    icon: HugeIcons.strokeRoundedBuilding02,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CustomTextField(
                    controller: _yearBuiltController,
                    label: "Année de construction",
                    icon: HugeIcons.strokeRoundedCalendar03,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CustomDropdown(
              value: selectedCondition,
              label: "État du bien",
              icon: HugeIcons.strokeRoundedCheckmarkSquare02,
              items: conditions,
              onChanged: (value) => setState(() => selectedCondition = value),
            ),
            const SizedBox(height: 16),
            if (selectedTransactionType == 'Location')
              _CustomDropdown(
                value: selectedFurnishing,
                label: "Ameublement",
                icon: HugeIcons.strokeRoundedChair01,
                items: furnishingOptions,
                onChanged: (value) =>
                    setState(() => selectedFurnishing = value),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesAndFeaturesPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SubTitle(
              text: "Photos et caractéristiques",
              fontsize: 20,
              fontWeight: FontWeight.w600,
              color: ConstColors().secondary,
            ),
            const SizedBox(height: 24),
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildFeaturesSection(),
            const SizedBox(height: 16),
            _CustomDropdown(
              value: selectedEnergyRating,
              label: "Classe énergétique",
              icon: HugeIcons.strokeRoundedLeaf01,
              items: energyRatings,
              onChanged: (value) =>
                  setState(() => selectedEnergyRating = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final colors = ConstColors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SubTitle(
              text: "Photos (${selectedImages.length}/10) *",
              fontsize: 18,
              fontWeight: FontWeight.w600,
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _pickImages,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedImage02,
                    color: colors.primary,
                  ),
                ),
                IconButton(
                  onPressed: _pickImageFromCamera,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCamera01,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (selectedImages.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: colors.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedImageAdd01,
                      color: colors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    SubTitle(text: "Ajouter des photos", color: colors.primary),
                  ],
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      selectedImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(
          text: "Caractéristiques",
          fontsize: 18,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableFeatures.map((feature) {
            final isSelected = selectedFeatures.contains(feature);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedFeatures.remove(feature);
                  } else {
                    selectedFeatures.add(feature);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ConstColors().primary
                      : ConstColors().tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? ConstColors().primary
                        : ConstColors().tertiary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  feature,
                  style: TextStyle(
                    color: isSelected ? Colors.white : ConstColors().secondary,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ConstColors().primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Précédent",
                  style: TextStyle(
                    color: ConstColors().primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (currentPage > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (currentPage < 2) {
                  if (_validateCurrentPage()) {
                    _nextPage();
                  } else {
                    _showSnackBar(
                      'Veuillez remplir tous les champs requis',
                      isError: true,
                    );
                  }
                } else {
                  _submitForm();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstColors().primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isSubmitting && currentPage == 2
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      currentPage < 2 ? "Suivant" : "Publier",
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

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final dynamic icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final String? suffix;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ConstColors();

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(fontSize: 16, color: colors.secondary),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        labelStyle: TextStyle(color: colors.primary, fontSize: 16),
        suffixStyle: TextStyle(color: colors.primary, fontSize: 14),
        // prefixIcon: HugeIcon(icon: icon, color: colors.primary, size: 20),
        filled: true,
        fillColor: colors.bgSubmit,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String? value;
  final String label;
  final dynamic icon;
  final List<String> items;
  final void Function(String?) onChanged;

  const _CustomDropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ConstColors();

    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: TextStyle(fontSize: 16, color: colors.secondary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.primary, fontSize: 16),
        //prefixIcon: HugeIcon(icon: icon, color: colors.primary, size: 20),
        filled: true,
        fillColor: colors.bgSubmit,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
    );
  }
}
