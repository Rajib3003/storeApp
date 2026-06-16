import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'google_auth_service.dart';
import 'drive_service.dart';

class BackupService {
  static Future<File> _getDbFile() async {
    final dbPath = await getDatabasesPath();
    return File(join(dbPath, 'store.db'));
  }

  static Future<File?> backupLocal() async {
    final db = await _getDbFile();

    if (!await db.exists()) return null;

    final backupPath = join(db.parent.path, 'backup_store.db');

    return await db.copy(backupPath);
  }

  static Future<void> backup() async {
    final db = await backupLocal();
    if (db == null) return;

    final user = await GoogleAuthService.signIn();
    if (user == null) return;

    await DriveService.initDrive(user);
    await DriveService.uploadFile(db);
  }
}