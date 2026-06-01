class ProductModel {
  final int? id;
  final String name;
  final String barcode;
  final double purchasePrice;
  final double sellingPrice;
  final int stock;

  ProductModel({
    this.id,
    required this.name,
    required this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      barcode: map['barcode'],
      purchasePrice: map['purchase_price'],
      sellingPrice: map['selling_price'],
      stock: map['stock'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock': stock,
    };
  }
}