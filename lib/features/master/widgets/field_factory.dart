import 'package:flutter/material.dart';

class FieldFactory {
  static Widget build({
    required String field,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: field.replaceAll("_", " ").toUpperCase(),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if ((value ?? "").trim().isEmpty) {
            return "Required";
          }
          return null;
        },
      ),
    );
  }
}