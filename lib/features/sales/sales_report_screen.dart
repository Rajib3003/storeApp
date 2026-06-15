import 'package:flutter/material.dart';

import 'sales_service.dart';
import 'sale_model.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() =>
      _SalesReportScreenState();
}

class _SalesReportScreenState
    extends State<SalesReportScreen> {
  late Future<List<SaleModel>> salesFuture;

  @override
  void initState() {
    super.initState();
    salesFuture = SalesService.getSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Report"),
      ),
      body: FutureBuilder<List<SaleModel>>(
        future: salesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final sales = snapshot.data!;

          if (sales.isEmpty) {
            return const Center(
              child: Text("No Sales Found"),
            );
          }

          double grandTotal = 0;

          for (var sale in sales) {
            grandTotal += sale.total;
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade100,
                child: Text(
                  "Total Sales: ৳${grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(sale.name),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Qty: ${sale.qty}",
                            ),
                            Text(
                              "Price: ৳${sale.sellingPrice}",
                            ),
                            Text(
                              sale.date.toString(),
                            ),
                          ],
                        ),
                        trailing: Text(
                          "৳${sale.total.toStringAsFixed(2)}",
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
          );
        },
      ),
    );
  }
}