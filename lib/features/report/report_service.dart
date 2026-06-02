class ReportService {

  static Future<double> getTotalSales() async {
    final db = await DBHelper.db;

    final result = await db.rawQuery(
      "SELECT SUM(total) as total FROM sales"
    );

    return result.first["total"] ?? 0.0;
  }
}