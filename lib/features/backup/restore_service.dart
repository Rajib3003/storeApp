import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'drive_service.dart';

class RestoreService {
  static Future<void> restore() async {
    final dbPath = await getDatabasesPath();
    final localPath = join(dbPath, "store.db");

    final files = await DriveService.listFiles();
    if (files.isEmpty) return;

    final fileId = files.first.id;
    if (fileId == null) return;

    final downloaded = await DriveService.download(
      fileId,
      localPath,
    );

    if (downloaded == null) return;

    print("Restore completed");
  }
}