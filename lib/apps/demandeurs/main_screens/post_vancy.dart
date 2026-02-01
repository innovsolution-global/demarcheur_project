import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/application_provider.dart';
import 'package:demarcheur_app/widgets/btn.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class PostVancy extends StatefulWidget {
  const PostVancy({super.key});

  @override
  State<PostVancy> createState() => _PostVancyState();
}

class _PostVancyState extends State<PostVancy> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Form Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();

  // Form Values
  String? selectedJobType;
  String? selectedExperienceLevel;
  String? selectedCategory;
  String? selectedSalaryType;
  List<String> selectedSkills = [];
  bool isRemoteAvailable = false;
  bool isUrgent = false;

  int currentStep = 0;
  final int totalSteps = 4;

  final List<String> jobTypes = [
    'Temps-plein',
    'Temps-partiel',
    'Contrat',
    'Stage',
    'Freelance',
  ];

  final List<String> experienceLevels = [
    'Débutant (0-1 ans)',
    'Junior (1-3 ans)',
    'Intermédiaire (3-5 ans)',
    'Senior (5+ ans)',
    'Expert (8+ ans)',
  ];

  final List<String> categories = [
    'Développement',
    'Design',
    'Marketing',
    'Vente',
    'Finance',
    'RH',
    'Support Client',
    'Operations',
    'Autre',
  ];

  final List<String> salaryTypes = [
    'Par mois',
    'Par année',
    'Par heure',
    'À négocier',
  ];

  final List<String> availableSkills = [
    'Flutter',
    'React',
    'Node.js',
    'Python',
    'Java',
    'UI/UX Design',
    'Photoshop',
    'Figma',
    'Marketing Digital',
    'SEO',
    'Google Analytics',
    'Excel',
    'PowerPoint',
    'Communication',
    'Gestion de projet',
    'Leadership',
  ];

  ConstColors colors = ConstColors();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<ApplicationProvider>(
      //   context,
      //   listen: false,
      // ).loadApplication();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _benefitsController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (currentStep < totalSteps - 1) {
        setState(() {
          currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitJobPosting();
      }
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    String? errorMessage;

    switch (currentStep) {
      case 0:
        if (_titleController.text.trim().isEmpty) {
          errorMessage = 'Le titre du poste est obligatoire';
        } else if (_titleController.text.trim().length < 3) {
          errorMessage =
              'Le titre du poste doit contenir au moins 3 caractères';
        } else if (selectedJobType == null) {
          errorMessage = 'Veuillez sélectionner un type de contrat';
        } else if (selectedCategory == null) {
          errorMessage = 'Veuillez sélectionner une catégorie';
        }
        break;
      case 1:
        if (_locationController.text.trim().isEmpty) {
          errorMessage = 'La localisation est obligatoire';
        } else if (_locationController.text.trim().length < 2) {
          errorMessage = 'Veuillez saisir une localisation valide';
        } else if (selectedExperienceLevel == null) {
          errorMessage = 'Veuillez sélectionner un niveau d\'expérience requis';
        }
        break;
      case 2:
        if (_salaryController.text.trim().isEmpty) {
          errorMessage = 'Le salaire est obligatoire';
        } else if (int.tryParse(_salaryController.text.trim()) == null ||
            int.parse(_salaryController.text.trim()) <= 0) {
          errorMessage = 'Veuillez saisir un salaire valide (nombre positif)';
        } else if (selectedSalaryType == null) {
          errorMessage = 'Veuillez sélectionner un type de salaire';
        }
        break;
      case 3:
        if (_descriptionController.text.trim().isEmpty) {
          errorMessage = 'La description du poste est obligatoire';
        } else if (_descriptionController.text.trim().length < 20) {
          errorMessage = 'La description doit contenir au moins 20 caractères';
        } else if (_requirementsController.text.trim().isEmpty) {
          errorMessage = 'Les exigences sont obligatoires';
        } else if (_requirementsController.text.trim().length < 10) {
          errorMessage =
              'Les exigences doivent contenir au moins 10 caractères';
        } else if (selectedSkills.isEmpty) {
          errorMessage =
              'Veuillez sélectionner au moins une compétence requise';
        }
        break;
      default:
        return true;
    }

    if (errorMessage != null) {
      _showValidationError(errorMessage);
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: colors.bg, size: 20),
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
        backgroundColor: colors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: colors.bg, size: 20),
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
        backgroundColor: colors.accepted,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _submitJobPosting() {
    // Final validation before submission
    if (_validateCurrentStep()) {
      // Create job posting data
      final jobData = {
        'title': _titleController.text.trim(),
        'jobType': selectedJobType,
        'category': selectedCategory,
        'location': _locationController.text.trim(),
        'experienceLevel': selectedExperienceLevel,
        'education': _educationController.text.trim(),
        'salary': _salaryController.text.trim(),
        'salaryType': selectedSalaryType,
        'benefits': _benefitsController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text.trim(),
        'skills': selectedSkills,
        'isRemoteAvailable': isRemoteAvailable,
        'isUrgent': isUrgent,
        'companyId': context
            .read<ApplicationProvider>()
            .allapplication
            .first
            .id,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // TODO: Implement actual job posting submission to backend
      print('Job posting data: $jobData');

      _showSuccessMessage('Offre d\'emploi publiée avec succès!');
      Navigator.pop(context);
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: index <= currentStep ? colors.primary : colors.tertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleWidget(text: title, fontSize: 24),
          const SizedBox(height: 4),
          SubTitle(text: subtitle, fontsize: 16, color: colors.secondary),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubTitle(text: label, fontWeight: FontWeight.w600, fontsize: 16),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            textCapitalization: maxLines == 1
                ? TextCapitalization.words
                : TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: colors.secondary.withOpacity(0.6),
                fontSize: 16,
              ),
              fillColor: colors.bgSubmit,
              filled: true,
              suffix: suffix,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required List<T> items,
    required T? value,
    required void Function(T?) onChanged,
    String Function(T)? itemLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubTitle(text: label, fontWeight: FontWeight.w600, fontsize: 16),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            initialValue: value,
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
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel != null ? itemLabel(item) : item.toString(),
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

  Widget _buildCheckboxField({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: colors.primary,
          ),
          Expanded(
            child: SubTitle(
              text: label,
              fontsize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubTitle(
            text: 'Compétences requises',
            fontWeight: FontWeight.w600,
            fontsize: 16,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableSkills.map((skill) {
              final isSelected = selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedSkills.add(skill);
                    } else {
                      selectedSkills.remove(skill);
                    }
                  });
                },
                selectedColor: colors.primary.withOpacity(0.2),
                checkmarkColor: colors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? colors.primary : colors.secondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: 'Titre du poste *',
            controller: _titleController,
            hint: 'Ex: Développeur Flutter Senior',
          ),
          _buildDropdownField<String>(
            label: 'Type de contrat *',
            hint: 'Sélectionnez le type de contrat',
            items: jobTypes,
            value: selectedJobType,
            onChanged: (value) {
              setState(() {
                selectedJobType = value;
              });
            },
          ),
          _buildDropdownField<String>(
            label: 'Catégorie *',
            hint: 'Sélectionnez une catégorie',
            items: categories,
            value: selectedCategory,
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
          ),
          _buildCheckboxField(
            label: 'Offre urgente',
            value: isUrgent,
            onChanged: (value) {
              setState(() {
                isUrgent = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: 'Localisation *',
            controller: _locationController,
            hint: 'Ex: Conakry, Guinée',
          ),
          _buildDropdownField<String>(
            label: 'Niveau d\'expérience *',
            hint: 'Sélectionnez le niveau requis',
            items: experienceLevels,
            value: selectedExperienceLevel,
            onChanged: (value) {
              setState(() {
                selectedExperienceLevel = value;
              });
            },
          ),
          _buildFormField(
            label: 'Formation souhaitée',
            controller: _educationController,
            hint: 'Ex: Licence en Informatique',
          ),
          _buildCheckboxField(
            label: 'Travail à distance possible',
            value: isRemoteAvailable,
            onChanged: (value) {
              setState(() {
                isRemoteAvailable = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: 'Salaire *',
            controller: _salaryController,
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            suffix: Text(
              'GNF',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildDropdownField<String>(
            label: 'Type de salaire *',
            hint: 'Sélectionnez la fréquence',
            items: salaryTypes,
            value: selectedSalaryType,
            onChanged: (value) {
              setState(() {
                selectedSalaryType = value;
              });
            },
          ),
          _buildFormField(
            label: 'Avantages',
            controller: _benefitsController,
            hint: 'Ex: Assurance santé, congés payés, formation...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: 'Description du poste *',
            controller: _descriptionController,
            hint: 'Décrivez les responsabilités et missions...',
            maxLines: 4,
          ),
          _buildFormField(
            label: 'Exigences *',
            controller: _requirementsController,
            hint: 'Listez les compétences et qualifications requises...',
            maxLines: 3,
          ),
          _buildSkillsSelector(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compaProvider = context.watch<ApplicationProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: CustomScrollView(
          slivers: [
            const Header(auto: true),
            SliverToBoxAdapter(
              child: compaProvider.isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            SpinKitThreeBounce(
                              color: colors.primary,
                              size: 30.0,
                            ),
                            const SizedBox(height: 20),
                            SubTitle(
                              text: 'Chargement des informations...',
                              fontsize: 16,
                              color: colors.secondary,
                            ),
                          ],
                        ),
                      ),
                    )
                  : compaProvider.allapplication.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.business_center_outlined,
                              size: 60,
                              color: colors.secondary,
                            ),
                            const SizedBox(height: 20),
                            TitleWidget(
                              text: 'Aucune entreprise trouvée',
                              fontSize: 20,
                            ),
                            const SizedBox(height: 10),
                            SubTitle(
                              text:
                                  'Veuillez vous connecter avec un compte entreprise valide.',
                              fontsize: 16,
                              color: colors.secondary,
                            ),
                            const SizedBox(height: 20),
                            Btn(
                              texte: 'Retour',
                              function: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Company Header
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.bgSubmit,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.tertiary),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.tertiary),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      compaProvider.allapplication.first.logo,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TitleWidget(
                                      text: 'Créer une offre d\'emploi',
                                      fontSize: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    SubTitle(
                                      text: compaProvider
                                          .allapplication
                                          .first
                                          .companyName,
                                      fontsize: 16,
                                      color: colors.secondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Progress Indicator
                        _buildProgressIndicator(),

                        // Step Title
                        if (currentStep == 0)
                          _buildStepTitle(
                            'Informations de base',
                            'Étape ${currentStep + 1} sur $totalSteps',
                          )
                        else if (currentStep == 1)
                          _buildStepTitle(
                            'Localisation & Expérience',
                            'Étape ${currentStep + 1} sur $totalSteps',
                          )
                        else if (currentStep == 2)
                          _buildStepTitle(
                            'Salaire & Avantages',
                            'Étape ${currentStep + 1} sur $totalSteps',
                          )
                        else
                          _buildStepTitle(
                            'Description détaillée',
                            'Étape ${currentStep + 1} sur $totalSteps',
                          ),

                        // Form Content
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Form(
                            key: _formKey,
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildBasicInfoStep(),
                                _buildLocationStep(),
                                _buildSalaryStep(),
                                _buildDetailsStep(),
                              ],
                            ),
                          ),
                        ),

                        // Navigation Buttons
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              if (currentStep > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _previousStep,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: colors.primary),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: SubTitle(
                                      text: 'Précédent',
                                      fontWeight: FontWeight.w600,
                                      fontsize: 16,
                                    ),
                                  ),
                                ),
                              if (currentStep > 0) const SizedBox(width: 12),
                              Expanded(
                                flex: currentStep == 0 ? 1 : 1,
                                child: Btn(
                                  texte: currentStep == totalSteps - 1
                                      ? 'Publier l\'offre'
                                      : 'Suivant',
                                  function: _nextStep,
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
      ),
    );
  }
}
