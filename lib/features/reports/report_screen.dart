import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'report_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ScrollController _controller = ScrollController();

  List<Map<String, dynamic>> rows = [];

  bool isPaginating = false;
  bool hasMore = true;

  DateTime? fromDate;
  DateTime? toDate;

  int offset = 0;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  // ================= DATE PICKERS =================

  Future<void> pickFromDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );

    setState(() {
      fromDate = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> pickToDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );

    setState(() {
      toDate = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 23,
        time?.minute ?? 59,
      );
    });
  }

  // ================= INITIAL LOAD =================

  Future<void> loadInitial() async {
    setState(() {
      rows.clear();
      offset = 0;
      hasMore = true;
    });

    await loadMore();
  }

  // ================= PAGINATION =================

  Future<void> loadMore() async {
    if (isPaginating || !hasMore) return;
    if (fromDate == null || toDate == null) return;

    setState(() => isPaginating = true);

    final data = await ReportRepository.getSaleItems(
      from: fromDate,
      to: toDate,
      offset: offset,
    );

    if (data.isEmpty || data.length < ReportRepository.pageSize) {
      hasMore = false;
    }

    offset += data.length;
    rows.addAll(data);

    setState(() => isPaginating = false);
  }

  // ================= HELPERS =================

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd MMM yyyy hh:mm a').format(dt);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final totalSales = rows.fold<double>(
      0,
      (s, r) => s + _toDouble(r['total']),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Sales Report")),

      body: Column(
        children: [
          // ================= DATE PICKERS =================
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pickFromDate,
                        child: Text(
                          fromDate == null
                              ? "Select From Date"
                              : "From: ${_fmt(fromDate)}",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pickToDate,
                        child: Text(
                          toDate == null
                              ? "Select To Date"
                              : "To: ${_fmt(toDate)}",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () async {
                    if (fromDate == null || toDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select From & To date"),
                        ),
                      );
                      return;
                    }

                    await loadInitial();
                  },
                  child: const Text("Generate Report"),
                ),
              ],
            ),
          ),

          // ================= EMPTY MESSAGE =================
          if (fromDate == null || toDate == null)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Please select date range",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          // ================= TOTAL =================
          if (rows.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Total Sales: ৳${totalSales.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),
            ),

          // ================= LIST =================
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: rows.length + 1,
              itemBuilder: (context, index) {
                if (index == rows.length) {
                  if (!isPaginating) return const SizedBox();

                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final r = rows[index];

                final qty = _toDouble(r['qty']);
                final sellPrice = _toDouble(r['sell_price']);
                final purchasePrice = _toDouble(r['purchase_price']);

                // ✅ REAL PROFIT CALCULATION
                final profit = (sellPrice - purchasePrice) * qty;
                final isLoss = profit < 0;
                

                return Card(
                  child: ListTile(
                    title: Text(r['product_name'] ?? 'Unknown'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Qty: $qty"),
                        Text("Barcode: ${r['barcode']}"),

                        Text(
                          isLoss
                              ? "Loss: ৳${profit.abs().toStringAsFixed(2)}"
                              : "Profit: ৳${profit.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: isLoss ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Date: ${_fmt(DateTime.tryParse(r['sale_date'] ?? ''))}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Text(
                      "৳${_toDouble(r['total']).toStringAsFixed(2)}",
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