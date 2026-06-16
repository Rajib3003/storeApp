import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class DriveService {
  static drive.DriveApi? _api;

  static Future<void> initDrive(GoogleSignInAccount user) async {
    final headers = await user.authHeaders;
    final client = GoogleAuthClient(headers);
    _api = drive.DriveApi(client);
  }

  static Future<void> uploadFile(File file) async {
    if (_api == null) return;

    const fileName = "store.db";

    final media = drive.Media(file.openRead(), file.lengthSync());

    final driveFile = drive.File()
      ..name = fileName
      ..parents = ["appDataFolder"];

    await _api!.files.create(driveFile, uploadMedia: media);
  }

  static Future<List<drive.File>> listFiles() async {
    final res = await _api!.files.list(
      spaces: "appDataFolder",
      orderBy: "createdTime desc",
      $fields: "files(id,name,createdTime)",
    );
    return res.files ?? [];
  }

  static Future<File?> download(String id, String path) async {
    final media = await _api!.files.get(
      id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final file = File(path);
    final sink = file.openWrite();

    await media.stream.pipe(sink);
    await sink.close();

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