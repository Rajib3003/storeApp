import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BackupService {
  /// 📦 Get database file
  static Future<File> _getDbFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'store.db');

    return File(path);
  }

  /// 📤 LOCAL BACKUP (temporary + safety copy)
  static Future<File?> backupLocal() async {
    try {
      final dbFile = await _getDbFile();

      if (!await dbFile.exists()) {
        throw Exception("Database not found");
      }

      final backupPath = join(
        dbFile.parent.path,
        'backup_store.db',
      );

      final backupFile = await dbFile.copy(backupPath);

      print("Local backup created: ${backupFile.path}");

      return backupFile;
    } catch (e) {
      print("Local backup failed: $e");
      return null;
    }
  }

  /// ☁️ MAIN BACKUP ENTRY (future Google Drive connect here)
  static Future<void> backup() async {
    try {
      final backupFile = await backupLocal();

      if (backupFile == null) {
        throw Exception("Backup failed");
      }

      // 👉 এখানে পরে Google Drive upload হবে
      // await DriveService.uploadFile(backupFile);

      print("Backup process completed successfully");
    } catch (e) {
      print("Backup failed: $e");
    }
  }
}