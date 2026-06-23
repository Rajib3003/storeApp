import 'package:cloud_firestore/cloud_firestore.dart';
import '../db/db_helper.dart';

class SyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= SALES =================
  static Future<void> syncSales() async {
    final db = await DBHelper.db;

    final rows = await db.query(
      'sales',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    for (final row in rows) {
      await _firestore.collection("sales")
          .doc(row['id'].toString())
          .set(row);

      await db.update(
        'sales',
        {'sync_status': 1},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  // ================= PRODUCTS =================
  static Future<void> syncProducts() async {
    final db = await DBHelper.db;

    final rows = await db.query(
      'products',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    for (final row in rows) {
      await _firestore.collection("products")
          .doc(row['id'].toString())
          .set(row);

      await db.update(
        'products',
        {'sync_status': 1},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  // ================= CUSTOMERS =================
  static Future<void> syncCustomers() async {
    final db = await DBHelper.db;

    final rows = await db.query(
      'customers',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    for (final row in rows) {
      await _firestore.collection("customers")
          .doc(row['id'].toString())
          .set(row);

      await db.update(
        'customers',
        {'sync_status': 1},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  // ================= EXPENSES =================
  static Future<void> syncExpenses() async {
    final db = await DBHelper.db;

    final rows = await db.query(
      'expenses',
      where: 'sync_status = ?',
      whereArgs: [0],
    );

    for (final row in rows) {
      await _firestore.collection("expenses")
          .doc(row['id'].toString())
          .set(row);

      await db.update(
        'expenses',
        {'sync_status': 1},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  // ================= MASTER =================
  static Future<void> syncAll() async {
    await syncSales();
    await syncProducts();
    await syncCustomers();
    await syncExpenses();

    final db = await DBHelper.db;

    await db.insert('backup_logs', {
      'file_name': 'auto_sync',
      'backup_date': DateTime.now().toString(),
      'status': 'success',
    });
  }
}