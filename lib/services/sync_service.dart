// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../db/db_helper.dart';

// class SyncService {
//   // static final FirebaseFirestore _firestore =
//   //     FirebaseFirestore.instance;

//   // ================= GENERIC TABLE SYNC =================
//   static Future<void> syncTable(String tableName) async {
//     final db = await DBHelper.db;

//     final rows = await db.query(
//       tableName,
//       where: 'sync_status = ?',
//       whereArgs: [0],
//     );

//     for (final row in rows) {
//       await _firestore
//           .collection(tableName)
//           .doc(row['id'].toString())
//           .set(row);

//       await db.update(
//         tableName,
//         {
//           'sync_status': 1,
//           'synced_at': DateTime.now().toIso8601String(),
//         },
//         where: 'id = ?',
//         whereArgs: [row['id']],
//       );
//     }
//   }

//   // ================= SYNC ALL TABLES =================
//   static Future<void> syncAll() async {
//     await syncTable("categories");
//     await syncTable("brands");
//     await syncTable("colors");
//     await syncTable("sizes");

//     await syncTable("suppliers");
//     await syncTable("customers");

//     await syncTable("users");
//     await syncTable("roles");

//     await syncTable("settings");

//     await syncTable("products");

//     await syncTable("purchases");
//     await syncTable("purchase_items");

//     await syncTable("sales");
//     await syncTable("sale_items");

//     await syncTable("expense_categories");
//     await syncTable("expenses");

//     await syncTable("stock_history");

//     await syncTable("customer_payments");

//     await syncTable("backup_logs");
//   }
// }