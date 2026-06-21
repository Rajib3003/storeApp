import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:myapp/features/reports/report_repository.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  late Future<List<Map<String, dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<List<Map<String, dynamic>>> _loadData() async {
    final items = await ReportRepository.getSaleItems();
    if (items.isNotEmpty) return items;
    return await ReportRepository.getLegacySales();
  }

  String _fmtDate(dynamic value) {
    try {
      if (value == null) return '';
      final dt = DateTime.parse(value.toString());
      return DateFormat('dd MMM yyyy - hh:mm a').format(dt);
    } catch (_) {
      return value.toString();
    }
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Report')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rows = snapshot.data ?? [];

          if (rows.isEmpty) {
            return const Center(child: Text('No sales data found'));
          }

          final grandTotal =
              rows.fold<double>(0, (sum, r) => sum + _toDouble(r['total']));

          return Column(
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
                  'Total Sales: ৳${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final r = rows[index];

                    final name =
                        r['product_name'] ?? r['barcode'] ?? 'Unknown';

                    final qty = _toDouble(r['qty']);

                    final sell =
                        _toDouble(r['sell_price'] ?? r['selling_price']);

                    final total = _toDouble(r['total']);

                    final profitValue = _toDouble(r['profit']); // 🔥 FIX HERE

                    final date =
                        _fmtDate(r['sale_date'] ?? r['created_at']);

                    final isLoss = profitValue < 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(name.toString()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Barcode: ${r['barcode'] ?? ''}'),
                            Text(
                              'Qty: ${qty.toInt()}  •  Price: ৳${sell.toStringAsFixed(2)}',
                            ),

                            // 🔥 PROFIT / LOSS SECTION FIXED
                            Text(
                              isLoss
                                  ? 'Loss: ৳${profitValue.abs().toStringAsFixed(2)}'
                                  : 'Profit: ৳${profitValue.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isLoss ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(date),
                          ],
                        ),
                        trailing: Text(
                          '৳${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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