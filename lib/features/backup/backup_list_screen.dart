import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';
import 'backup_detail_screen.dart';

import 'drive_service.dart';

class BackupListScreen extends StatefulWidget {
  const BackupListScreen({super.key});

  @override
  State<BackupListScreen> createState() => _BackupListScreenState();
}

class _BackupListScreenState extends State<BackupListScreen> {
  List<drive.File> files = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  // ---------------- LOAD FILES ----------------
  Future<void> loadFiles() async {
    try {
      final result = await DriveService.listFiles();

      // latest first
      result.sort((a, b) {
        final aTime = a.createdTime ?? DateTime(1970);
        final bTime = b.createdTime ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      setState(() {
        files = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint("Load error: $e");
    }
  }

  // ---------------- FORMAT BD TIME ----------------
  String formatBDTime(DateTime? time) {
    if (time == null) return "Unknown";

    final bdTime = time.toLocal();

    return DateFormat("dd MMM yyyy - hh:mm a").format(bdTime);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Backups"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : files.isEmpty
              ? const Center(child: Text("No backup found"))
              : ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final f = files[index];
                    final isLatest = index == 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          Icons.cloud,
                          color: isLatest ? Colors.green : Colors.grey,
                        ),

                        // FILE NAME
                        title: Text(
                          f.name ?? "Unknown",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        // DATE (Bangladesh time)
                        subtitle: Text(
                          formatBDTime(f.createdTime),
                        ),

                        // LATEST TAG
                        trailing: isLatest
                            ? const Text(
                                "LATEST",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                            onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                    builder: (_) => BackupDetailScreen(file: f),
                                    ),
                                );
                            }
                      ),
                    );
                  },
                ),
    );
  }
}