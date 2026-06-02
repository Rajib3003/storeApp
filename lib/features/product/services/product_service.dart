import '../../../core/db/db_helper.dart';

class ProductService {

  static Future<List<Map<String, dynamic>>> getProducts({
    required int limit,
    required int offset,
    String? search,
  }) async {
    final db = await DBHelper.db;

    if (search != null && search.isNotEmpty) {
      return await db.query(
        'products',
        where: 'name LIKE ? OR barcode LIKE ?',
        whereArgs: ['%$search%', '%$search%'],
        orderBy: 'id DESC',
        limit: limit,
        offset: offset,
      );
    }

    return await db.query(
      'products',
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
  }

  static Future<int> insertProduct(Map<String, dynamic> data) async {
    final db = await DBHelper.db;
    return await db.insert('products', data);
  }

  // ✅ ADD THIS: GET BY BARCODE
  static Future<Map<String, dynamic>?> getByBarcode(String barcode) async {
    final db = await DBHelper.db;

    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // ✅ ADD THIS: UPDATE STOCK
  static Future<int> updateStock({
    required String barcode,
    required int newStock,
  }) async {
    final db = await DBHelper.db;

    return await db.update(
      'products',
      {'stock': newStock},
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
  }
}