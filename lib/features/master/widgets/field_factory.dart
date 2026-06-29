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

  final text = value?.trim() ?? "";

  if (field == "name") {
    if (text.isEmpty) {
      return "Product name required";
    }
  }

  if (field == "barcode") {
    if (text.isEmpty) {
      return "Barcode required";
    }
  }

  if (field == "purchase_price" ||
      field == "selling_price") {

    if (text.isEmpty) {
      return "Required";
    }

    if (double.tryParse(text) == null) {
      return "Invalid amount";
    }
  }

  if (field == "stock" ||
      field == "low_stock_alert") {

    if (text.isEmpty) {
      return "Required";
    }

    if (int.tryParse(text) == null) {
      return "Invalid number";
    }
  }

  return null;
},
      ),
    );
  }
}