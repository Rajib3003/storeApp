import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteReader {

  static Future<List<String>> getTables(String dbPath) async {
    final db = await openDatabase(dbPath);

    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'"
    );

    return result.map((e) => e["name"].toString()).toList();
  }

  static Future<List<Map<String, dynamic>>> getTableData(
    String dbPath,
    String tableName,
  ) async {
    final db = await openDatabase(dbPath);

    return await db.query(tableName);
  }
}