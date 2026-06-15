import 'package:flutter/material.dart';
import '../sales/sales_service.dart';
import '../sales/sale_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<SaleModel> sales = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    try {
        final data = await SalesService.getSales();

        setState(() {
        sales = data;
        isLoading = false;
        });
    } catch (e) {
        setState(() {
        sales = [];
        isLoading = false;
        });

        debugPrint("Error loading sales: $e");
    }
    }

  double get totalAmount {
    return sales.fold(0, (sum, item) => sum + item.total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sales Report")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Total Sales: ৳${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  child: sales.isEmpty
                      ? const Center(child: Text("No sales data found"))
                      : ListView.builder(
                          itemCount: sales.length,
                          itemBuilder: (context, index) {
                            final sale = sales[index];

                            return ListTile(
                              leading: const Icon(Icons.point_of_sale),
                              title: Text(sale.name),
                              subtitle: Text(sale.createdAt),
                              trailing: Text(
                                "৳${sale.total}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
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