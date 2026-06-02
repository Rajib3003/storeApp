class SaleModel {
  final String barcode;
  final String name;
  final int qty;
  final double purchasePrice;
  final double sellingPrice;
  final double total;
  final DateTime date;

  SaleModel({
    required this.barcode,
    required this.name,
    required this.qty,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'qty': qty,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'total': total,
      'date': date.toIso8601String(),
    };
  }
}