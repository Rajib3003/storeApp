import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'google_auth_service.dart';
import 'drive_service.dart';

class BackupService {
  /// ================= GET DB FILE =================
  static Future<File> _getDbFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'store.db');

    return File(path);
  }

  /// ================= CREATE SAFE COPY =================
  static Future<File?> _createBackupCopy() async {
    try {
      final dbFile = await _getDbFile();

      if (!await dbFile.exists()) {
        throw Exception("Database not found");
      }

      final backupPath = join(
        dbFile.parent.path,
        'backup_store.db',
      );

      return await dbFile.copy(backupPath);
    } catch (e) {
      print("Local backup failed: $e");
      return null;
    }
  }

  /// ================= MAIN BACKUP =================
  static Future<void> backup() async {
    try {
      // Step 1: Create local copy
      final backupFile = await _createBackupCopy();

      if (backupFile == null) {
        throw Exception("Backup file not created");
      }

      // Step 2: Check existing login (IMPORTANT FIX)
      final user = GoogleAuthService.currentUser;

      // If not logged in, only do local backup
      if (user == null) {
        print("User not logged in, local backup only");
        return;
      }

      // Step 3: Init Drive (only once)
      await DriveService.initDrive(user);

      // Step 4: Upload to Google Drive
      await DriveService.uploadFile(backupFile);

      print("✅ Google Drive backup completed");
    } catch (e) {
      print("❌ Backup failed: $e");
    }
  }
}