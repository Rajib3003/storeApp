import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'drive_service.dart';

class BackupService {
  BackupService._();

  static Future<File> _databaseFile() async {
    final dbPath = await getDatabasesPath();

    return File(
      join(dbPath, "store.db"),
    );
  }

  static Future<Directory> _photoDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();

    final dir = Directory(
      join(appDir.path, "photos"),
    );

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  // ==========================
  // BACKUP DATABASE + PHOTOS
  // ==========================

  static Future<void> backupToDrive() async {
    final ok = await DriveService.initialize();

    if (!ok) {
      throw Exception("Google Drive login failed.");
    }

    final db = await _databaseFile();

    print("========== BACKUP ==========");
    print("Database Path : ${db.path}");
    print("Database Exists : ${await db.exists()}");

    if (await db.exists()) {
      print("Database Size : ${await db.length()} bytes");
    }

    await DriveService.uploadDatabase(db);

    final photoDir = await _photoDirectory();

    print("Photo Folder : ${photoDir.path}");

    final photos = photoDir.listSync();

    print("Total Photos : ${photos.length}");

    await DriveService.backupAllPhotos(photoDir);

    print("BACKUP COMPLETED");
    print("============================");
  }

  // ==========================
  // RESTORE DATABASE + PHOTOS
  // ==========================

  static Future<void> restoreFromDrive() async {
    final ok = await DriveService.initialize();

    if (!ok) {
      throw Exception("Google Drive login failed.");
    }

    final db = await _databaseFile();

    await DriveService.downloadDatabase(db);

    final photoDir = await _photoDirectory();

    await DriveService.restoreAllPhotos(photoDir);

    print("RESTORE COMPLETED");
  }
}