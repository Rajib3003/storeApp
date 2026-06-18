import 'package:sqflite/sqflite.dart';
import 'package:myapp/db/db_helper.dart';

class ReportRepository {
  // ---------------- FIND CORRECT COLUMN ----------------
  static Future<String?> _salesTimestampColumn(Database db) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info(sales)');

    final columns = tableInfo
        .map((row) => row['name']?.toString())
        .whereType<String>()
        .toList();

    // normalize check
    if (columns.contains('created_at')) return 'created_at';
    if (columns.contains('createdAt')) return 'createdAt';
    if (columns.contains('date')) return 'date';
    if (columns.contains('sale_date')) return 'sale_date';

    return null; // ❗ important
  }

  // ---------------- MAIN QUERY ----------------
  static Future<List<Map<String, dynamic>>> getSaleItems() async {
    final db = await DBHelper.db;

    final timestampColumn = await _salesTimestampColumn(db);

    if (timestampColumn == null) {
      print("⚠️ No timestamp column found in sales table");

      return getLegacySales();
    }

    final result = await db.rawQuery('''
      SELECT si.id as sale_item_id,
             si.sale_id,
             s.$timestampColumn as sale_date,
             si.product_id,
             p.name as product_name,
             p.barcode as barcode,
             si.qty,
             si.purchase_price,
             si.sell_price,
             si.discount,
             si.total,
             si.profit
      FROM sale_items si
      LEFT JOIN sales s ON s.id = si.sale_id
      LEFT JOIN products p ON p.id = si.product_id
      ORDER BY s.$timestampColumn DESC
    ''');

    return result;
  }

  // ---------------- LEGACY FALLBACK ----------------
  static Future<List<Map<String, dynamic>>> getLegacySales() async {
    final db = await DBHelper.db;

    final rows = await db.query('sales');

    return rows.map((r) {
      return {
        'sale_item_id': r['id'],
        'sale_id': r['id'],
        'sale_date': r['created_at'] ?? r['date'] ?? '',
        'product_name': r['barcode'] ?? r['name'] ?? 'Unknown',
        'barcode': r['barcode'] ?? '',
        'qty': r['qty'] ?? 1,
        'purchase_price': r['purchase_price'] ?? 0,
        'sell_price': r['sell_price'] ?? 0,
        'discount': r['discount'] ?? 0,
        'total': r['total'] ?? 0,
        'profit': r['profit'] ?? 0,
      };
    }).toList();
  }
}