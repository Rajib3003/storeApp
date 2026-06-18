import '../../db/db_helper.dart';
import '../cart/cart_item_model.dart';

class SalesService {
  /// Legacy single-row sale insert (kept for compatibility) - not recommended.
  static Future<void> addSale(Map<String, dynamic> saleData) async {
    final db = await DBHelper.db;
    await db.insert('sales', saleData);
  }

  /// Create a sale transactionally: one `sales` row + multiple `sale_items` rows.
  /// `productsByBarcode` maps barcode -> product DB row (must include `id`, `purchase_price`, `stock`).
  static Future<int> createSale(List<CartItem> items, Map<String, Map<String, dynamic>> productsByBarcode, double discount, {String paymentMethod = 'Cash'}) async {
    final db = await DBHelper.db;

    return await db.transaction<int>((txn) async {
      final subtotal = items.fold<double>(0, (s, it) => s + it.total);
      final grandTotal = subtotal - discount;

      final saleId = await txn.insert('sales', {
        'customer_id': null,
        'subtotal': subtotal,
        'discount': discount,
        'grand_total': grandTotal,
        'payment_method': paymentMethod,
        'created_at': DateTime.now().toIso8601String(),
      });

      for (var item in items) {
        final product = productsByBarcode[item.barcode];
        final purchasePrice = product?['purchase_price'] ?? 0;
        final productId = product?['id'];

        final total = item.total;
        final profit = (item.price - (purchasePrice is num ? purchasePrice.toDouble() : double.tryParse(purchasePrice.toString()) ?? 0)) * item.qty;

        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': productId,
          'qty': item.qty,
          'purchase_price': purchasePrice,
          'sell_price': item.price,
          'discount': 0,
          'total': total,
          'profit': profit,
        });

        // update product stock
        if (product != null) {
          final newStock = (product['stock'] ?? 0) - item.qty;
          await txn.update('products', {'stock': newStock}, where: 'barcode = ?', whereArgs: [item.barcode]);
        }
      }

      return saleId;
    });
  }

  /// NOTE: keep getSales minimal — higher-level reports should use `ReportRepository`.
  static Future<List<Map<String, dynamic>>> getSalesRaw() async {
    final db = await DBHelper.db;
    final result = await db.query('sales', orderBy: 'created_at DESC');
    return result;
  }
}