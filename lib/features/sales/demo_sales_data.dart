import 'sales_service.dart';
import 'sale_model.dart';

void insertDateWiseDemoSales() {
  final now = DateTime.now();

  List<Map<String, dynamic>> demoData = [
    {"name": "Rice", "price": 120.0, "qty": 2, "daysAgo": 0},
    {"name": "Oil", "price": 180.0, "qty": 1, "daysAgo": 0},
    {"name": "Sugar", "price": 90.0, "qty": 3, "daysAgo": 1},
    {"name": "Milk", "price": 60.0, "qty": 5, "daysAgo": 2},
    {"name": "Bread", "price": 40.0, "qty": 4, "daysAgo": 3},
    {"name": "Egg", "price": 12.0, "qty": 12, "daysAgo": 5},
    {"name": "Tea", "price": 10.0, "qty": 20, "daysAgo": 7},
    {"name": "Fish", "price": 250.0, "qty": 2, "daysAgo": 10},
    {"name": "Chicken", "price": 220.0, "qty": 3, "daysAgo": 15},
    {"name": "Soap", "price": 50.0, "qty": 6, "daysAgo": 20},
  ];

  for (var item in demoData) {
    SalesService.addSale(
      SaleModel(
        barcode: "DEMO-${item['name']}",
        name: item['name'],
        qty: item['qty'],
        purchasePrice: (item['price'] as double) * 0.8,
        sellingPrice: item['price'],
        total: (item['price'] as double) * item['qty'],
        date: now.subtract(Duration(days: item['daysAgo'])),
      ),
    );
  }
}