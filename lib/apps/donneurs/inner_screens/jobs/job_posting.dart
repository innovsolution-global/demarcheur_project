import 'dart:io';

import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/immo_header.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/models/add_vancy_model.dart';

class JobPostings extends StatefulWidget {
  const JobPostings({super.key});

  @override
  State<JobPostings> createState() => _JobPostingsState();
}

class _JobPostingsState extends State<JobPostings>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final ConstColors colors = ConstColors();

  // Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _contactController = TextEditingController();
  final _levelController = TextEditingController();
  final _experienceController = TextEditingController();
  final _deadlineController = TextEditingController();

  // Form State
  String? selectedServiceCategory;
  String? selectedDuration;
  List<File> selectedImages = [];
  bool isSubmitting = false;

  // Service Categories
  final List<String> serviceCategories = [
    'Nettoyage ménager',
    'Plomberie',
    'Électricité',
    'Réparation générale',
    'Jardinage',
    'Peinture',
    'Déménagement',
    'Autre',
  ];

  // Duration Options
  final List<String> durationOptions = [
    'Ponctuel',
    'Hebdomadaire',
    'Mensuel',
    'À discuter',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _requirementsController.dispose();
    _contactController.dispose();
    _levelController.dispose();
    _experienceController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1080,
        imageQuality: 80,
      );

      if (images.isNotEmpty && selectedImages.length + images.length <= 5) {
        setState(() {
          selectedImages.addAll(images.map((image) => File(image.path)));
        });
      } else if (selectedImages.length + images.length > 5) {
        _showSnackBar('Maximum 5 images autorisées', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection des images', isError: true);
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
        backgroundColor: isError ? colors.error : colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _mapDurationToJobType(String? duration) {
    switch (duration) {
      case 'Ponctuel':
      case 'Hebdomadaire':
      case 'Mensuel':
      case 'À discuter':
        return 'FREELANCE';
      default:
        return 'FREELANCE';
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedServiceCategory == null) {
        _showSnackBar('Veuillez sélectionner une catégorie', isError: true);
        return;
      }
      if (selectedDuration == null) {
        _showSnackBar('Veuillez sélectionner la durée', isError: true);
        return;
      }

      final authProvider = context.read<AuthProvider>();

      print('DEBUG: JobPosting - Role: ${authProvider.role}');
      print('DEBUG: JobPosting - UserID: ${authProvider.userId}');
      print('DEBUG: JobPosting - Enterprise: ${authProvider.enterprise?.id}');

      final companyId = authProvider.enterprise?.id ?? authProvider.userId;
      print('DEBUG: JobPosting - Selected CompanyID: $companyId');

      if (companyId == null) {
        _showSnackBar(
          'Erreur: Identifiant manquant. Veuillez vous reconnecter.',
          isError: true,
        );
        return;
      }

      setState(() {
        isSubmitting = true;
      });

      final vancy = AddVancyModel(
        title: _titleController.text,
        description: _descriptionController.text,
        city: _locationController.text,
        salary: int.tryParse(_budgetController.text) ?? 0,
        typeJobe: _mapDurationToJobType(selectedDuration),
        level: _levelController.text.isNotEmpty
            ? _levelController.text
            : 'Intermédiaire',
        experience: _experienceController.text.isNotEmpty
            ? _experienceController.text
            : '1-3 ans',
        deadline: _deadlineController.text.isNotEmpty
            ? _deadlineController.text
            : DateTime.now()
                  .add(const Duration(days: 30))
                  .toString()
                  .split(' ')[0],
        companyId: companyId,
        missions: [_descriptionController.text],
        benefits: [],
        conditions: [_requirementsController.text],
        reqProfile: [_requirementsController.text],
        otherInfo: [_contactController.text],
      );

      final success = await authProvider.addVancyJob(vancy);

      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      if (success) {
        _showSnackBar('Annonce publiée avec succès !');
        Navigator.pop(context);
      } else {
        _showSnackBar('Échec de la publication de l\'annonce', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Form(
          key: _formKey,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const ImmoHeader(auto: true),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        "Nouvelle Offre",
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                      Text(
                        "Trouvez le prestataire idéal pour vos besoins",
                        style: TextStyle(
                          color: colors.secondary.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),
                      const SizedBox(height: 32),

                      _buildSectionTitle(
                        "Informations de base",
                        Icons.info_outline,
                      ),
                      _buildModernCard(
                        children: [
                          _buildModernTextField(
                            controller: _titleController,
                            label: 'Titre de l\'offre',
                            hint: 'Ex: Recherche plombier pour réparation',
                            icon: Icons.title_rounded,
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                          const SizedBox(height: 24),
                          _buildModernTextField(
                            controller: _locationController,
                            label: 'Localisation',
                            hint: 'Où se situe le besoin ?',
                            icon: Icons.location_on_outlined,
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        "Catégorie & Type",
                        Icons.category_outlined,
                      ),
                      _buildModernCard(
                        children: [
                          const Text(
                            "Sélectionnez une catégorie",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildChoiceChips(
                            items: serviceCategories,
                            selected: selectedServiceCategory,
                            onSelected: (v) =>
                                setState(() => selectedServiceCategory = v),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Durée estimée",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildChoiceChips(
                            items: durationOptions,
                            selected: selectedDuration,
                            onSelected: (v) =>
                                setState(() => selectedDuration = v),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),

                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        "Description & Détails",
                        Icons.description_outlined,
                      ),
                      _buildModernCard(
                        children: [
                          _buildModernTextField(
                            controller: _descriptionController,
                            label: 'Description détaillée',
                            hint: 'Décrivez précisément votre besoin...',
                            icon: Icons.notes_rounded,
                            maxLines: 4,
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                          const SizedBox(height: 24),
                          _buildModernTextField(
                            controller: _requirementsController,
                            label: 'Exigences particulières',
                            hint: 'Ex: Outillage, expérience minimum...',
                            icon: Icons.rule_rounded,
                            maxLines: 3,
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05),

                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        "Détails Techniques",
                        Icons.settings_outlined,
                      ),
                      _buildModernCard(
                        children: [
                          _buildModernTextField(
                            controller: _levelController,
                            label: 'Niveau d\'expérience requis',
                            hint: 'Ex: Débutant, Senior...',
                            icon: Icons.grade_outlined,
                          ),
                          const SizedBox(height: 24),
                          _buildModernTextField(
                            controller: _experienceController,
                            label: 'Années d\'expérience',
                            hint: 'Ex: 2 ans',
                            icon: Icons.history_toggle_off_rounded,
                          ),
                          const SizedBox(height: 24),
                          _buildModernTextField(
                            controller: _deadlineController,
                            label: 'Date limite',
                            hint: 'AAAA-MM-JJ',
                            icon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 7),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setState(() {
                                  _deadlineController.text = picked
                                      .toString()
                                      .split(' ')[0];
                                });
                              }
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.05),

                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        "Budget & Contact",
                        Icons.payments_outlined,
                      ),
                      _buildModernCard(
                        children: [
                          _buildModernTextField(
                            controller: _budgetController,
                            label: 'Budget estimé (GNF)',
                            hint: 'Ex: 500000',
                            icon: Icons.account_balance_wallet_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                          const SizedBox(height: 24),
                          _buildModernTextField(
                            controller: _contactController,
                            label: 'Moyen de contact preferred',
                            hint: 'Ex: WhatsApp, Téléphone...',
                            icon: Icons.contact_page_outlined,
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                        ],
                      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.05),

                      const SizedBox(height: 32),
                      _buildSectionTitle(
                        "Photos",
                        Icons.photo_library_outlined,
                      ),
                      _buildImagePickerSection()
                          .animate()
                          .fadeIn(delay: 1000.ms)
                          .slideY(begin: 0.05),

                      const SizedBox(height: 48),
                      _buildPremiumSubmitButton(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: colors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          textCapitalization: TextCapitalization.sentences,
          onTap: onTap,
          style: TextStyle(color: colors.secondary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: colors.primary.withOpacity(0.5),
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9).withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildChoiceChips({
    required List<String> items,
    required String? selected,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onSelected(item),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? colors.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? colors.primary : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImagePickerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          if (selectedImages.isEmpty)
            GestureDetector(
              onTap: _pickImages,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: colors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Ajouter des photos",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Montrez aux prestataires de quoi il s'agit",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...selectedImages.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  entry.value,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: GestureDetector(
                                  onTap: () => _removeImage(entry.key),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ).animate().scale(duration: 200.ms),
                        );
                      }),
                      if (selectedImages.length < 5)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                // dashStyle: BorderStyle.dashed,
                              ),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: colors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${selectedImages.length}/5 photos sélectionnées",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPremiumSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                "Publier l'Offre",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
