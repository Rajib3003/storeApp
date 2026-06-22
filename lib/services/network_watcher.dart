import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import '../main.dart';
import 'sync_service.dart';

class NetworkWatcher {
  static bool _isSyncing = false;

  static void startListening() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) return;

      if (!firebaseReady) return;
      if (Firebase.apps.isEmpty) return;

      if (_isSyncing) return; // prevent duplicate sync

      try {
        _isSyncing = true;
        await SyncService.syncAll();
      } catch (e) {
        print("Sync error: $e");
      } finally {
        _isSyncing = false;
      }
    });
  }
}