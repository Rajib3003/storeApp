import 'dart:async';

import '../network/network_service.dart';

import 'backup_service.dart';

class BackupEngine {
  BackupEngine._();

  static Timer? _timer;

  static bool _dirty = false;

  static bool _uploading = false;

  // ==========================
  // Database Changed
  // ==========================

  static void markDirty() {
    _dirty = true;

    _timer?.cancel();

    _timer = Timer(
      const Duration(seconds: 3),
      () async {
        await _backupIfNeeded();
      },
    );
  }

  // ==========================
  // Backup
  // ==========================

  static Future<void> _backupIfNeeded() async {
    if (!_dirty) {
      return;
    }

    if (_uploading) {
      return;
    }

    final hasInternet =
        await NetworkService.hasInternet();

    if (!hasInternet) {
      return;
    }

    _uploading = true;

    try {
      await BackupService.backupToDrive();

      _dirty = false;
    } catch (e) {
      print("AUTO BACKUP ERROR : $e");
    }

    _uploading = false;
  }

  // ==========================
  // Force Backup
  // ==========================

  static Future<void> backupNow() async {
    _timer?.cancel();

    _dirty = true;

    await _backupIfNeeded();
  }
}