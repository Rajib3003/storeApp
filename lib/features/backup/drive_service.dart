import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleAuthClient extends http.BaseClient {
  GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}

class DriveService {
  DriveService._();

  static drive.DriveApi? _api;
  static GoogleSignInAccount? _user;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );
  static String? _smartShopFolderId;
  static String? _databaseFolderId;
  static String? _photoFolderId;

  static Future<bool> initialize() async {
  if (_api != null) {
    return true;
  }

  try {
    _user = await _googleSignIn.signInSilently();
    _user ??= await _googleSignIn.signIn();

    if (_user == null) {
      return false;
    }

    final headers = await _user!.authHeaders;
    final client = GoogleAuthClient(headers);

    _api = drive.DriveApi(client);

    await _prepareFolders();

    return true;
  } catch (e) {
    print("Drive Init Error : $e");
    return false;
  }
}

  static Future<void> _prepareFolders() async {
    _smartShopFolderId = await _getOrCreateFolder('SmartShop', null);
    _databaseFolderId = await _getOrCreateFolder('Database', _smartShopFolderId);
    _photoFolderId = await _getOrCreateFolder('Photos', _smartShopFolderId);
  }

  static Future<String> _getOrCreateFolder(String name, String? parent) async {
    if (_api == null) {
      throw Exception('Drive not initialized');
    }

    var query =
        "mimeType='application/vnd.google-apps.folder' and name='$name' and trashed=false";
    if (parent != null) {
      query += " and '$parent' in parents";
    }

    final result = await _api!.files.list(q: query, spaces: 'drive');
    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    final folder = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder';
    if (parent != null) {
      folder.parents = [parent];
    }

    final created = await _api!.files.create(folder);
    return created.id!;
  }

  static Future<drive.File?> _findDatabaseFile() async {
    if (_api == null) {
      throw Exception('Drive not initialized');
    }

    final result = await _api!.files.list(
      q: "name='store.db' and '$_databaseFolderId' in parents and trashed=false",
      spaces: 'drive',
    );

    if (result.files == null || result.files!.isEmpty) {
      return null;
    }
    return result.files!.first;
  }

  static Future<void> _deleteOldDatabase() async {
    final oldFile = await _findDatabaseFile();
    if (oldFile == null) return;

    await _api!.files.delete(oldFile.id!);
  }

  static Future<void> uploadDatabase(File databaseFile) async {
    final ok = await initialize();
    if (!ok) {
      throw Exception('Google Drive login failed.');
    }

    await _deleteOldDatabase();
    final media = drive.Media(databaseFile.openRead(), databaseFile.lengthSync());
    final driveFile = drive.File()
      ..name = 'store.db'      
      ..parents = [_databaseFolderId!];

    await _api!.files.create(driveFile, uploadMedia: media);
    print('DATABASE BACKUP SUCCESS');
  }

  static Future<void> downloadDatabase(File destination) async {
    final ok = await initialize();
    if (!ok) {
      throw Exception('Google Drive login failed.');
    }

    final file = await _findDatabaseFile();
    if (file == null) {
      throw Exception('No backup found.');
    }

    final media = await _api!.files.get(
      file.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final sink = destination.openWrite();
    await media.stream.pipe(sink);
    await sink.flush();
    await sink.close();
    print('DATABASE RESTORE SUCCESS');
  }

  static Future<drive.File?> findPhoto(String fileName) async {
    final ok = await initialize();
    if (!ok) {
      throw Exception('Google Drive login failed.');
    }

    final result = await _api!.files.list(
      q: "name='$fileName' and '$_photoFolderId' in parents and trashed=false",
      spaces: 'drive',
    );

    if (result.files == null || result.files!.isEmpty) {
      return null;
    }
    return result.files!.first;
  }

  static Future<void> deletePhoto(String fileName) async {
    final file = await findPhoto(fileName);
    if (file == null) {
      return;
    }

    await _api!.files.delete(file.id!);
    print('PHOTO DELETED : $fileName');
  }

  static Future<String> uploadPhoto(File photo) async {
    final ok = await initialize();
    if (!ok) {
      throw Exception('Google Drive login failed.');
    }

    final fileName = photo.path.split('/').last;

    await deletePhoto(fileName);

    final media = drive.Media(
      photo.openRead(),
      photo.lengthSync(),
    );
    final driveFile = drive.File()
      ..name = fileName
      ..parents = [_photoFolderId!];

    await _api!.files.create(driveFile, uploadMedia: media);
    print('PHOTO UPLOADED : $fileName');
    return fileName;
  }

  static Future<bool> photoExists(String fileName) async {
    final file = await findPhoto(fileName);
    return file != null;
  }

  static Future<String> replacePhoto(File photo, String? oldFileName) async {
    if (oldFileName != null && oldFileName.isNotEmpty) {
      await deletePhoto(oldFileName);
    }
    return await uploadPhoto(photo);
  }

  static Future<File?> downloadPhoto(String fileName, Directory destination) async {
    final ok = await initialize();
    if (!ok) {
      throw Exception('Google Drive login failed.');
    }

    final driveFile = await findPhoto(fileName);
    if (driveFile == null) {
      return null;
    }

    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }
    final localFile = File('${destination.path}/$fileName');

    final media = await _api!.files.get(
      driveFile.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final sink = localFile.openWrite();
    await media.stream.pipe(sink);
    await sink.flush();
    await sink.close();
    return localFile;
  }

  static Future<void> backupAllPhotos(Directory photoDirectory) async {
    final ok = await initialize();
    if (!ok) {
      throw Exception('Google Drive login failed.');
    }

    if (!await photoDirectory.exists()) {
      return;
    }

    final files = photoDirectory.listSync();
    for (final item in files) {
      if (item is! File) {
        continue;
      }

      final fileName = item.path.split('/').last;

      final exists = await photoExists(fileName);
      if (!exists) {
        final media = drive.Media(item.openRead(), item.lengthSync());
        final driveFile = drive.File()
          ..name = fileName
          ..parents = [_photoFolderId!];

        await _api!.files.create(driveFile, uploadMedia: media);
      }
    }
  }

  static Future<void> restoreAllPhotos(Directory destination) async {
    final ok = await initialize();
    if (!ok) {
      throw Exception('Google Drive login failed.');
    }

    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    final result = await _api!.files.list(
      q: "'$_photoFolderId' in parents and trashed=false",
      spaces: 'drive',
    );
    final files = result.files ?? [];

    for (final driveFile in files) {
      if (driveFile.name == null) {
      continue;
    }

    final media = await _api!.files.get(
      driveFile.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final file = File('${destination.path}/${driveFile.name}');
      final sink = file.openWrite();
      await media.stream.pipe(sink);
      await sink.flush();
      await sink.close();
    }
  }
}
