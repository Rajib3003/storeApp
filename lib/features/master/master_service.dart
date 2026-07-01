import 'package:myapp/db/db_helper.dart';
import 'package:myapp/features/backup/backup_engine.dart';

class MasterService {
  static Future<List<String>> getTables() async {
    final db = await DBHelper.db;

    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );

    return result.map((e) => e['name'].toString()).toList();
  }

  static Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String orderBy = 'id DESC',
  }) async {
    final db = await DBHelper.db;

    return await db.query(
      table,
      orderBy: orderBy,
    );
  }

  // ================= INSERT =================

  static Future<int> insert(
    String table,
    Map<String, dynamic> values,
  ) async {
    final dbClient = await DBHelper.db;

    final payload = Map<String, dynamic>.from(values);

    if (table == "settings" &&
        !payload.containsKey("id")) {
      payload["id"] = 1;
    }

    final id = await dbClient.insert(
      table,
      payload,
    );

    if (table == "products") {
      final barcode =
          "SMARTSHOP${id.toString().padLeft(6, "0")}";

      await dbClient.update(
        "products",
        {
          "barcode": barcode,
        },
        where: "id=?",
        whereArgs: [id],
      );
    }

    // AUTO BACKUP
    BackupEngine.markDirty();

    return id;
  }

  // ================= TABLE INFO =================

  static Future<List<Map<String, dynamic>>> getTableColumns(
    String table,
  ) async {
    final db = await DBHelper.db;

    return await db.rawQuery(
      "PRAGMA table_info('$table')",
    );
  }

  // ================= UPDATE =================

  static Future<int> update(
    String table,
    int id,
    Map<String, dynamic> values,
  ) async {
    final db = await DBHelper.db;

    final result = await db.update(
      table,
      values,
      where: "id=?",
      whereArgs: [id],
    );

    BackupEngine.markDirty();

    return result;
  }

  // ================= DELETE =================

  static Future<int> delete(
    String table,
    int id,
  ) async {
    final db = await DBHelper.db;

    final result = await db.delete(
      table,
      where: "id=?",
      whereArgs: [id],
    );

    BackupEngine.markDirty();

    return result;
  }

  // ================= SETTINGS =================

  static Future<Map<String, dynamic>?> getSettings() async {
    final rows = await getAll(
      "settings",
      orderBy: "id ASC",
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  static Future<int> saveSettings(
    Map<String, dynamic> values,
  ) async {
    final current = await getSettings();

    if (current == null) {
      final payload = Map<String, dynamic>.from(values);

      payload["id"] = 1;

      return await insert(
        "settings",
        payload,
      );
    }

    return await update(
      "settings",
      current["id"],
      values,
    );
  }

  // ================= BACKUP LOG =================

  static Future<int> addBackupLog(
    String fileName,
    String driveFileId,
    String status,
  ) async {
    return await insert(
      "backup_logs",
      {
        "file_name": fileName,
        "google_drive_file_id": driveFileId,
        "backup_date":
            DateTime.now().toIso8601String(),
        "status": status,
      },
    );
  }
}