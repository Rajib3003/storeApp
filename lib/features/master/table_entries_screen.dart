import 'package:flutter/material.dart';
import 'master_service.dart';
import 'table_editor_screen.dart';

class TableEntriesScreen extends StatefulWidget {
  final String tableName;

  const TableEntriesScreen({super.key, required this.tableName});

  @override
  State<TableEntriesScreen> createState() => _TableEntriesScreenState();
}

class _TableEntriesScreenState extends State<TableEntriesScreen> {
  late Future<List<Map<String, dynamic>>> _rowsFuture;

  @override
  void initState() {
    super.initState();
    _loadRows();
  }

  void _loadRows() {
    _rowsFuture = MasterService.getAll(widget.tableName);
  }

  Future<void> _refresh() async {
    setState(_loadRows);
    await _rowsFuture;
  }

  String _buildRowSummary(Map<String, dynamic> row) {
    final keys = row.keys.where((key) =>
          key != 'id' &&
          row[key] != null &&
          row[key].toString().trim().isNotEmpty &&
          row[key].toString().toLowerCase() != 'null').take(3).toList();
    final values = keys.map((key) => '${row[key]}').join(' | ');
    return values.isEmpty ? 'No fields' : values;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table: ${widget.tableName}'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _rowsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final rows = snapshot.data ?? [];

            if (rows.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 60),
                  Center(child: Text('No records found')),
                ],
              );
            }

            return ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('ID: ${row['id'] ?? '-'}'),
                    subtitle: Text(_buildRowSummary(row)),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TableEditorScreen(
                            tableName: widget.tableName,
                            rowData: row,
                          ),
                        ),
                      );
                      await _refresh();
                    },
                    onLongPress: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete record'),
                          content: const Text('Do you want to delete this record?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        if (row['id'] is int) {
                          await MasterService.delete(widget.tableName, row['id'] as int);
                          await _refresh();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Record deleted')),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TableEditorScreen(tableName: widget.tableName),
            ),
          );
          await _refresh();
        },
      ),
    );
  }
}
