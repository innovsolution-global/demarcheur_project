import 'dart:io';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/methods/my_methodes.dart';
import 'package:demarcheur_app/widgets/btn_page.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PrestataireRegisterPage extends StatefulWidget {
  const PrestataireRegisterPage({super.key});

  @override
  State<PrestataireRegisterPage> createState() =>
      _PrestataireRegisterPageState();
}

class _PrestataireRegisterPageState extends State<PrestataireRegisterPage> {
  final MyMethodes methodes = MyMethodes();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  Future<void> openImageCamera() async {
    try {
      // 2. Request to pick an image from the gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        // You can limit the image size or quality if needed
        //maxWidth: 1080,
        // imageQuality: 70,
      );

      if (image != null) {
        // 3. If an image was selected, update the state
        // This part should be wrapped in setState() inside a StatefulWidget
        // to update the UI (e.g., displaying the image).
        setState(() {
          selectedImage = File(image.path);
        });
        //print('Image picked successfully: ${selectedImage!.path}');

        // Example of setting state if this function is inside a State class:
        /*
      setState(() {
        _selectedImage = File(image.path);
      });
      */
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle potential errors (e.g., permission denied)
      //print('Error picking image: $e');
    }
  }

  Future<void> openImageGallery() async {
    try {
      // 2. Request to pick an image from the gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        // You can limit the image size or quality if needed
        //maxWidth: 1080,
        // imageQuality: 70,
      );

      if (image != null) {
        // 3. If an image was selected, update the state
        // This part should be wrapped in setState() inside a StatefulWidget
        // to update the UI (e.g., displaying the image).
        setState(() {
          selectedImage = File(image.path);
        });
        //print('Image picked successfully: ${selectedImage!.path}');

        // Example of setting state if this function is inside a State class:
        /*
      setState(() {
        _selectedImage = File(image.path);
      });
      */
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle potential errors (e.g., permission denied)
      //print('Error picking image: $e');
    }
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isloading = true;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        isloading = false;
      });
    });
  }

  ConstColors color = ConstColors();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: isloading
          ? Scaffold(
              backgroundColor: color.bg,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SpinKitThreeBounce(color: color.primary, size: 20.0),
                ),
              ),
            )
          : Scaffold(
              backgroundColor: color.bg,
              extendBodyBehindAppBar: true,
              body: CustomScrollView(
                slivers: [
                  Header(isLeading: true),
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      color: color.bg,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Form(
                              child: Column(
                                children: [
                                  SizedBox(height: 6),
                                  TitleWidget(
                                    text: "Creer un compte",
                                    fontSize: 30,
                                    color: color.secondary,
                                  ),
                                  SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Center(
                                              child: TitleWidget(
                                                text: "Choisissez",
                                              ),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        openImageGallery();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons.camera,
                                                            size: 30,
                                                            color:
                                                                color.primary,
                                                          ),
                                                          SubTitle(
                                                            text: "Gallerie",
                                                            fontsize: 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 20),
                                                    GestureDetector(
                                                      onTap: () {
                                                        openImageCamera();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Column(
                                                        children: [
                                                          HugeIcon(
                                                            icon: HugeIcons
                                                                .strokeRoundedCamera01,
                                                            color:
                                                                color.primary,
                                                            size: 30,
                                                          ),
                                                          SubTitle(
                                                            text: "Camera",
                                                            fontsize: 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Stack(
                                      alignment: AlignmentGeometry.bottomRight,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            // The background color for the circle
                                            color: color.tertiary,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            // 3. Add a border to make the circle stand out
                                            border: Border.all(
                                              color: color.primary,
                                              width: 1,
                                            ),
                                            // 4. If an image is selected, use it as the background image
                                            image: selectedImage != null
                                                ? DecorationImage(
                                                    image: FileImage(
                                                      selectedImage!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null, // Otherwise, don't use a background image
                                          ),
                                          child: selectedImage == null
                                              ? Center(
                                                  // Show the camera icon when no image is selected
                                                  child: HugeIcon(
                                                    icon: HugeIcons
                                                        .strokeRoundedCamera01,
                                                  ),
                                                )
                                              : null, // Hide the camera icon when an image is selected
                                        ),
                                        selectedImage == null
                                            ? HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedCamera01,
                                                color: Colors.transparent,
                                                size: 1,
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedCameraAdd02,
                                                  color: color.bg,
                                                  size: 23,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  _CustomTextField(
                                    controller: TextEditingController(), // Replace with proper controller later if needed
                                    label: "Votre nom complet",
                                    icon: Icons.person_outline,
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 20),
                                  _CustomTextField(
                                    controller: TextEditingController(),
                                    label: "Votre domaine d'activité",
                                    icon: Icons.work_outline,
                                    textCapitalization: TextCapitalization.sentences,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 20),
                                  _CustomTextField(
                                    controller: emailController,
                                    label: "Votre adresse e-mail",
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textCapitalization: TextCapitalization.none,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 20),
                                  IntlPhoneField(
                                    keyboardType: TextInputType.phone,
                                    disableLengthCheck: true,
                                    initialCountryCode: 'GN',
                                    style: TextStyle(fontSize: 18, color: color.secondary, fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      hintText: "Votre numéro de téléphone",
                                      hintStyle: TextStyle(color: color.secondary.withOpacity(0.5), fontSize: 16),
                                      filled: true,
                                      fillColor: color.bgSubmit ?? Colors.grey.shade100,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: color.primary, width: 2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      errorStyle: TextStyle(color: Colors.red),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.red),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _CustomTextField(
                                    controller: TextEditingController(),
                                    label: "Votre localisation",
                                    icon: Icons.location_on_outlined,
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 20),
                                  _CustomTextField(
                                    controller: passwordController,
                                    label: "Mot de passe",
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    textCapitalization: TextCapitalization.none,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                BtnPage(
                                  texte: "Confirmer",
                                  route: "/prestataire",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final dynamic icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool isPassword;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.textCapitalization,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<_CustomTextField> {
  bool obscuredText = true;

  @override
  Widget build(BuildContext context) {
    final color = ConstColors();

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      textCapitalization: widget.textCapitalization,
      validator: widget.validator,
      obscureText: widget.isPassword ? obscuredText : false,
      style: TextStyle(fontSize: 18, color: color.secondary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: TextStyle(color: color.secondary.withOpacity(0.5), fontSize: 16),
        prefixIcon: Icon(widget.icon, color: color.primary),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  obscuredText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: color.primary,
                ),
                onPressed: () {
                  setState(() {
                    obscuredText = !obscuredText;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: color.bgSubmit ?? Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color.primary, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        errorStyle: TextStyle(color: Colors.red),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
