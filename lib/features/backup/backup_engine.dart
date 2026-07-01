import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/network_service.dart';
import 'backup_service.dart';

class BackupEngine {
  BackupEngine._();

  static Timer? _timer;

  static bool _dirty = false;
  static bool _uploading = false;

  /// Database changed
static void markDirty() {
  print("MARK DIRTY CALLED");

  _dirty = true;

  _timer?.cancel();

  _timer = Timer(
    const Duration(seconds: 3),
    () async {
      print("3 SECOND TIMER FINISHED");
      await _backupIfNeeded();
    },
  );
}

  /// Backup if needed
static Future<void> _backupIfNeeded() async {

  print("BACKUP IF NEEDED");

  if (!_dirty) {
    print("NOT DIRTY");
    return;
  }

  if (_uploading) {
    print("ALREADY UPLOADING");
    return;
  }

  final hasInternet =
      await NetworkService.hasInternet();

  print("Internet = $hasInternet");

  if (!hasInternet) {
    return;
  }

  _uploading = true;

  try {

    print("CALLING BackupService");

    await BackupService.backupToDrive();

    print("BACKUP DONE");

    _dirty = false;

  } catch (e) {

    print(e);

  }

  _uploading = false;
}

  /// Manual backup
  static Future<void> backupNow() async {
    _timer?.cancel();

    _dirty = true;

    await _backupIfNeeded();
  }
}