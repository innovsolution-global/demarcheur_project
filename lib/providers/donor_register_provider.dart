import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class DonorRegisterProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  // Form fields
  String _fullName = '';
  String _specialty = '';
  String _email = '';
  String _phone = '';
  String _location = '';

  // Image
  File? _selectedImage;

  // Loading states
  bool _isInitialLoading = true;
  bool _isSubmitting = false;

  // Validation errors
  String? _fullNameError;
  String? _specialtyError;
  String? _emailError;
  String? _phoneError;
  String? _locationError;

  // Getters
  String get fullName => _fullName;
  String get specialty => _specialty;
  String get email => _email;
  String get phone => _phone;
  String get location => _location;
  File? get selectedImage => _selectedImage;
  bool get isInitialLoading => _isInitialLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isValid =>
      _fullNameError == null &&
      _specialtyError == null &&
      _emailError == null &&
      _phoneError == null &&
      _locationError == null &&
      _fullName.isNotEmpty &&
      _specialty.isNotEmpty &&
      _email.isNotEmpty &&
      _phone.isNotEmpty &&
      _location.isNotEmpty;

  String? get fullNameError => _fullNameError;
  String? get specialtyError => _specialtyError;
  String? get emailError => _emailError;
  String? get phoneError => _phoneError;
  String? get locationError => _locationError;

  // Initialize loading (simulates initial setup)
  Future<void> initialize() async {
    _isInitialLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _isInitialLoading = false;
    notifyListeners();
  }

  // Setters for form fields
  void setFullName(String value) {
    _fullName = value;
    _validateFullName();
    notifyListeners();
  }

  void setSpecialty(String value) {
    _specialty = value;
    _validateSpecialty();
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    _validateEmail();
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    _validatePhone();
    notifyListeners();
  }

  void setLocation(String value) {
    _location = value;
    _validateLocation();
    notifyListeners();
  }

  // Validation methods
  void _validateFullName() {
    if (_fullName.isEmpty) {
      _fullNameError = 'Le nom complet est requis';
    } else if (_fullName.length < 3) {
      _fullNameError = 'Le nom doit contenir au moins 3 caractères';
    } else {
      _fullNameError = null;
    }
  }

  void _validateSpecialty() {
    if (_specialty.isEmpty) {
      _specialtyError = 'La spécialité est requise';
    } else {
      _specialtyError = null;
    }
  }

  void _validateEmail() {
    if (_email.isEmpty) {
      _emailError = 'L\'email est requis';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email)) {
      _emailError = 'Format d\'email invalide';
    } else {
      _emailError = null;
    }
  }

  void _validatePhone() {
    if (_phone.isEmpty) {
      _phoneError = 'Le numéro de téléphone est requis';
    } else if (_phone.length < 8) {
      _phoneError = 'Numéro de téléphone invalide';
    } else {
      _phoneError = null;
    }
  }

  void _validateLocation() {
    if (_location.isEmpty) {
      _locationError = 'La localisation est requise';
    } else {
      _locationError = null;
    }
  }

  // Validate all fields
  void validateAll() {
    _validateFullName();
    _validateSpecialty();
    _validateEmail();
    _validatePhone();
    _validateLocation();
    notifyListeners();
  }

  // Image picker methods
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1080,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
  }

  // Submit form
  Future<bool> submitForm() async {
    validateAll();

    if (!isValid) {
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _isSubmitting = false;
    notifyListeners();

    return true;
  }

  // Clear form
  void clearForm() {
    _fullName = '';
    _specialty = '';
    _email = '';
    _phone = '';
    _location = '';
    _selectedImage = null;
    _fullNameError = null;
    _specialtyError = null;
    _emailError = null;
    _phoneError = null;
    _locationError = null;
    notifyListeners();
  }
}
