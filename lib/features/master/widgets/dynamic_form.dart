import 'package:flutter/material.dart';

import '../master_service.dart';
import '../helpers/table_config.dart';
import 'field_factory.dart';
import 'lookup_dropdown.dart';
import 'photo_picker.dart';

class DynamicForm extends StatefulWidget {
  final String tableName;
  final Map<String, dynamic>? row;

  const DynamicForm({
    super.key,
    required this.tableName,
    this.row,
  });

  @override
  DynamicFormState createState() => DynamicFormState();
}

class DynamicFormState extends State<DynamicForm> {
  final formKey = GlobalKey<FormState>();

  final controllers = <String, TextEditingController>{};

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> colors = [];
  List<Map<String, dynamic>> sizes = [];

  int? categoryId;
  int? brandId;
  int? colorId;
  int? sizeId;

  @override
  void initState() {
    super.initState();

    final fields =
        TableConfig.editableFields[widget.tableName] ?? [];

    for (final field in fields) {
      controllers[field] = TextEditingController(
        text: widget.row?[field]?.toString() ?? "",
      );
    }

    categoryId = widget.row?['category_id'];
    brandId = widget.row?['brand_id'];
    colorId = widget.row?['color_id'];
    sizeId = widget.row?['size_id'];

    loadLookups();
  }

  Future<void> loadLookups() async {
    categories = await MasterService.getAll("categories");
    brands = await MasterService.getAll("brands");
    colors = await MasterService.getAll("colors");
    sizes = await MasterService.getAll("sizes");

    if (mounted) {
      setState(() {});
    }
  }

  Map<String, dynamic> getValues() {
    final map = <String, dynamic>{};

    controllers.forEach((key, value) {
      map[key] = value.text.trim();
    });

    if (widget.tableName == "products") {
      map["category_id"] = categoryId;
      map["brand_id"] = brandId;
      map["color_id"] = colorId;
      map["size_id"] = sizeId;
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    final fields =
        TableConfig.editableFields[widget.tableName] ?? [];

    return Form(
      key: formKey,
      child: Column(
        children: [

          if (widget.tableName == "products") ...[

            LookupDropdown(
              label: "Category",
              items: categories,
              value: categoryId,
              onChanged: (v) {
                setState(() {
                  categoryId = v;
                });
              },
            ),

            LookupDropdown(
              label: "Brand",
              items: brands,
              value: brandId,
              onChanged: (v) {
                setState(() {
                  brandId = v;
                });
              },
            ),

            LookupDropdown(
              label: "Color",
              items: colors,
              value: colorId,
              onChanged: (v) {
                setState(() {
                  colorId = v;
                });
              },
            ),

            LookupDropdown(
              label: "Size",
              items: sizes,
              value: sizeId,
              onChanged: (v) {
                setState(() {
                  sizeId = v;
                });
              },
            ),
          ],

          for (final field in fields)
            if (field != "category_id" &&
                field != "brand_id" &&
                field != "color_id" &&
                field != "size_id")
                if (field == "photo")
                  PhotoPicker(
                    initialValue: controllers[field]?.text,
                    onChanged: (path) {
                      controllers[field]?.text = path;
                    },
                  )
                else
                  FieldFactory.build(
                    field: field,
                    controller: controllers[field]!,
                  ),

              
        ],
      ),
    );
  }
}