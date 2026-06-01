import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'util/utils.dart';
import 'main.dart';

class ResultScreen extends StatefulWidget {
  final String data;

  const ResultScreen({super.key, required this.data});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Map<String, dynamic>? product;

  final TextEditingController qtyController =
      TextEditingController(text: "1");

  final TextEditingController sellPriceController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  void loadProduct() async {
    final db = await DBHelper.db;

    final result = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [widget.data],
    );

    if (result.isNotEmpty) {
      setState(() {
        product = result.first;
        sellPriceController.text =
            product!['selling_price'].toString();
      });
    }
  }

  void confirmSell() {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Confirm Sell"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              sellProduct();
            },
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
}

  void sellProduct() async {
  final db = await DBHelper.db;

  if (product == null) return;

  int qty = int.tryParse(qtyController.text) ?? 0;
  int currentStock =
      int.tryParse(product!['stock'].toString()) ?? 0;

  double actualSellPrice =
      double.tryParse(sellPriceController.text) ?? 0;

  if (qty <= 0 || currentStock < qty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid / Not enough stock")),
    );
    return;
  }

  int newStock = currentStock - qty;

  // 1️⃣ UPDATE DB
  await db.update(
    'products',
    {'stock': newStock},
    where: 'barcode = ?',
    whereArgs: [product!['barcode']],
  );

  // 2️⃣ INSERT SALES
  await db.insert('sales', {
    'barcode': product!['barcode'],
    'qty': qty,
    'sell_price': actualSellPrice,
    'total': actualSellPrice * qty,
    'date': DateTime.now().toString(),
  });

  // 3️⃣ UPDATE LOCAL UI
  setState(() {
    product!['stock'] = newStock;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Sold Successfully")),
  );

  // 4️⃣ IMPORTANT FIX (WAIT + BACK FLOW CLEAN)
  await Future.delayed(const Duration(milliseconds: 300));

  if (!mounted) return;

  Navigator.of(context).pop(true); 
}

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Product Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Product Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            DataTable(
              border: TableBorder.all(),
              columns: const [
                DataColumn(label: Text("Field")),
                DataColumn(label: Text("Value")),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text("Name")),
                  DataCell(Text(product!['name'].toString())),
                ]),
                DataRow(cells: [
                  const DataCell(Text("Barcode")),
                  DataCell(Text(product!['barcode'].toString())),
                ]),
                DataRow(cells: [
                  const DataCell(Text("Purchase Price")),
                  DataCell(Text(
                    PriceEncoder.encode(
                      product!['purchase_price'],
                    ),
                  )),
                ]),
                DataRow(cells: [
                  const DataCell(Text("Selling Price")),
                  DataCell(Text(product!['selling_price'].toString())),
                ]),
                DataRow(cells: [
                  const DataCell(Text("Stock")),
                  DataCell(Text(product!['stock'].toString())),
                ]),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity to Sell",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: sellPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Selling Price (Editable)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: confirmSell,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("SELL PRODUCT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}