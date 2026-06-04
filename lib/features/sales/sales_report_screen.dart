import 'package:flutter/material.dart';
import 'sales_service.dart';
import 'demo_sales_data.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;

  List allSales = [];
  List filteredSales = [];

  @override
  void initState() {
    super.initState();
    insertDateWiseDemoSales();
    _loadSales();
  }

  // 🚀 LOAD DATA ONCE (FAST)
  Future<void> _loadSales() async {
    allSales = SalesService.getAllSales();

    filteredSales = allSales;
    setState(() {});
  }

  // 🚀 FILTER
  void _applyFilter() {
    if (fromDate == null || toDate == null) {
      filteredSales = allSales;
    } else {
      final start = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
      final end = DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59);

      filteredSales = allSales.where((item) {
        return item.date.isAfter(start) && item.date.isBefore(end);
      }).toList();
    }

    setState(() {});
  }

  Future<void> pickFromDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      fromDate = picked;
      _applyFilter();
    }
  }

  Future<void> pickToDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      toDate = picked;
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sales = filteredSales;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Report"),
      ),

      body: Column(
        children: [

          // 📅 FILTER SECTION
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pickFromDate,
                        child: Text(
                          fromDate == null
                              ? "From Date"
                              : fromDate.toString().split(" ")[0],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pickToDate,
                        child: Text(
                          toDate == null
                              ? "To Date"
                              : toDate.toString().split(" ")[0],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: _applyFilter,
                  child: const Text("Apply Filter"),
                ),
              ],
            ),
          ),

          // 💰 TOTAL SALES
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Total Sales: ৳${sales.fold<double>(0.0, (a, b) => a + b.total).toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 📦 LIST
          Expanded(
            child: sales.isEmpty
                ? const Center(child: Text("No Data Found"))
                : ListView.builder(
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final item = sales[index];

                      return Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            "Qty: ${item.qty} | Price: ৳${item.sellingPrice}",
                          ),
                          trailing: Text(
                            "৳${item.total}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}