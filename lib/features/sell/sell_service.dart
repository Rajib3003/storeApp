import 'package:myapp/db/db_helper.dart';
import '../backup/backup_engine.dart';

class SellService {

  static Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await DBHelper.db;

    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  static Future<void> updateStock(String barcode, int newStock) async {
    final db = await DBHelper.db;

    await db.update(
      'products',
      {'stock': newStock},
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    BackupEngine.markDirty();
  }

  static Future<void> insertSale({
    required String barcode,
    required int qty,
    required double sellPrice,
  }) async {
    final db = await DBHelper.db;

    await db.insert('sales', {
      'barcode': barcode,
      'qty': qty,
      'sell_price': sellPrice,
      'total': qty * sellPrice,
      'date': DateTime.now().toString(),
    });

    BackupEngine.markDirty();
  }
}