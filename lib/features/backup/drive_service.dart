import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DriveService {
  static drive.DriveApi? _api;

  // ---------------- INIT DRIVE ----------------
  static Future<void> initDrive(GoogleSignInAccount user) async {
    final headers = await user.authHeaders;
    final client = GoogleAuthClient(headers);
    _api = drive.DriveApi(client);
  }

  // ---------------- UPLOAD FILE ----------------
  static Future<void> uploadFile(File file) async {
    if (_api == null) return;

    final media = drive.Media(file.openRead(), file.lengthSync());

    final driveFile = drive.File()
      ..name = "store.db"
      ..parents = ["appDataFolder"];

    await _api!.files.create(driveFile, uploadMedia: media);
  }

  // ---------------- LIST FILES ----------------
  static Future<List<drive.File>> listFiles() async {
    if (_api == null) {
      print("Drive not initialized");
      return [];
    }

    final result = await _api!.files.list(
      spaces: "appDataFolder",
      $fields: "files(id,name,createdTime)",
    );

    return result.files ?? [];
  }

  // ---------------- DOWNLOAD FILE ----------------
//  static Future<File> download(String fileId) async {
static Future<File> download(String fileId) async {
  final dir = await getExternalStorageDirectory();

  // final downloadDir = Directory("${dir!.path}/Downloads");

  // if (!await downloadDir.exists()) {
  //   await downloadDir.create(recursive: true);
  // }

  // final path = "${downloadDir.path}/backup.db";

  final downloadDir = Directory("/storage/emulated/0/Download");

if (!await downloadDir.exists()) {
  await downloadDir.create(recursive: true);
}

final path = "${downloadDir.path}/backup.db";

  final file = File(path);

  final media = await _api!.files.get(
    fileId,
    downloadOptions: drive.DownloadOptions.fullMedia,
  ) as drive.Media;

  final sink = file.openWrite();

  await media.stream.pipe(sink);
  await sink.flush();
  await sink.close();

  print("Saved to: $path");

  return file;
}
}



 


class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}