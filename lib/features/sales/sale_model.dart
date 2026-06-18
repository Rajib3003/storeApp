class SaleModel {
  final String barcode;
  final String name;
  final int qty;
  final double purchasePrice;
  final double sellingPrice;
  final double total;
  final DateTime date;
  final String createdAt;

  SaleModel({
    required this.barcode,
    required this.name,
    required this.qty,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.total,
    required this.date,
    required this.createdAt,
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

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      barcode: map['barcode'],
      name: map['name'],
      qty: map['qty'],
      purchasePrice: map['purchase_price'],
      sellingPrice: map['selling_price'],
      total: map['total'],
      date: map['date'] != null ? DateTime.parse(map['date']) : (map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now()),
      createdAt: map['createdAt'] ?? map['created_at'] ?? '',
    );
  }
}