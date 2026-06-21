import 'package:sqflite/sqflite.dart';
import 'package:myapp/db/db_helper.dart';

class ReportRepository {
  static const int pageSize = 50;

  // =============================
  // PAGINATED + FILTERED DATA
  // =============================
  static Future<List<Map<String, dynamic>>> getSaleItems({
    DateTime? from,
    DateTime? to,
    int offset = 0,
  }) async {
    final db = await DBHelper.db;

    String where = '';
    List<dynamic> args = [];

    if (from != null && to != null) {
      where = 's.date BETWEEN ? AND ?';
      args = [
        from.toIso8601String(),
        to.toIso8601String(),
      ];
    }

    final result = await db.rawQuery('''
      SELECT 
        si.id,
        si.sale_id,
        si.product_id,
        si.qty,
        si.purchase_price,
        si.sell_price,
        si.total,
        si.profit,
        p.name as product_name,
        p.barcode,
        s.date as sale_date
      FROM sale_items si
      LEFT JOIN products p ON p.id = si.product_id
      LEFT JOIN sales s ON s.id = si.sale_id
      ${where.isNotEmpty ? 'WHERE $where' : ''}
      ORDER BY s.date DESC
      LIMIT $pageSize OFFSET $offset
    ''', args);

    return result;
  }
}