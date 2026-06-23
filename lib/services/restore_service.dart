import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../db/db_helper.dart';

class RestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= PRODUCTS =================
  static Future<void> restoreProducts() async {
    final db = await DBHelper.db;

    final snapshot = await _firestore.collection("products").get();
     print("PRODUCTS COUNT: ${snapshot.docs.length}");
    for (var doc in snapshot.docs) {
      await db.insert(
        'products',
        Map<String, dynamic>.from(doc.data()),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // ================= SALES =================
  static Future<void> restoreSales() async {
    final db = await DBHelper.db;

    final snapshot = await _firestore.collection("sales").get();
print("SALES COUNT: ${snapshot.docs.length}"); 
    for (var doc in snapshot.docs) {
      await db.insert(
        'sales',
        Map<String, dynamic>.from(doc.data()),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // ================= CUSTOMERS =================
  static Future<void> restoreCustomers() async {
    final db = await DBHelper.db;

    final snapshot = await _firestore.collection("customers").get();
print("CUSTOMERS COUNT: ${snapshot.docs.length}");
    for (var doc in snapshot.docs) {
      await db.insert(
        'customers',
        Map<String, dynamic>.from(doc.data()),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // ================= EXPENSES =================
  static Future<void> restoreExpenses() async {
    final db = await DBHelper.db;

    final snapshot = await _firestore.collection("expenses").get();
print("EXPENSES COUNT: ${snapshot.docs.length}");
    for (var doc in snapshot.docs) {
      await db.insert(
        'expenses',
        Map<String, dynamic>.from(doc.data()),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<void> restoreAll() async {
    print("RESTORE STARTED"); 
    await restoreProducts();
    await restoreSales();
    await restoreCustomers();
    await restoreExpenses();
    print("RESTORE FINISHED");
  }
}