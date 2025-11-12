import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MyMethodes {
  File? _selectedImage;

  // 1. Create the ImagePicker instance
  final ImagePicker _picker = ImagePicker();

  Future<void> openImageGallery() async {
    try {
      // 2. Request to pick an image from the gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        // You can limit the image size or quality if needed
        // maxWidth: 1080,
        // imageQuality: 70,
      );

      if (image != null) {
        // 3. If an image was selected, update the state
        // This part should be wrapped in setState() inside a StatefulWidget
        // to update the UI (e.g., displaying the image).
        
        _selectedImage = File(image.path);
        print('Image picked successfully: ${_selectedImage!.path}');

        // Example of setting state if this function is inside a State class:
        /*
      setState(() {
        _selectedImage = File(image.path);
      });
      */
      } else {
        // User canceled the selection
        print('No image selected.');
      }
    } catch (e) {
      // Handle potential errors (e.g., permission denied)
      print('Error picking image: $e');
    }
  }
  Future<void> openCamera() async {
    try {
      // 2. Request to pick an image from the gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        // You can limit the image size or quality if needed
        // maxWidth: 1080,
        // imageQuality: 70,
      );

      if (image != null) {
        // 3. If an image was selected, update the state
        // This part should be wrapped in setState() inside a StatefulWidget
        // to update the UI (e.g., displaying the image).
        _selectedImage = File(image.path);
        print('Image picked successfully: ${_selectedImage!.path}');

        // Example of setting state if this function is inside a State class:
        /*
      setState(() {
        _selectedImage = File(image.path);
      });
      */
      } else {
        // User canceled the selection
        print('No image selected.');
      }
    } catch (e) {
      // Handle potential errors (e.g., permission denied)
      print('Error picking image: $e');
    }
  }
}