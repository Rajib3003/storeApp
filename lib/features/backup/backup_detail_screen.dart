import 'dart:io';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'table_data_screen.dart';
import 'backup_file_service.dart';

class BackupDetailScreen extends StatefulWidget {
  final drive.File file;

  const BackupDetailScreen({super.key, required this.file});

  @override
  State<BackupDetailScreen> createState() => _BackupDetailScreenState();
}

class _BackupDetailScreenState extends State<BackupDetailScreen> {
  bool loading = false;
  File? downloadedFile;

  // ---------------- DOWNLOAD ----------------
  Future<void> downloadBackup() async {
  setState(() => loading = true);

  try {
    final file = await BackupFileService.downloadDb(widget.file.id!);

    setState(() {
      downloadedFile = file;
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Backup Downloaded Successfully")),
    );

  } catch (e) {
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

  // ---------------- MOCK TABLES ----------------
  final List<Map<String, dynamic>> tables = const [
    {"name": "products", "count": 120},
    {"name": "sales", "count": 45},
    {"name": "cart", "count": 8},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name ?? "Backup"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: downloadBackup,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),

                // FILE INFO
                Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    leading: const Icon(Icons.cloud),
                    title: Text(widget.file.name ?? "Backup"),
                    subtitle: Text(widget.file.id ?? ""),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "📦 Tables",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // TABLE LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];

                      return Card(
                        child: ListTile(
                            leading: const Icon(Icons.table_chart),
                            title: Text(table["name"]),
                            subtitle: Text("${table["count"]} items"),

                            onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (_) => TableDataScreen(
                                    tableName: table["name"],
                                ),
                                ),
                            );
                            },
                        ),
                        );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}