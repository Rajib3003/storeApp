import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class DriveService {
  static drive.DriveApi? _api;
  static GoogleSignInAccount? _user;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
    ],
  );

  // ---------------- AUTO INIT ----------------
  static Future<bool> tryAutoInit() async {
    try {
      final user = await _googleSignIn.signInSilently();

      if (user == null) {
        print("Google user not found");
        return false;
      }

      _user = user;

      final headers = await user.authHeaders;
      final client = GoogleAuthClient(headers);

      _api = drive.DriveApi(client);

      print("Drive initialized");
      return true;
    } catch (e) {
      print("Drive init error: $e");
      return false;
    }
  }

  // ---------------- MANUAL INIT ----------------
  static Future<void> initDrive(GoogleSignInAccount user) async {
    final headers = await user.authHeaders;
    final client = GoogleAuthClient(headers);

    _api = drive.DriveApi(client);
    _user = user;
  }

  // ---------------- UPLOAD FILE ----------------
  static Future<void> uploadFile(File file) async {
    await tryAutoInit();

    if (_api == null) {
      throw Exception("Drive not initialized");
    }

    final media = drive.Media(
      file.openRead(),
      file.lengthSync(),
    );

    final driveFile = drive.File()
      ..name = "store.db"
      ..parents = ["appDataFolder"];

    await _api!.files.create(
      driveFile,
      uploadMedia: media,
    );
  }

  // ---------------- LIST FILES ----------------
  static Future<List<drive.File>> listFiles() async {
    await tryAutoInit();

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
  static Future<File> download(String fileId) async {
    await tryAutoInit();

    if (_api == null) {
      throw Exception("Drive not initialized");
    }

    final downloadDir = Directory("/storage/emulated/0/Download");

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final path =
        "${downloadDir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.db";

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

  // ---------------- DELETE FILE ----------------
  static Future<void> deleteFile(String fileId) async {
    await tryAutoInit();

    if (_api == null) {
      throw Exception("Drive not initialized");
    }

    await _api!.files.delete(fileId);
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