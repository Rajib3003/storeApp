import 'package:flutter/material.dart';

import 'master_service.dart';
import 'widgets/dynamic_form.dart';

class TableEditorScreen extends StatefulWidget {
  final String tableName;
  final Map<String, dynamic>? rowData;

  const TableEditorScreen({
    super.key,
    required this.tableName,
    this.rowData,
  });

  @override
  State<TableEditorScreen> createState() =>
      _TableEditorScreenState();
}

class _TableEditorScreenState
    extends State<TableEditorScreen> {

  final GlobalKey<DynamicFormState> formKey =
      GlobalKey<DynamicFormState>();

  bool saving = false;

  Future<void> save() async {
    if (saving) return;

    final form = formKey.currentState;

    if (form == null) return;

    if (!form.formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    final values = form.getValues();

    if (widget.rowData == null) {
      await MasterService.insert(
        widget.tableName,
        values,
      );
    } else {
      await MasterService.update(
        widget.tableName,
        widget.rowData!['id'],
        values,
      );
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rowData == null
            ? "Add Record"
            : "Edit Record"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: DynamicForm(
            key: formKey,
            tableName: widget.tableName,
            row: widget.rowData,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: save,
        icon: const Icon(Icons.save),
        label: const Text("SAVE"),
      ),
    );
  }
}