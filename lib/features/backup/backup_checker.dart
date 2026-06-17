import 'package:flutter/material.dart';
import 'backup_reminder.dart';
import 'backup_service.dart';

class BackupChecker {
  static Future<void> check(BuildContext context) async {
    final show = await BackupReminder.shouldShowBackupDialog();

    if (!show) return;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Backup"),
        content: const Text(
          "Backup your data to Google Drive?",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await BackupService.backupToDrive();
              await BackupReminder.saveBackupDate();

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}