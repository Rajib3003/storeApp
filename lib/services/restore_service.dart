import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../db/db_helper.dart';

class RestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= GENERIC RESTORE =================
  static Future<void> restoreTable(String tableName) async {
    final db = await DBHelper.db;

    final snapshot = await _firestore.collection(tableName).get();

    print("$tableName COUNT: ${snapshot.docs.length}");

    for (final doc in snapshot.docs) {
      await db.insert(
        tableName,
        Map<String, dynamic>.from(doc.data()),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
     final count = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $tableName"),
      );

      print("$tableName SQLITE COUNT: $count");
  }

  // ================= RESTORE ALL =================
  static Future<void> restoreAll() async {
    print("RESTORE STARTED");

    await restoreTable("categories");
    await restoreTable("brands");
    await restoreTable("colors");
    await restoreTable("sizes");

    await restoreTable("suppliers");
    await restoreTable("customers");

    await restoreTable("roles");
    await restoreTable("users");

    await restoreTable("settings");

    await restoreTable("products");

    await restoreTable("purchases");
    await restoreTable("purchase_items");

    await restoreTable("sales");
    await restoreTable("sale_items");

    await restoreTable("expense_categories");
    await restoreTable("expenses");

    await restoreTable("stock_history");

    await restoreTable("customer_payments");

    await restoreTable("backup_logs");

    print("RESTORE FINISHED");
  }
}