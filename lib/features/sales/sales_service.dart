import 'sale_model.dart';

class SalesService {
  static List<SaleModel> sales = [];

  static void addSale(SaleModel sale) {
    sales.add(sale);
  }

  static List<SaleModel> getAllSales() {
    return sales;
  }

  static double get totalSales =>
      sales.fold(0, (sum, item) => sum + item.total);

  static int get totalItems =>
      sales.fold(0, (sum, item) => sum + item.qty);
}