import 'dart:io';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/immo_header.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demarcheur_app/models/house_model.dart';
import 'package:demarcheur_app/models/type_properties.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:provider/provider.dart';

class ImmoPostPage extends StatefulWidget {
  final HouseModel? propertyToEdit;
  const ImmoPostPage({super.key, this.propertyToEdit});

  @override
  State<ImmoPostPage> createState() => _ImmoPostPageState();
}

class _ImmoPostPageState extends State<ImmoPostPage>
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
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _livingRoomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorController = TextEditingController();
  final _yearBuiltController = TextEditingController();
  final _garageController = TextEditingController();
  final _kitchenController = TextEditingController();
  final _storeController = TextEditingController();
  final _otherDescriptionController = TextEditingController();
  final _advantageController = TextEditingController();

  // Form State
  String? selectedPropertyType;
  String? selectedTransactionType;
  String? selectedCondition;
  String? selectedFurnishing;
  String? selectedEnergyRating;
  List<File> selectedImages = [];
  List<String> existingImageUrls = [];
  List<String> selectedFeatures = [];
  bool hasGarden = false;
  int currentPage = 0;
  bool isSubmitting = false;

  // Animation Controller
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

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
    debugPrint("DEBUG: ImmoPostPage.initState - calling loadPropertyTypes");
    if (widget.propertyToEdit != null) {
      _initializeEditMode();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadPropertyTypes();
    });
  }

  void _initializeEditMode() {
    final p = widget.propertyToEdit!;
    _titleController.text = p.title ?? '';
    _descriptionController.text = p.description ?? '';
    _priceController.text = (p.price ?? p.rent ?? 0).toString();
    _areaController.text = p.area ?? '';
    _addressController.text = p.location ?? '';
    _districtController.text = p.district ?? '';
    _cityController.text = p.city ?? '';
    _bedroomsController.text = (p.rooms ?? 0).toString();
    _livingRoomsController.text = (p.livingRooms ?? 0).toString();
    _bathroomsController.text = (p.kitchen ?? 0).toString();
    _garageController.text = (p.garage ?? 0).toString();
    _kitchenController.text = (p.kitchen ?? 0).toString();
    _storeController.text = (p.store ?? 0).toString();
    _otherDescriptionController.text = p.otherDescription ?? '';
    _advantageController.text = p.advantage ?? '';

    // Safety check for dropdown values
    selectedPropertyType = (p.countType != null && p.countType!.isNotEmpty)
        ? p.countType
        : null;
    selectedTransactionType = (p.category != null && p.category!.isNotEmpty)
        ? p.category
        : null;
    selectedCondition = (p.condition != null && p.condition!.isNotEmpty)
        ? p.condition
        : null;
    hasGarden = p.garden ?? false;

    // Load existing images
    if (p.imageUrl.isNotEmpty) {
      existingImageUrls = List.from(p.imageUrl);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _bedroomsController.dispose();
    _livingRoomsController.dispose();
    _bathroomsController.dispose();
    _floorController.dispose();
    _yearBuiltController.dispose();
    _garageController.dispose();
    _kitchenController.dispose();
    _storeController.dispose();
    _otherDescriptionController.dispose();
    _advantageController.dispose();
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

      if (images.isNotEmpty && selectedImages.length + images.length <= 15) {
        setState(() {
          selectedImages.addAll(images.map((image) => File(image.path)));
        });
      } else if (selectedImages.length + images.length > 15) {
        _showSnackBar('Maximum 15 images autorisées', isError: true);
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

      if (image != null && selectedImages.length < 15) {
        setState(() {
          selectedImages.add(File(image.path));
        });
      } else if (selectedImages.length >= 15) {
        _showSnackBar('Maximum 15 images autorisées', isError: true);
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

  void _removeExistingImage(int index) {
    setState(() {
      existingImageUrls.removeAt(index);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
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
            _areaController.text.isNotEmpty;
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

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.propertyTypes.isEmpty) {
        await authProvider.loadPropertyTypes();
      }

      final matchedType = authProvider.propertyTypes.firstWhere(
        (t) =>
            t.tyPePropertyName.trim().toLowerCase() ==
            selectedPropertyType?.trim().toLowerCase(),
        orElse: () => TypeProperties(tyPePropertyName: '', typeEnum: ''),
      );

      if (matchedType.id == null) {
        _showSnackBar('Type de propriété invalide', isError: true);
        setState(() => isSubmitting = false);
        return;
      }

      final house = HouseModel(
        id: widget.propertyToEdit?.id,
        ownerId: authProvider.userId,
        companyId: authProvider.userId,
        companyName: _titleController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text),
        rent: double.tryParse(_priceController.text),
        district: _districtController.text.isNotEmpty
            ? _districtController.text
            : _addressController.text,
        city: _cityController.text.isNotEmpty
            ? _cityController.text
            : _addressController.text,
        location: _cityController.text,
        type: matchedType.id,
        typePropertId: matchedType.id,
        statusProperty: 'Disponible',
        status: 'Disponible',
        rooms: int.tryParse(_bedroomsController.text),
        livingRooms: int.tryParse(_livingRoomsController.text),
        area: _areaController.text,
        garage: int.tryParse(_garageController.text),
        kitchen: int.tryParse(_kitchenController.text),
        store: int.tryParse(_storeController.text),
        garden: hasGarden,
        otherDescription: _otherDescriptionController.text,
        advantage: _advantageController.text,
        condition: selectedCondition ?? 'Bon état',
        category: selectedTransactionType,
        piscine: selectedFeatures.contains('Piscine') ? 1 : 0,
      );

      bool result;
      if (widget.propertyToEdit != null) {
        result = await authProvider.updateProperty(
          widget.propertyToEdit!.id!,
          house,
          newImages: selectedImages,
        );
      } else {
        result = await authProvider.addPropertiesForCompany(
          house,
          selectedImages,
        );
      }

      if (mounted) {
        setState(() {
          isSubmitting = false;
        });

        if (result) {
          _showSnackBar(
            widget.propertyToEdit != null
                ? 'Annonce mise à jour avec succès!'
                : 'Annonce publiée avec succès!',
          );
          Navigator.pop(context);
        } else {
          _showSnackBar(
            widget.propertyToEdit != null
                ? 'Erreur lors de la mise à jour'
                : 'Erreur lors de la publication',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
        _showSnackBar('Erreur: $e', isError: true);
      }
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
            text: widget.propertyToEdit != null
                ? "Modifier l'annonce"
                : "Publier une annonce",
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
              validator: (value) =>
                  value?.isEmpty == true ? 'Titre requis' : null,
            ),
            const SizedBox(height: 16),
            _CustomTextField(
              controller: _descriptionController,
              label: "Description *",
              maxLines: 4,
              validator: (value) =>
                  value?.isEmpty == true ? 'Description requise' : null,
            ),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return _CustomDropdown(
                  value: selectedPropertyType,
                  label: "Type de bien *",
                  items: authProvider.propertyTypes
                      .map((e) => e.tyPePropertyName)
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedPropertyType = value),
                );
              },
            ),
            const SizedBox(height: 16),
            _CustomDropdown(
              value: selectedTransactionType,
              label: "Type de transaction *",
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
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Surface requise' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CustomTextField(
                    controller: _bedroomsController,
                    label: "Chambres",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CustomTextField(
                    controller: _livingRoomsController,
                    label: "Salons",
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
                    controller: _kitchenController,
                    label: "Cuisines",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CustomTextField(
                    controller: _bathroomsController,
                    label: "Douches",
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
                    controller: _garageController,
                    label: "Garages",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CustomTextField(
                    controller: _storeController,
                    label: "Magasins",
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
                    controller: _districtController,
                    label: "Quartier *",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CustomTextField(
                    controller: _cityController,
                    label: "Ville *",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CustomTextField(
              controller: _advantageController,
              label: "Conditions",
            ),
            const SizedBox(height: 16),
            _CustomTextField(
              controller: _otherDescriptionController,
              label: "Autres descriptions",
              maxLines: 2,
            ),

            const SizedBox(height: 16),
            _CustomDropdown(
              value: selectedCondition,
              label: "État du bien",
              items: conditions,
              onChanged: (value) => setState(() => selectedCondition = value),
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
              text: "Photos (${selectedImages.length}/15) *",
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
        if (selectedImages.isEmpty && existingImageUrls.isEmpty)
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.bgSubmit,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: colors.tertiary.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedImage02,
                  color: colors.tertiary,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  "Aucune photo sélectionnée",
                  style: TextStyle(color: colors.tertiary),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing Images
                ...List.generate(existingImageUrls.length, (index) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(existingImageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => _removeExistingImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors
                                    .orange, // Different color for distinction
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
                    ),
                  );
                }),

                // New Selected Images
                ...List.generate(selectedImages.length, (index) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: FileImage(selectedImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 4,
                          top: 4,
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
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle(
          text: "Équipements et services",
          fontsize: 18,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableFeatures.map((feature) {
            final isSelected = selectedFeatures.contains(feature);
            return FilterChip(
              label: Text(feature),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedFeatures.add(feature);
                  } else {
                    selectedFeatures.remove(feature);
                  }
                });
              },
              selectedColor: ConstColors().primary.withOpacity(0.2),
              checkmarkColor: ConstColors().primary,
              labelStyle: TextStyle(
                color: isSelected ? ConstColors().primary : Colors.grey[700],
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final colors = ConstColors();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          if (currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Précédent",
                  style: TextStyle(color: colors.primary),
                ),
              ),
            ),
          if (currentPage > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: currentPage < 2 ? _nextPage : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      currentPage < 2 ? "Suivant" : "Publier",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
  final int maxLines;
  final TextInputType keyboardType;
  final String? suffix;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ConstColors();

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 16, color: colors.secondary),
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.primary, fontSize: 16),
        suffixText: suffix,
        filled: true,
        fillColor: colors.bgSubmit,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
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
  final List<String> items;
  final void Function(String?) onChanged;

  const _CustomDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ConstColors();

    // Safety check to avoid DropdownButton assertion errors
    final safeValue = (value != null && items.contains(value)) ? value : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      dropdownColor: colors.bg,
      onChanged: onChanged,
      style: TextStyle(fontSize: 16, color: colors.secondary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.primary, fontSize: 16),
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
