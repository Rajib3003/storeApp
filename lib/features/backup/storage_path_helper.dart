import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StoragePathHelper {

  static Future<String> getDownloadPath() async {
    final dir = await getExternalStorageDirectory();

    final downloadPath = Directory("${dir!.path}/Downloads");

    if (!await downloadPath.exists()) {
      await downloadPath.create(recursive: true);
    }

    return downloadPath.path;
  }
}