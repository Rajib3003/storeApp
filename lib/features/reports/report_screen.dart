import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:myapp/features/reports/report_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<Map<String, dynamic>>> _futureRows;

  @override
  void initState() {
    super.initState();
    _futureRows = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
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
      return value?.toString() ?? '';
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
        future: _futureRows,
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
              rows.fold<double>(0, (s, r) => s + _toDouble(r['total']));

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

                    // ✅ FIX HERE
                    final profitValue = _toDouble(r['profit']);
                    final isLoss = profitValue < 0;

                    final date =
                        _fmtDate(r['sale_date'] ?? r['created_at']);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.point_of_sale),
                        title: Text(name.toString()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Barcode: ${r['barcode'] ?? ''}'),
                            Text(
                              'Qty: ${qty.toInt()}  •  Price: ৳${sell.toStringAsFixed(2)}',
                            ),

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