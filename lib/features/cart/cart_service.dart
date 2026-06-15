import 'cart_item_model.dart';
import 'package:flutter/foundation.dart';

class CartService {
  static List<CartItem> cart = [];

  // 🔥 NOTIFIER (IMPORTANT)
  static ValueNotifier<int> cartCount = ValueNotifier(0);

  static void _updateCount() {
    cartCount.value = cart.length;
  }

  // ➕ ADD
  static void addItem(CartItem item) {
    final index = cart.indexWhere((e) => e.barcode == item.barcode);

    if (index >= 0) {
      cart[index].qty += item.qty;
    } else {
      cart.add(item);
    }

   _updateCount();
  }

  // ➖ DECREASE
  static void decreaseQty(String barcode) {
    final index = cart.indexWhere((e) => e.barcode == barcode);

    if (index >= 0) {
      cart[index].qty--;

      if (cart[index].qty <= 0) {
        cart.removeAt(index);
      }
    }

    _updateCount();
  }

  // ❌ REMOVE
  static void removeItem(String barcode) {
    cart.removeWhere((e) => e.barcode == barcode);
    _updateCount();
  }

  // 🧹 CLEAR
  static void clear() {
    cart.clear();
    _updateCount();
  }

  static List<CartItem> get items => cart;

  static double get total =>
      cart.fold(0, (sum, item) => sum + item.total);
}