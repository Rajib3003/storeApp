import 'package:flutter/foundation.dart';
import '../../db/db_helper.dart';
import '../cart/cart_item_model.dart';

class SalesService {
  static Future<Set<String>> _getSalesColumns() async {
    final db = await DBHelper.db;
    final tableInfo = await db.rawQuery('PRAGMA table_info(sales)');

    return tableInfo
        .map((row) => row['name']?.toString().toLowerCase())
        .whereType<String>()
        .toSet();
  }

  static Future<int> createSale(
    List<CartItem> items,
    Map<String, Map<String, dynamic>> productsByBarcode,
    double discount, {
    String paymentMethod = 'Cash',
  }) async {
    final db = await DBHelper.db;
    final salesColumns = await _getSalesColumns();

    return await db.transaction<int>((txn) async {
      
      final subtotal = items.fold<double>(0, (s, it) => s + it.total);

      // 🔥 FIXED LOGIC
      final grandTotal = subtotal;        // original total
      final payable = subtotal - discount; // customer pays

      final now = DateTime.now().toIso8601String();

      /// =========================
      /// SALES HEADER
      /// =========================
      final saleData = <String, dynamic>{};

      if (salesColumns.contains('customer_id')) {
        saleData['customer_id'] = null;
      }

      if (salesColumns.contains('discount')) {
        saleData['discount'] = discount;
      }

      if (salesColumns.contains('grand_total')) {
        saleData['grand_total'] = grandTotal;
      }

      if (salesColumns.contains('total')) {
        saleData['total'] = grandTotal;
      }

      if (salesColumns.contains('date')) {
        saleData['date'] = now;
      }

      if (salesColumns.contains('created_at')) {
        saleData['created_at'] = now;
      }

      final saleId = await txn.insert('sales', saleData);

      /// =========================
      /// SALES ITEMS + STOCK UPDATE
      /// =========================
      for (var item in items) {
        final product = productsByBarcode[item.barcode];

        final purchasePrice = product?['purchase_price'] ?? 0;
        final productId = product?['id'];

        final originalPrice = item.price;

        // 🔥 discount per item distribute (simple logic)
        // final itemDiscount = discount / items.length;
        // final itemDiscount = (originalPrice / subtotal) * discount;
        final itemDiscount = double.parse((((originalPrice / subtotal) * discount).toStringAsFixed(2)));

        final sellPriceAfterDiscount = originalPrice - itemDiscount;

        

        final total = sellPriceAfterDiscount * item.qty;

        final purchase = purchasePrice is num
            ? purchasePrice.toDouble()
            : double.tryParse(purchasePrice.toString()) ?? 0;

        final profit = (sellPriceAfterDiscount - purchase) * item.qty;

        /// insert sale item (SAFE)
        try {
          await txn.insert('sale_items', {
            'sale_id': saleId,
            'product_id': productId,
            'barcode': item.barcode,
            'qty': item.qty,
            'purchase_price': purchase,
            'sell_price': sellPriceAfterDiscount,
            'discount': itemDiscount,
            'total': total,
            'profit': profit,
            'created_at': now,
            'sync_status': 0,
          });
        } catch (e) {
          debugPrint("sale_items insert failed: $e");
        }

        /// stock update (ALWAYS RUN)
        if (product != null) {
          final newStock = (product['stock'] ?? 0) - item.qty;

          await txn.update(
            'products',
             {
                'stock': newStock,
                'sync_status': 0,
                'updated_at': DateTime.now().toIso8601String(),
              },
            where: 'barcode = ?',
            whereArgs: [item.barcode],
          );
        }
      }

      return saleId;
    });
  }

  static Future<List<Map<String, dynamic>>> getSalesRaw() async {
    final db = await DBHelper.db;
    return await db.query('sales', orderBy: 'id DESC');
  }
}