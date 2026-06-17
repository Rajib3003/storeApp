import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'drive_service.dart';

class BackupFileService {

  static Future<File> downloadDb(String fileId) async {
  final dir = await getApplicationDocumentsDirectory();

  final filePath = "${dir.path}/backup.db";

  final file = await DriveService.download(fileId);

  print("Downloaded path: ${file.path}");

  return file;
}
}