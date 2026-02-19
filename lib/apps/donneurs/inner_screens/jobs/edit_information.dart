import 'dart:io';

import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/donnor_user_provider.dart';
import 'package:demarcheur_app/providers/enterprise_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInformation extends StatefulWidget {
  const EditInformation({super.key});

  @override
  State<EditInformation> createState() => _EditInformationState();
}

class _EditInformationState extends State<EditInformation> {
  final _formKey = GlobalKey<FormState>();
  final ConstColors colors = ConstColors();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  bool _isDataLoaded = false;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'GIVER';

    if (mounted) {
      setState(() {
        _role = role;
      });

      if (role == 'GIVER') {
        context.read<EnterpriseProvider>().loadUser();
      } else if (role == 'SEARCHER') {
        context.read<DonnorUserProvider>().loadUser();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      if (_role == 'GIVER') {
        final user = context.watch<EnterpriseProvider>().user;
        if (user != null) {
          _nameController.text = user.name;
          _phoneController.text = user.phone ?? '';
          _addressController.text = user.adress ?? '';
          _cityController.text = user.city ?? '';
          _isDataLoaded = true;
        }
      } else if (_role == 'SEARCHER') {
        final user = context.watch<DonnorUserProvider>().user;
        if (user != null) {
          _nameController.text = user.name;
          _phoneController.text = user.phone ?? '';
          _addressController.text = user.adress ?? '';
          _cityController.text = user.city ?? '';
          _isDataLoaded = true;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success = false;
    if (_role == 'GIVER') {
      final provider = context.read<EnterpriseProvider>();
      success = await provider.updateProfile(
        _nameController.text,
        _phoneController.text,
        _addressController.text,
        _cityController.text,
        _selectedImage,
      );
    } else {
      final provider = context.read<DonnorUserProvider>();
      success = await provider.updateProfile(
        _nameController.text,
        _phoneController.text,
        _addressController.text,
        _cityController.text,
        _selectedImage,
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profil mis à jour avec succès"),
            backgroundColor: colors.primary,
          ),
        );
        Navigator.pop(context); // Go back after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de la mise à jour du profil"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? profileUrl;
    if (_role == 'GIVER') {
      profileUrl = context.watch<EnterpriseProvider>().user?.profile;
    } else {
      profileUrl = context.watch<DonnorUserProvider>().user?.profile;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text(
          "Modifier le profil",
          style: TextStyle(
            color: colors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowTurnBackward,
            color: colors.primary,
            strokeWidth: 2,
            size: 30,
          ),
        ),
      ),
      body: _isLoading && profileUrl == null
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: colors.primary.withOpacity(0.1),
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : (profileUrl != null &&
                                        profileUrl.isNotEmpty)
                                  ? Image.network(
                                      profileUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 60,
                                              color: colors.primary.withOpacity(
                                                0.2,
                                              ),
                                            );
                                          },
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 60,
                                      color: colors.primary.withOpacity(0.2),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCamera01,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Modify Info Fields
                    _buildTextField(
                      controller: _nameController,
                      label: "Nom de l'entreprise / Votre nom",
                      icon: HugeIcons.strokeRoundedUser,
                      validator: (value) => value == null || value.isEmpty
                          ? "Le nom est requis"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: "Téléphone",
                      icon: HugeIcons.strokeRoundedCall02,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: "Adresse",
                      icon: HugeIcons.strokeRoundedLocation01,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: "Ville",
                      icon: HugeIcons.strokeRoundedCity01,
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: colors.primary.withOpacity(0.4),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Enregistrer les modifications",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required dynamic icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
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
}
