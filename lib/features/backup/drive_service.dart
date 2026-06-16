import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class DriveService {
  static drive.DriveApi? _driveApi;

  static Future<void> initDrive(GoogleSignInAccount user) async {
    final headers = await user.authHeaders;
    final client = GoogleAuthClient(headers);

    _driveApi = drive.DriveApi(client);
  }

  /// UPLOAD (REPLACE OLD FILE)
  static Future<void> uploadFile(File file) async {
    if (_driveApi == null) throw Exception("Drive not initialized");

    final media = drive.Media(file.openRead(), file.lengthSync());

    final driveFile = drive.File()
      ..name = "store.db"
      ..parents = ["appDataFolder"];

    await _driveApi!.files.create(
      driveFile,
      uploadMedia: media,
    );
  }

  /// LIST FILES
  static Future<List<drive.File>> listFiles() async {
    final res = await _driveApi!.files.list(
      spaces: "appDataFolder",
      $fields: "files(id,name,createdTime)",
    );

    return res.files ?? [];
  }

  /// DOWNLOAD
  static Future<File?> download(
    String fileId,
    String savePath,
  ) async {
    final media = await _driveApi!.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final file = File(savePath);
    final sink = file.openWrite();

    await media.stream.pipe(sink);
    await sink.close();

    return file;
  }
}

/// HTTP CLIENT
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