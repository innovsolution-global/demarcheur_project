import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/add_vancy_model.dart';
import 'package:demarcheur_app/providers/enterprise_provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class AddVacancyPage extends StatefulWidget {
  final AddVancyModel? vacancyToEdit;
  const AddVacancyPage({super.key, this.vacancyToEdit});

  @override
  State<AddVacancyPage> createState() => _AddVacancyPageState();
}

class _AddVacancyPageState extends State<AddVacancyPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;
  bool _isSubmitting = false;

  final ConstColors colors = ConstColors();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  String _selectedJobType = 'Plein temps';
  final List<String> _jobTypes = [
    'Plein temps',
    'Temps partiel',
    'Contrat',
    'Freelance',
    'Stage',
  ];

  // List fields
  final List<String> _missions = [];
  final List<String> _benefits = [];
  final List<String> _conditions = [];
  final List<String> _reqProfile = [];
  final List<String> _otherInfo = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    if (widget.vacancyToEdit != null) {
      final v = widget.vacancyToEdit!;
      _titleController.text = v.title;
      _descriptionController.text = v.description;
      _cityController.text = v.city;
      _salaryController.text = v.salary.toString();
      _experienceController.text = v.experience;
      _levelController.text = v.level;
      _deadlineController.text = v.deadline;

      // Map job type back to UI Label
      String mapTypeToUi(String type) {
        switch (type) {
          case 'CDI':
            return 'Plein temps';
          case 'PART_TIME':
            return 'Temps partiel';
          case 'CDD':
            return 'Contrat';
          case 'FREELANCE':
            return 'Freelance';
          case 'STAGE':
            return 'Stage';
          default:
            return type;
        }
      }

      _selectedJobType = mapTypeToUi(v.typeJobe);

      _missions.addAll(v.missions.map((e) => e.toString()));
      _benefits.addAll(v.benefits.map((e) => e.toString()));
      _conditions.addAll(v.conditions.map((e) => e.toString()));
      _reqProfile.addAll(v.reqProfile.map((e) => e.toString()));
      _otherInfo.addAll(v.otherInfo.map((e) => e.toString()));
    }

    Future.microtask(() {
      context.read<EnterpriseProvider>().loadUser();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _salaryController.dispose();
    _experienceController.dispose();
    _levelController.dispose();
    _deadlineController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubicEmphasized,
      );
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubicEmphasized,
      );
    }
  }

  Future<void> _submitForm() async {
    final enterprise = context.read<AuthProvider>().enterprise;
    final companyId = enterprise?.id;

    if (enterprise == null || companyId == null || companyId.isEmpty) {
      _showSnackBar(
        "ID d'entreprise manquant. Veuillez rafraîchir ou vous reconnecter.",
        isError: true,
      );
      return;
    }

    // Basic Validation
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _cityController.text.isEmpty) {
      _showSnackBar(
        "Veuillez remplir les informations obligatoires.",
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String mapJobType(String uiType) {
      switch (uiType) {
        case 'Plein temps':
          return 'CDI';
        case 'Temps partiel':
          return 'PART_TIME';
        case 'Contrat':
          return 'CDD';
        case 'Freelance':
          return 'FREELANCE';
        case 'Stage':
          return 'STAGE';
        default:
          return uiType.toUpperCase();
      }
    }

    final vancy = AddVancyModel(
      id: widget.vacancyToEdit?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      city: _cityController.text,
      salary: int.tryParse(_salaryController.text) ?? 0,
      typeJobe: mapJobType(_selectedJobType),
      level: _levelController.text,
      experience: _experienceController.text,
      deadline: _deadlineController.text,
      companyId: companyId,
      missions: _missions.isNotEmpty ? _missions : [_descriptionController.text],
      benefits: _benefits,
      conditions: _conditions,
      reqProfile: _reqProfile,
      otherInfo: _otherInfo,
    );

    bool success;
    if (widget.vacancyToEdit != null) {
      success = await context.read<AuthProvider>().updateJobOffer(
        widget.vacancyToEdit!.id!,
        vancy,
      );
    } else {
      success = await context.read<AuthProvider>().addVancyJob(vancy, []);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        _showSnackBar(
          widget.vacancyToEdit != null
              ? "Offre mise à jour avec succès !"
              : "Offre publiée avec succès !",
          isError: false,
        );
        Navigator.pop(context);
      } else {
        _showSnackBar(
          widget.vacancyToEdit != null
              ? "Erreur lors de la mise à jour"
              : "Erreur lors de la publication",
          isError: true,
        );
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFFBFBFB),
        body: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildStepContainer(_buildStep1(), 0),
                  _buildStepContainer(_buildStep2(), 1),
                  _buildStepContainer(_buildStep3(), 2),
                  // _buildStepContainer(_buildStep4(), 3),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContainer(Widget child, int stepIndex) {
    if (_currentStep != stepIndex) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOutCubic,
              ),
            ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowTurnBackward,
                    color: colors.bg,
                    strokeWidth: 2,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Créer une offre",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.bg,
                    ),
                  ),
                  Text(
                    "Étape ${_currentStep + 1} sur $_totalSteps",
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.bg.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(_totalSteps, (index) {
              final isActive = index <= _currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  margin: EdgeInsets.only(
                    right: index < _totalSteps - 1 ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors.bg
                        : const Color.fromARGB(255, 36, 44, 62),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeader("Informations de base", "Dites-nous en plus sur le poste"),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _titleController,
          label: "Intitulé du poste",
          icon: HugeIcons.strokeRoundedWorkHistory,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: "Description du poste",
          icon: HugeIcons.strokeRoundedFileEdit,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: "Ville",
                icon: HugeIcons.strokeRoundedLocation01,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _salaryController,
                label: "Salaire (GNF)",
                icon: HugeIcons.strokeRoundedMoney03,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdownField(),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeader(
          "Détails & Avantages",
          "Missions, avantages et conditions",
        ),
        const SizedBox(height: 24),
        _buildListInput(
          "Missions principales",
          _missions,
          HugeIcons.strokeRoundedTask01,
        ),
        const SizedBox(height: 24),
        _buildListInput(
          "Avantages offerts",
          _benefits,
          HugeIcons.strokeRoundedGift,
        ),
        const SizedBox(height: 24),
        _buildListInput(
          "Conditions de travail",
          _conditions,
          HugeIcons.strokeRoundedCheckList,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeader("Profil Recherché", "Compétences et expériences"),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _experienceController,
                label: "Expérience",
                icon: HugeIcons.strokeRoundedClock01,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _levelController,
                label: "Niveau",
                icon: HugeIcons.strokeRoundedMortarboard02,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildListInput(
          "Compétences requises",
          _reqProfile,
          HugeIcons.strokeRoundedStar,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _deadlineController,
          label: "Date limite",
          icon: HugeIcons.strokeRoundedCalendar03,
          readOnly: true, // You might want to add a date picker here
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                _deadlineController.text =
                    "${picked.year}-${picked.month}-${picked.day}";
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: colors.secondary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: colors.secondary.withOpacity(0.6),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required dynamic icon, // Can be IconData or generic
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: colors.secondary, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: colors.secondary.withOpacity(0.4),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: HugeIcon(icon: icon, color: colors.primary, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedJobType,
          isExpanded: true,
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowDown01,
            color: colors.primary,
            size: 24,
          ),
          items: _jobTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedBriefcase02,
                    size: 20,
                    color: colors.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    style: TextStyle(
                      color: colors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) setState(() => _selectedJobType = newValue);
          },
        ),
      ),
    );
  }

  Widget _buildListInput(String label, List<String> list, dynamic icon) {
    final TextEditingController localController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: localController,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: colors.secondary),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          setStateLocal(() {
                            list.add(val.trim());
                            localController.clear();
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "Ajouter un élément...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (localController.text.trim().isNotEmpty) {
                      setStateLocal(() {
                        list.add(localController.text.trim());
                        localController.clear();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
            if (list.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: icon,
                              size: 14,
                              color: colors.primary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  setStateLocal(() => list.remove(item)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -5),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(color: colors.secondary.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Retour",
                  style: TextStyle(
                    color: colors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSubmitting
                    ? colors.secondary
                    : colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: colors.primary.withOpacity(0.5),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == _totalSteps - 1
                          ? "Publier l'offre"
                          : "Suivant",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
