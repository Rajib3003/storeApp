import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  // ================= CAMERA =================

  static Future<File?> pickFromCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (file == null) return null;

    return File(file.path);
  }

  // ================= GALLERY =================

  static Future<File?> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return null;

    return File(file.path);
  }

  // ================= FIREBASE STORAGE =================

  static Future<String?> upload(File image) async {
    try {
      final fileName =
          "products/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref =
          FirebaseStorage.instance.ref().child(fileName);

      await ref.putFile(image);

      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }
}