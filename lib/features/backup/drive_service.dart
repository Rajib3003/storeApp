import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'google_auth_service.dart';

class DriveService {
  static drive.DriveApi? _driveApi;

  /// STEP 1: Authenticate & create Drive client
  static Future<void> initDrive(GoogleSignInAccount user) async {
    final headers = await user.authHeaders;

    final client = GoogleAuthClient(headers);

    _driveApi = drive.DriveApi(client);
  }

  /// STEP 2: Upload DB file
  static Future<void> uploadFile(File file) async {
    if (_driveApi == null) {
      throw Exception("Drive not initialized");
    }

    final media = drive.Media(file.openRead(), file.lengthSync());

    final driveFile = drive.File()
      ..name = "store.db"
      ..parents = ["appDataFolder"];

    await _driveApi!.files.create(
      driveFile,
      uploadMedia: media,
    );

    print("Backup uploaded successfully");
  }

  /// STEP 3: List backup files
  static Future<List<drive.File>> listFiles() async {
    if (_driveApi == null) return [];

    final result = await _driveApi!.files.list(
      spaces: "appDataFolder",
      $fields: "files(id, name, createdTime)",
    );

    return result.files ?? [];
  }

  /// STEP 4: Download latest backup
  static Future<File?> downloadLatest(String fileId, String savePath) async {
    if (_driveApi == null) return null;

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

/// Helper HTTP client for Google Auth
class GoogleAuthClient extends drive.BaseClient {
  final Map<String, String> _headers;
  final _client = HttpClient();

  GoogleAuthClient(this._headers);

  @override
  Future<drive.StreamedResponse> send(drive.BaseRequest request) {
    return _client
        .openUrl(request.method, request.url)
        .then((HttpClientRequest req) {
      request.headers.forEach((key, value) {
        req.headers.set(key, value);
      });

      _headers.forEach((key, value) {
        req.headers.set(key, value);
      });

      if (request.contentLength > 0) {
        return request.finalize().pipe(req);
      } else {
        req.close();
        return req.done;
      }
    }).then((HttpClientResponse response) {
      return drive.StreamedResponse(
        response.cast(),
        response.statusCode,
        contentLength: response.contentLength,
        request: request,
        headers: response.headers
            .map
            .map((k, v) => MapEntry(k, v.join(","))),
      );
    });
  }
}