import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'drive_service.dart';

class RestoreService {
  static Future<void> restore() async {
    try {
      final dbPath = await getDatabasesPath();
      final localPath = join(dbPath, "store.db");

      // 1. Get file list from Drive
      final files = await DriveService.listFiles();

      if (files.isEmpty) {
        print("No backup found in Drive");
        return;
      }

      // 2. Pick latest file
      final latestFile = files.first;
      final fileId = latestFile.id;

      if (fileId == null) {
        print("File ID is null");
        return;
      }

      // 3. Temp download path
      final tempPath = join(dbPath, "restore_temp.db");

      // 4. Download from Drive
      final downloadedFile =
          await DriveService.download(fileId, tempPath);

      if (downloadedFile == null) {
        print("Download failed");
        return;
      }

      // 5. Delete old database
      final localFile = File(localPath);

      if (await localFile.exists()) {
        await localFile.delete();
      }

      // 6. Move downloaded file to database location
      await downloadedFile.copy(localPath);

      print("Restore completed successfully");
    } catch (e) {
      print("Restore failed: $e");
    }
  }
}