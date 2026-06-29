import 'package:flutter/material.dart';

class LookupDropdown extends StatelessWidget {
  final String label;
  final List<Map<String, dynamic>> items;
  final int? value;
  final ValueChanged<int?> onChanged;

  const LookupDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((row) {
          final id = row['id'] as int;

          final text =
              row['category_name'] ??
              row['brand_name'] ??
              row['color_name'] ??
              row['size_name'] ??
              row['supplier_name'] ??
              row['customer_name'] ??
              row['role_name'] ??
              row['name'] ??
              row['shop_name'] ??
              id.toString();

          return DropdownMenuItem<int>(
            value: id,
            child: Text(text.toString()),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return "Required";
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}