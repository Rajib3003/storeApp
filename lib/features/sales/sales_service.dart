import '../../db/db_helper.dart';
import 'sale_model.dart';

class SalesService {
  static Future<void> addSale(SaleModel sale) async {
    final db = await DBHelper.db;

    await db.insert('sales', sale.toMap());
  }

  static Future<List<SaleModel>> getSales() async {
    final db = await DBHelper.db;

    final result = await db.query(
      'sales',
      orderBy: 'createdAt DESC',
    );

    return result.map((e) => SaleModel.fromMap(e)).toList();
  }
}