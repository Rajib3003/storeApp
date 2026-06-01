import '../../../core/db/db_helper.dart';

class ProductService {

  static Future<int> insertProduct(Map<String, dynamic> data) async {
    final db = await DBHelper.db;
    return await db.insert('products', data);
  }

  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await DBHelper.db;
    return await db.query('products');
  }

  static Future<Map<String, dynamic>?> getByBarcode(String barcode) async {
    final db = await DBHelper.db;

    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    return result.isNotEmpty ? result.first : null;
  }

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