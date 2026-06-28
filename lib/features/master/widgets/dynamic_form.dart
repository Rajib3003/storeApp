import 'package:flutter/material.dart';

import '../helpers/table_config.dart';
import 'field_factory.dart';

class DynamicForm extends StatefulWidget {
  final String tableName;
  final Map<String, dynamic>? row;

  const DynamicForm({
    super.key,
    required this.tableName,
    this.row,
  });

  @override
  State<DynamicForm> createState() => DynamicFormState();

  
}

class DynamicFormState extends State<DynamicForm> {

  final formKey = GlobalKey<FormState>();

  final controllers = <String, TextEditingController>{};

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
  }

  Map<String, dynamic> getValues() {
    final map = <String, dynamic>{};

    controllers.forEach((key, value) {
      map[key] = value.text.trim();
    });

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

          for (final field in fields)
            FieldFactory.build(
              field: field,
              controller: controllers[field]!,
            ),

        ],
      ),
    );
  }
}