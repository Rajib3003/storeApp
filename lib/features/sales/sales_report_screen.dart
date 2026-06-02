import 'package:flutter/material.dart';
import 'sales_service.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;

  List getFilteredSales() {
    final sales = SalesService.getAllSales();

    if (fromDate == null || toDate == null) {
      return sales;
    }

    return sales.where((item) {
      final d = item.date;
      return d.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
             d.isBefore(toDate!.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> pickFromDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => fromDate = picked);
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
      setState(() => toDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sales = getFilteredSales();

    return Scaffold(
      appBar: AppBar(title: const Text("Sales Report (Date Range)")),

      body: Column(
        children: [

          // 🔥 DATE FILTER SECTION
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
                  onPressed: () => setState(() {}),
                  child: const Text("Apply Filter"),
                ),
              ],
            ),
          ),

          // 🔥 TOTAL
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
             "Total Sales: ৳${sales.fold(0.0, (a, b) => a + b.total).toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 🔥 LIST
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
                            "Qty: ${item.qty} | Price: ৳${item.sellingPrice.toStringAsFixed(2)}",
                          ),
                          trailing: Text(
                            "৳${item.total.toStringAsFixed(2)}",
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