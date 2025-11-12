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

                                  TextFormField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      hint: SubTitle(
                                        text: "Votre nom complet",
                                        fontWeight: FontWeight.w500,
                                        fontsize: 16,
                                      ),
                                      fillColor: color.bgSubmit,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      hint: SubTitle(
                                        text: "Votre domaine d'activite",
                                        fontsize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      fillColor: color.bgSubmit,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      hint: SubTitle(
                                        text: "Votre adresse e-mail",
                                        fontWeight: FontWeight.w500,
                                        fontsize: 16,
                                      ),
                                      fillColor: color.bgSubmit,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      hint: SubTitle(
                                        text: "Votre numero de telephone",
                                        fontWeight: FontWeight.w500,
                                        fontsize: 16,
                                      ),
                                      fillColor: color.bgSubmit,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      hint: SubTitle(
                                        text: "Votre localisation",
                                        fontsize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      fillColor: color.bgSubmit,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
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
