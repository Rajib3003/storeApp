import 'package:connectivity_plus/connectivity_plus.dart';

import '../features/backup/backup_engine.dart';

class NetworkWatcher {
  static bool _isSyncing = false;

  static void startListening() {
    Connectivity().onConnectivityChanged.listen((results) async {
      // No internet
      if (results.contains(ConnectivityResult.none)) {
        return;
      }

      // Prevent multiple backup calls
      if (_isSyncing) {
        return;
      }

      try {
        _isSyncing = true;

        // Internet available -> run pending backup
        await BackupEngine.backupNow();
      } catch (e) {
        print('NetworkWatcher Backup Error: $e');
      } finally {
        _isSyncing = false;
      }
    });
  }
}

