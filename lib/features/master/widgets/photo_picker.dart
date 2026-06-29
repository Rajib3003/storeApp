import 'dart:io';

import 'package:flutter/material.dart';

import '../../../services/photo_service.dart';

class PhotoPicker extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const PhotoPicker({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  File? photo;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null &&
        widget.initialValue!.isNotEmpty) {
      photo = File(widget.initialValue!);
    }
  }

  Future<void> _pickGallery() async {
    final file = await PhotoService.pickFromGallery();

    if (file == null) return;

    setState(() {
      photo = file;
    });

    widget.onChanged(file.path);
  }

  Future<void> _pickCamera() async {
    final file = await PhotoService.pickFromCamera();

    if (file == null) return;

    setState(() {
      photo = file;
    });

    widget.onChanged(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (photo != null)
          Image.file(
            photo!,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          )
        else
          Container(
            width: 150,
            height: 150,
            color: Colors.grey.shade300,
            child: const Icon(Icons.image, size: 50),
          ),

        const SizedBox(height: 10),

        Row(
          children: [

            ElevatedButton.icon(
              onPressed: _pickGallery,
              icon: const Icon(Icons.photo),
              label: const Text("Gallery"),
            ),

            const SizedBox(width: 10),

            ElevatedButton.icon(
              onPressed: _pickCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Camera"),
            ),

          ],
        ),
      ],
    );
  }
}