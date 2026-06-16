import 'package:shared_preferences/shared_preferences.dart';

class BackupReminder {
  static const String _key = "last_backup_date";

  static Future<bool> shouldShowBackupDialog() async {
    final prefs = await SharedPreferences.getInstance();

    final last = prefs.getString(_key);

    if (last == null) return true;

    final lastDate = DateTime.parse(last);

    // return DateTime.now().difference(lastDate).inDays >= 3;
    return DateTime.now().difference(lastDate).inMinutes >= 5;
  }

  static Future<void> saveBackupDate() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      DateTime.now().toIso8601String(),
    );
  }
}