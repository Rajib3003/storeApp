import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'google_auth_service.dart';
import 'drive_service.dart';

class BackupService {

  static Future<File> _dbFile() async {
    final path = await getDatabasesPath();
    return File(join(path, "store.db"));
  }

  // ✅ FIX: this was missing
  static Future<File> localBackup() async {
    final db = await _dbFile();

    final backupPath = join(db.parent.path, "backup.db");

    return await db.copy(backupPath);
  }

  // ✅ MAIN DRIVE BACKUP
  static Future<void> backupToDrive() async {
    final user = await GoogleAuthService.signIn();

    if (user == null) return;

    await DriveService.initDrive(user);

    final file = await localBackup();

    await DriveService.uploadFile(file);
  }
}