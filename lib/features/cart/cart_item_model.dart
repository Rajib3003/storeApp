class CartItem {
  final String barcode;
  final String name;

  double price; // 👈 editable (important for custom sell price)
  int qty;

  CartItem({
    required this.barcode,
    required this.name,
    required this.price,
    this.qty = 1,
  });

  // 💰 total calculation
  double get total => price * qty;

  // 📦 convert to DB / JSON map
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'price': price,
      'qty': qty,
      'total': total,
    };
  }

  // 🔁 copy with update (useful later for cart update)
  CartItem copyWith({
    String? barcode,
    String? name,
    double? price,
    int? qty,
  }) {
    return CartItem(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      price: price ?? this.price,
      qty: qty ?? this.qty,
    );
  }
}