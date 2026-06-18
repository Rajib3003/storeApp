import 'package:flutter/material.dart';
import 'master_service.dart';
import 'table_entries_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  late Future<List<String>> _tablesFuture;

  @override
  void initState() {
    super.initState();
    _tablesFuture = MasterService.getTables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Tables'),
      ),
      body: FutureBuilder<List<String>>(
        future: _tablesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tables = snapshot.data ?? [];

          if (tables.isEmpty) {
            return const Center(child: Text('No tables found'));
          }

          return ListView.builder(
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final tableName = tables[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(tableName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TableEntriesScreen(tableName: tableName),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
