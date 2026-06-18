import 'package:flutter/material.dart';
import 'master_service.dart';

class TableEditorScreen extends StatefulWidget {
  final String tableName;
  final Map<String, dynamic>? rowData;

  const TableEditorScreen({super.key, required this.tableName, this.rowData});

  @override
  State<TableEditorScreen> createState() => _TableEditorScreenState();
}

class _TableEditorScreenState extends State<TableEditorScreen> {
  final Map<String, TextEditingController> _controllers = {};
  late Future<List<Map<String, dynamic>>> _metadataFuture;
  late List<Map<String, dynamic>> _columns;

  @override
  void initState() {
    super.initState();
    _metadataFuture = MasterService.getTableColumns(widget.tableName);
    _columns = [];
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isNumericColumn(String type) {
    final normalized = type.toLowerCase();
    return normalized.contains('int') || normalized.contains('real') || normalized.contains('numeric');
  }

  bool _isDateColumn(String name) {
    final lower = name.toLowerCase();
    return lower.contains('date') || lower.contains('created_at') || lower.contains('updated_at');
  }

  String _fieldLabel(String name) {
    return name.replaceAll('_', ' ').toUpperCase();
  }

  Map<String, dynamic> _collectValues() {
    final values = <String, dynamic>{};
    for (final column in _columns) {
      final name = column['name'] as String;
      if (name == 'id') continue;
      final controller = _controllers[name];
      if (controller == null) continue;
      var text = controller.text.trim();
      if (_isDateColumn(name) && text.isEmpty) {
        text = DateTime.now().toIso8601String();
      }
      if (text.isEmpty) {
        values[name] = null;
        continue;
      }
      if (_isNumericColumn(column['type'] as String)) {
        if (text.contains('.')) {
          values[name] = double.tryParse(text);
        } else {
          values[name] = int.tryParse(text) ?? double.tryParse(text);
        }
      } else {
        values[name] = text;
      }
    }
    return values;
  }

  Future<void> _save() async {
    final values = _collectValues();
    if (widget.rowData == null) {
      await MasterService.insert(widget.tableName, values);
    } else if (widget.rowData!['id'] is int) {
      await MasterService.update(widget.tableName, widget.rowData!['id'] as int, values);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _buildForm() {
    return Column(
      children: _columns.map((column) {
        final name = column['name'] as String;
        final type = column['type'] as String;
        if (name == 'id') {
          return const SizedBox.shrink();
        }

        final controller = _controllers.putIfAbsent(
          name,
          () {
            final initial = widget.rowData != null && widget.rowData!.containsKey(name)
                ? widget.rowData![name]?.toString() ?? ''
                : '';
            return TextEditingController(text: initial);
          },
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: controller,
            keyboardType: _isNumericColumn(type) ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: _fieldLabel(name),
              border: const OutlineInputBorder(),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rowData == null ? 'Add record' : 'Edit record'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _metadataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          _columns = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildForm(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
